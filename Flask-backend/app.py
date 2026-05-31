from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_wtf import FlaskForm
from config import Config
from forms import ReservationSearchForm, ReservationDetailsForm
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, date, time

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

def get_db_connection():
    conn = psycopg2.connect(app.config['DATABASE_URL'])
    conn.cursor_factory = RealDictCursor
    return conn

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Cafe Fausse API is running'})

@app.route('/api/find-available-tables', methods=['POST'])
def find_available_tables():
    # Get JSON data instead of form data
    data = request.get_json()
    
    date_str = data.get('date')
    people_str = data.get('people')
    time_str = data.get('time')
    
    if not all([date_str, people_str, time_str]):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        from datetime import date, time
        selected_date = date.fromisoformat(date_str)
        people = int(people_str)
        
        # Handle time with or without seconds
        if ':' in time_str:
            parts = time_str.split(':')
            selected_time = time(int(parts[0]), int(parts[1]), int(parts[2]) if len(parts) == 3 else 0)
        else:
            return jsonify({'error': 'Invalid time format'}), 400
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT * FROM fn_find_available_tables(
                %s::date,
                %s::time,
                %s::integer
            )
        """, (selected_date, selected_time, people))
        
        tables = cur.fetchall()
        cur.close()
        conn.close()
        
        if not tables:
            return jsonify({
                'available': False,
                'message': 'No tables available for the selected time',
                'tables': []
            }), 200
        
        return jsonify({
            'available': True,
            'message': f'Found {len(tables)} available table(s)',
            'tables': [
                {
                    'table_number': t['table_number'],
                    'capacity': t['capacity'],
                    'table_type': t['table_type'],
                    'min_capacity': t['min_capacity'],
                    'max_capacity': t['max_capacity']
                }
                for t in tables
            ]
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/check-table-availability', methods=['POST'])
def check_table_availability():
    data = request.json
    
    if not all(k in data for k in ['table_number', 'date', 'time', 'party_size']):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            SELECT fn_check_table_availability(
                %s::integer,
                %s::date,
                %s::time,
                %s::integer
            ) as available
        """, (data['table_number'], data['date'], data['time'], data['party_size']))
        
        result = cur.fetchone()
        cur.close()
        conn.close()
        
        return jsonify({
            'available': result['available'],
            'table_number': data['table_number']
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/create-customer', methods=['POST'])
def create_customer():
    form = ReservationDetailsForm(data=request.form)
    
    if not form.validate():
        return jsonify({'error': 'Invalid input', 'details': form.errors}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup, newsletter_verified)
            VALUES (%s, %s, %s, %s, %s, FALSE)
            RETURNING id, email
        """, (
            form.firstName.data,
            form.lastName.data,
            form.email.data,
            form.phone.data or None,
            form.newsletter.data
        ))
        
        customer = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'customer_id': customer['id'],
            'email': customer['email'],
            'message': 'Customer created successfully'
        }), 201
        
    except psycopg2.IntegrityError as e:
        conn.rollback()
        return jsonify({'error': 'Email already exists'}), 409
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/get-or-create-customer', methods=['POST'])
def get_or_create_customer():
    form = ReservationDetailsForm(data=request.form)
    
    if not form.validate():
        return jsonify({'error': 'Invalid input', 'details': form.errors}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Check if customer exists by email
        cur.execute("""
            SELECT id FROM customers WHERE email = %s
        """, (form.email.data,))
        
        existing = cur.fetchone()
        
        if existing:
            customer_id = existing['id']
            cur.close()
            conn.close()
            
            return jsonify({
                'success': True,
                'customer_id': customer_id,
                'existing': True,
                'message': 'Existing customer found'
            }), 200
        
        # Create new customer
        cur.execute("""
            INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup, newsletter_verified)
            VALUES (%s, %s, %s, %s, %s, FALSE)
            RETURNING id
        """, (
            form.firstName.data,
            form.lastName.data,
            form.email.data,
            form.phone.data or None,
            form.newsletter.data
        ))
        
        customer = cur.fetchone()
        conn.commit()
        customer_id = customer['id']
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'customer_id': customer_id,
            'existing': False,
            'message': 'New customer created'
        }), 201
        
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/create-reservation', methods=['POST'])
def create_reservation():
    data = request.json
    
    required_fields = ['customer_id', 'date', 'time', 'party_size', 'table_number']
    if not all(k in data for k in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Call the PostgreSQL function to create reservation
        cur.execute("""
            SELECT * FROM fn_create_reservation(
                %s::integer,
                %s::date,
                %s::time,
                %s::integer,
                %s::integer,
                'confirmed'::varchar
            )
        """, (
            data['customer_id'],
            data['date'],
            data['time'],
            data['party_size'],
            data['table_number']
        ))
        
        result = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        if result['message'] == 'Reservation created successfully':
            return jsonify({
                'success': True,
                'reservation_id': result['reservation_id'],
                'message': result['message'],
                'reservation': {
                    'id': result['reservation_id'],
                    'customer_id': result['customer_id'],
                    'start_time': str(result['start_time']),
                    'end_time': str(result['end_time']),
                    'party_size': result['party_size'],
                    'table_number': result['table_number'],
                    'table_type': result['table_type'],
                    'status': result['status']
                }
            }), 201
        else:
            return jsonify({
                'success': False,
                'error': result['message']
            }), 400
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/create-reservation-auto', methods=['POST'])
def create_reservation_auto():
    data = request.json
    
    required_fields = ['customer_id', 'date', 'time', 'party_size']
    if not all(k in data for k in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Call the auto-table function
        cur.execute("""
            SELECT * FROM fn_create_reservation_auto_table(
                %s::integer,
                %s::date,
                %s::time,
                %s::integer,
                'confirmed'::varchar
            )
        """, (
            data['customer_id'],
            data['date'],
            data['time'],
            data['party_size']
        ))
        
        result = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
        
        if result['message'] == 'Reservation created successfully':
            return jsonify({
                'success': True,
                'reservation_id': result['reservation_id'],
                'message': result['message'],
                'reservation': {
                    'id': result['reservation_id'],
                    'customer_id': result['customer_id'],
                    'start_time': str(result['start_time']),
                    'end_time': str(result['end_time']),
                    'party_size': result['party_size'],
                    'table_number': result['table_number'],
                    'table_type': result['table_type'],
                    'status': result['status']
                }
            }), 201
        else:
            return jsonify({
                'success': False,
                'error': result['message']
            }), 400
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/todays-reservations', methods=['GET'])
def get_todays_reservations():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT * FROM v_todays_reservations ORDER BY start_time")
        reservations = cur.fetchall()
        
        cur.close()
        conn.close()
        
        return jsonify({
            'reservations': [
                {
                    'id': r['id'],
                    'customer_id': r['customer_id'],
                    'customer_name': f"{r['first_name']} {r['last_name']}",
                    'email': r['email'],
                    'phone': r['phone'],
                    'start_time': str(r['start_time']),
                    'end_time': str(r['end_time']),
                    'party_size': r['party_size'],
                    'table_number': r['table_number'],
                    'table_type': r['table_type'],
                    'status': r['status']
                }
                for r in reservations
            ]
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)

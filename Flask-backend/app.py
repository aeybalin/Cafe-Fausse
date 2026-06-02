from flask import Flask, request, jsonify
from flask_cors import CORS
from config import Config, config
#from forms import ReservationSearchForm, ReservationDetailsForm
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import date, time, datetime

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
app.config['SECRET_KEY'] = config.SECRET_KEY


def get_db_connection():
    conn = psycopg2.connect(app.config['DATABASE_URL'])
    conn.cursor_factory = RealDictCursor
    return conn


@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Cafe Fausse API is running'})


@app.route('/api/find-available-tables', methods=['POST'])
def find_available_tables():
    data = request.get_json()
    
    date_str = data.get('date')
    people_str = data.get('people')
    time_str = data.get('time')
    
    if not all([date_str, people_str, time_str]):
        return jsonify({'error': 'Missing required fields'}), 400
    
    try:
        selected_date = date.fromisoformat(date_str)
        people = int(people_str)
        
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

@app.route('/api/find-available-times', methods=['POST'])
def find_available_times():
    data = request.get_json()
    
    date_str = data.get('date')
    people_str = data.get('people')
    
    if not date_str or not people_str:
        return jsonify({
            'error': 'Missing required fields: date and people',
            'available_times': []
        }), 400
    
    try:
        selected_date = date.fromisoformat(date_str)
        people = int(people_str)
    except ValueError:
        return jsonify({
            'error': 'Invalid date or people value',
            'available_times': []
        }), 400
    
    # Generate time slots based on day of week (same logic as in Reservation.js)
    day = selected_date.weekday()  # 0=Mon, ..., 4=Fri, 5=Sat, 6=Sun
    
    start_hour = 17  # 5pm
    # Sunday (6) closes at 7pm, others at 9pm
    end_hour = 19 if day == 6 else 21
    
    # Generate 15-minute slots from start_hour:00 to end_hour:00
    slots = []
    for hour in range(start_hour, end_hour):
        for minute in [0, 15, 30, 45]:
            time_str = f"{hour:02d}:{minute:02d}:00"
            slots.append(time_str)
    
    available_times = []
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        for time_str in slots:
            # Parse time for the function call
            parts = time_str.split(':')
            selected_time = time(int(parts[0]), int(parts[1]), int(parts[2]))
            
            cur.execute("""
                SELECT * FROM fn_find_available_tables(
                    %s::date,
                    %s::time,
                    %s::integer
                )
            """, (selected_date, selected_time, people))
            
            tables = cur.fetchall()
            
            # If at least one table is available, this time slot is available
            if tables:
                available_times.append(time_str)
        
        cur.close()
        conn.close()
        
        return jsonify({
            'available_times': available_times,
            'date': date_str,
            'people': people,
            'total_available_slots': len(available_times)
        }), 200
    
    except Exception as e:
        print(f"ERROR in find_available_times: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': str(e),
            'available_times': []
        }), 500


@app.route('/api/reserve-table', methods=['POST'])
def reserve_table():
    data = request.get_json()
    
    date_str = data.get('date')
    people_str = data.get('people')
    time_str = data.get('time')
    occasion = data.get('occasion', '')
    first_name = data.get('firstName', '') or data.get('first_name', '')
    last_name = data.get('lastName', '') or data.get('last_name', '')
    email = data.get('email', '')
    phone_raw = data.get('phone', '') or data.get('phone')
    text_updates = data.get('textUpdates', False) or data.get('text_updates', False)
    
    # Use NULL for phone if empty or not provided
    phone = phone_raw if phone_raw and phone_raw.strip() else None
    
    if not all([date_str, people_str, time_str, email]):
        return jsonify({
            'error': 'Missing required fields: date, people, time, email',
            'success': False
        }), 400
    
    conn = None
    cur = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Step 1: Look up or create customer
        cur.execute("""
            SELECT id FROM customers WHERE email = %s
        """, (email,))
        
        customer_result = cur.fetchone()
        
        if customer_result:
            customer_id = customer_result['id']
        else:
            cur.execute("""
                INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id
            """, (first_name, last_name, email, phone, text_updates))
            
            customer_id = cur.fetchone()['id']
            conn.commit()
        
        # Step 2: Find an available table
        cur.execute("""
            SELECT * FROM fn_find_available_tables(
                %s::date,
                %s::time,
                %s::integer
            )
        """, (date_str, time_str, int(people_str)))
        
        tables = cur.fetchall()
        
        if not tables:
            return jsonify({
                'error': 'No tables available for this time slot',
                'success': False
            }), 409
        
        # Use the first available table
        table_number = tables[0]['table_number']
        
        # Step 3: Create the reservation using the function
        cur.execute("""
            SELECT * FROM fn_create_reservation(
                %s, %s::date, %s::time, %s, %s, %s, %s
            )
        """, (customer_id, date_str, time_str, int(people_str), table_number, 'confirmed', occasion))
        
        result = cur.fetchone()
        conn.commit()
        
        return jsonify({
            'success': True,
            'message': 'Reservation confirmed',
            'reservation_id': result['reservation_id'],
            'table_number': result['table_number']
        }), 201
        
    except psycopg2.IntegrityError as e:
        print(f"INTEGRITY ERROR: {e}")
        if conn:
            conn.rollback()
        return jsonify({
            'error': 'This time slot is no longer available. Please try again.',
            'success': False
        }), 409
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500
        
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()
    
    # Fallback return (should never reach here, but ensures we always return)
    return jsonify({
        'success': False,
        'error': 'Unknown error',
    }), 500

@app.route('/api/newsletter-signup', methods=['POST'])
def newsletter_signup():
    data = request.get_json()
    
    first_name = data.get('firstName', '') or data.get('first_name', '')
    last_name = data.get('lastName', '') or data.get('last_name', '')
    email = data.get('email', '')
    phone_raw = data.get('phone', '') or data.get('phone')
    
    if not all([first_name, last_name, email]):
        return jsonify({
            'error': 'Missing required fields: firstName, lastName, email',
            'success': False
        }), 400
    
    # Use NULL for phone if empty or not provided
    phone = phone_raw if phone_raw and phone_raw.strip() else None
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Insert or update customer, setting newsletter_signup = TRUE
        cur.execute("""
            INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup)
            VALUES (%s, %s, %s, %s, TRUE)
            ON CONFLICT (email) DO UPDATE SET 
                first_name = EXCLUDED.first_name,
                last_name = EXCLUDED.last_name,
                phone = EXCLUDED.phone,
                newsletter_signup = TRUE
            RETURNING id
        """, (first_name, last_name, email, phone))
        
        customer_id = cur.fetchone()['id']
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Thank you for signing up for our newsletter!',
            'customer_id': customer_id
        }), 201
        
    except Exception as e:
        print(f"NEWSLETTER ERROR: {e}")
        if 'conn' in locals():
            conn.rollback()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500


if __name__ == '__main__':
    app.run(debug=True, port=5001, host='127.0.0.1')

from flask import Flask, request, jsonify
from flask_cors import CORS
from config import Config, config
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import date, time, datetime

app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
app.config['SECRET_KEY'] = config.SECRET_KEY


def get_db_connection():
    conn = psycopg2.connect(config.DATABASE_URL)
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


@app.route('/api/reserve-table', methods=['POST'])
def reserve_table():
    data = request.get_json()
    
    date_str = data.get('date')
    people_str = data.get('people')
    time_str = data.get('time')
    name = data.get('name', '')
    first_name = name.split(' ', 1)[0] if name else ''
    last_name = name.split(' ', 1)[1] if name and ' ' in name else ''
    email = data.get('email')
    phone = data.get('phone', '') or None
    text_updates = data.get('textUpdates', False)
    
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
            INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (email) DO UPDATE SET 
                first_name = EXCLUDED.first_name, 
                last_name = EXCLUDED.last_name,
                phone = EXCLUDED.phone
            RETURNING id
        """, (first_name, last_name, email, phone, text_updates))
        
        customer = cur.fetchone()
        customer_id = customer['id']
        
        # Step 2: Parse time
        if ':' in time_str:
            parts = time_str.split(':')
            reservation_time = time(int(parts[0]), int(parts[1]), int(parts[2]) if len(parts) == 3 else 0)
        else:
            return jsonify({'error': 'Invalid time format. Use HH:MM:SS'}), 400
        
        selected_date = date.fromisoformat(date_str)
        start_datetime = datetime.combine(selected_date, reservation_time)
        
        # Step 3: Get available table with table_number AND table_type
        cur.execute("""
            SELECT table_number, table_type FROM fn_find_available_tables(
                %s::date, %s::time, %s::integer
            ) LIMIT 1
        """, (selected_date, reservation_time, int(people_str)))
        
        table_result = cur.fetchone()
        if not table_result:
            return jsonify({
                'error': 'No tables available for this time slot',
                'success': False
            }), 400
        
        table_number = table_result['table_number']
        table_type = table_result['table_type']
        
        # Step 4: Insert reservation with table_type (NOT end_time - it's generated)
        cur.execute("""
            INSERT INTO reservations (customer_id, start_time, party_size, table_number, table_type, status)
            VALUES (%s, %s, %s, %s, %s, 'confirmed')
            RETURNING id
        """, (customer_id, start_datetime, int(people_str), table_number, table_type))
        
        reservation_id = cur.fetchone()['id']
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Reservation confirmed',
            'reservation_id': reservation_id,
            'table_number': table_number,
            'table_type': table_type,
            'customer_id': customer_id
        }), 201
        
    except psycopg2.IntegrityError as e:
        if conn:
            conn.rollback()
        if cur:
            cur.close()
        if conn:
            conn.close()
        print(f"INTEGRITY ERROR: {e}")
        return jsonify({
            'error': f'This time slot is no longer available: {str(e)}',
            'success': False
        }), 409
        
    except Exception as e:
        if conn:
            conn.rollback()
        if cur:
            cur.close()
        if conn:
            conn.close()
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e), 'success': False}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5001, host='127.0.0.1')

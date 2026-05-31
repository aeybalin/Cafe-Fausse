-- =====================================================
-- SCRIPT 2: CREATE DATABASE SCHEMA
-- File: 02_create_schema.sql
-- Run in: Query Tool connected to 'cafe_fausse_db' database
-- =====================================================

DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS dining_tables CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    newsletter_signup BOOLEAN NOT NULL DEFAULT FALSE,
    newsletter_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone IS NULL OR phone ~ '^[0-9\-\+\\(\\) ]+$')
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_last_name ON customers(last_name);
CREATE INDEX idx_customers_created_at ON customers(created_at);

CREATE TABLE dining_tables (
    table_number INTEGER PRIMARY KEY,
    capacity INTEGER NOT NULL,
    table_type VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT chk_table_capacity CHECK (
        (table_type = 'small' AND capacity BETWEEN 1 AND 4) OR
        (table_type = 'medium' AND capacity BETWEEN 5 AND 8) OR
        (table_type = 'large' AND capacity BETWEEN 9 AND 12)
    ),
    
    CONSTRAINT chk_table_type CHECK (table_type IN ('small', 'medium', 'large'))
);

CREATE INDEX idx_dining_tables_capacity ON dining_tables(capacity);
CREATE INDEX idx_dining_tables_type ON dining_tables(table_type);
CREATE INDEX idx_dining_tables_active ON dining_tables(is_active) WHERE is_active = TRUE;

INSERT INTO dining_tables (table_number, capacity, table_type)
SELECT generate_series(1, 5), 2, 'small'
UNION ALL
SELECT generate_series(6, 10), 3, 'small'
UNION ALL
SELECT generate_series(11, 20), 4, 'small'
UNION ALL
SELECT generate_series(21, 24), 5, 'medium'
UNION ALL
SELECT generate_series(25, 27), 6, 'medium'
UNION ALL
SELECT 28, 8, 'medium'
UNION ALL
VALUES (29, 10, 'large'), (30, 12, 'large');

CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    party_size INTEGER NOT NULL,
    table_number INTEGER NOT NULL,
    table_type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_reservations_customer 
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    
    CONSTRAINT fk_reservations_table 
        FOREIGN KEY (table_number) REFERENCES dining_tables(table_number) ON DELETE RESTRICT,
    
    CONSTRAINT chk_party_size CHECK (party_size > 0 AND party_size <= 12),
    CONSTRAINT chk_table_type CHECK (table_type IN ('small', 'medium', 'large')),
    CONSTRAINT chk_status CHECK (status IN ('confirmed', 'checked_in', 'completed', 'cancelled', 'no_show'))
);

ALTER TABLE reservations 
ADD COLUMN end_time TIMESTAMP GENERATED ALWAYS AS (start_time + INTERVAL '2 hours') STORED;

CREATE OR REPLACE FUNCTION check_party_size_vs_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.party_size > (SELECT capacity FROM dining_tables WHERE table_number = NEW.table_number) THEN
        RAISE EXCEPTION 'Party size % exceeds table % capacity %', 
            NEW.party_size, NEW.table_number, 
            (SELECT capacity FROM dining_tables WHERE table_number = NEW.table_number);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_party_capacity
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION check_party_size_vs_capacity();

CREATE OR REPLACE FUNCTION check_no_overlap()
RETURNS TRIGGER AS $$
DECLARE
    v_conflicts INTEGER;
    v_end_time TIMESTAMP;
BEGIN
    v_end_time := NEW.start_time + INTERVAL '2 hours';
    
    SELECT COUNT(*) INTO v_conflicts
    FROM reservations
    WHERE table_number = NEW.table_number
      AND status IN ('confirmed', 'checked_in')
      AND id IS DISTINCT FROM NEW.id
      AND (
          (start_time <= NEW.start_time AND end_time > NEW.start_time)
          OR
          (start_time >= NEW.start_time AND start_time < v_end_time)
      );
    
    IF v_conflicts > 0 THEN
        RAISE EXCEPTION 'Table % is not available at % (already reserved)', 
            NEW.table_number, NEW.start_time;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_no_overlap
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
    EXECUTE FUNCTION check_no_overlap();

CREATE INDEX idx_reservations_start_time ON reservations(start_time);
CREATE INDEX idx_reservations_table_number ON reservations(table_number);
CREATE INDEX idx_reservations_time_table ON reservations(table_number, start_time);
CREATE INDEX idx_reservations_customer_id ON reservations(customer_id);
CREATE INDEX idx_reservations_status ON reservations(status) WHERE status IN ('confirmed', 'checked_in');

CREATE OR REPLACE FUNCTION fn_find_available_tables(
    p_date DATE,
    p_time TIME,
    p_party_size INTEGER
)
RETURNS TABLE (
    table_number INTEGER,
    capacity INTEGER,
    table_type VARCHAR(20),
    min_capacity INTEGER,
    max_capacity INTEGER
) AS $$
DECLARE
    v_start_time TIMESTAMP;
BEGIN
    v_start_time := MAKE_TIMESTAMP(
        EXTRACT(YEAR FROM p_date)::INTEGER,
        EXTRACT(MONTH FROM p_date)::INTEGER,
        EXTRACT(DAY FROM p_date)::INTEGER,
        EXTRACT(HOUR FROM p_time)::INTEGER,
        EXTRACT(MINUTE FROM p_time)::INTEGER
    );
    
    RETURN QUERY
    SELECT 
        dt.table_number,
        dt.capacity,
        dt.table_type,
        CASE 
            WHEN dt.table_type = 'small' THEN 1
            WHEN dt.table_type = 'medium' THEN 5
            WHEN dt.table_type = 'large' THEN 9
        END AS min_capacity,
        CASE 
            WHEN dt.table_type = 'small' THEN 4
            WHEN dt.table_type = 'medium' THEN 8
            WHEN dt.table_type = 'large' THEN 12
        END AS max_capacity
    FROM dining_tables dt
    WHERE dt.is_active = TRUE
      AND dt.capacity >= p_party_size
      AND dt.table_number NOT IN (
          SELECT r.table_number
          FROM reservations r
          WHERE r.status IN ('confirmed', 'checked_in')
            AND (
                (r.start_time <= v_start_time AND r.end_time > v_start_time)
                OR
                (r.start_time >= v_start_time AND r.start_time < v_start_time + INTERVAL '2 hours')
                OR
                (r.start_time <= v_start_time AND r.end_time >= v_start_time + INTERVAL '2 hours')
            )
      )
    ORDER BY dt.capacity, dt.table_number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_check_table_availability(
    p_table_number INTEGER,
    p_date DATE,
    p_time TIME,
    p_party_size INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_capacity INTEGER;
    v_conflicts INTEGER;
BEGIN
    v_start_time := MAKE_TIMESTAMP(
        EXTRACT(YEAR FROM p_date)::INTEGER,
        EXTRACT(MONTH FROM p_date)::INTEGER,
        EXTRACT(DAY FROM p_date)::INTEGER,
        EXTRACT(HOUR FROM p_time)::INTEGER,
        EXTRACT(MINUTE FROM p_time)::INTEGER
    );
    
    SELECT capacity INTO v_capacity 
    FROM dining_tables 
    WHERE table_number = p_table_number AND is_active = TRUE;
    
    IF v_capacity IS NULL THEN
        RAISE EXCEPTION 'Table % does not exist or is inactive', p_table_number;
    END IF;
    
    IF p_party_size > v_capacity THEN
        RETURN FALSE;
    END IF;
    
    SELECT COUNT(*) INTO v_conflicts
    FROM reservations
    WHERE table_number = p_table_number
      AND status IN ('confirmed', 'checked_in')
      AND (
          (start_time <= v_start_time AND end_time > v_start_time)
          OR
          (start_time >= v_start_time AND start_time < v_start_time + INTERVAL '2 hours')
      );
    
    RETURN v_conflicts = 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_create_reservation(
    p_customer_id INTEGER,
    p_date DATE,
    p_time TIME,
    p_party_size INTEGER,
    p_table_number INTEGER,
    p_status VARCHAR(20) DEFAULT 'confirmed'
)
RETURNS TABLE (
    reservation_id INTEGER,
    customer_id INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    party_size INTEGER,
    table_number INTEGER,
    table_type VARCHAR(20),
    status VARCHAR(20),
    message VARCHAR(255)
) AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_capacity INTEGER;
    v_table_type VARCHAR(20);
    v_conflicts INTEGER;
    v_customer_exists INTEGER;
BEGIN
    v_start_time := MAKE_TIMESTAMP(
        EXTRACT(YEAR FROM p_date)::INTEGER,
        EXTRACT(MONTH FROM p_date)::INTEGER,
        EXTRACT(DAY FROM p_date)::INTEGER,
        EXTRACT(HOUR FROM p_time)::INTEGER,
        EXTRACT(MINUTE FROM p_time)::INTEGER
    );
    v_end_time := v_start_time + INTERVAL '2 hours';
    
    SELECT COUNT(*) INTO v_customer_exists FROM customers WHERE id = p_customer_id;
    IF v_customer_exists = 0 THEN
        RAISE EXCEPTION 'Customer ID % does not exist', p_customer_id;
    END IF;
    
    SELECT capacity, table_type INTO v_capacity, v_table_type
    FROM dining_tables 
    WHERE table_number = p_table_number AND is_active = TRUE;
    
    IF v_capacity IS NULL THEN
        RAISE EXCEPTION 'Table % does not exist or is inactive', p_table_number;
    END IF;
    
    IF p_party_size > v_capacity THEN
        RAISE EXCEPTION 'Party size % exceeds table % capacity %', 
            p_party_size, p_table_number, v_capacity;
    END IF;
    
    IF p_party_size <= 0 THEN
        RAISE EXCEPTION 'Party size must be greater than 0';
    END IF;
    
    SELECT COUNT(*) INTO v_conflicts
    FROM reservations
    WHERE table_number = p_table_number
      AND status IN ('confirmed', 'checked_in')
      AND (
          (start_time <= v_start_time AND end_time > v_start_time)
          OR
          (start_time >= v_start_time AND start_time < v_end_time)
      );
    
    IF v_conflicts > 0 THEN
        RAISE EXCEPTION 'Table % is not available at % (already reserved)', 
            p_table_number, v_start_time;
    END IF;
    
    IF p_status NOT IN ('confirmed', 'checked_in', 'completed', 'cancelled', 'no_show') THEN
        RAISE EXCEPTION 'Invalid status. Must be: confirmed, checked_in, completed, cancelled, or no_show';
    END IF;
    
    INSERT INTO reservations (
        customer_id, 
        start_time, 
        party_size, 
        table_number, 
        table_type,
        status
    ) VALUES (
        p_customer_id,
        v_start_time,
        p_party_size,
        p_table_number,
        v_table_type,
        p_status
    )
    RETURNING id, customer_id, start_time, end_time, party_size, table_number, table_type, status
    INTO reservation_id, customer_id, start_time, end_time, party_size, table_number, table_type, status;
    
    message := 'Reservation created successfully';
    
    RETURN NEXT;
EXCEPTION
    WHEN RAISE_EXCEPTION THEN
        message := SQLERRM;
        reservation_id := NULL;
        customer_id := p_customer_id;
        start_time := v_start_time;
        end_time := v_end_time;
        party_size := p_party_size;
        table_number := p_table_number;
        table_type := NULL;
        status := NULL;
        RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_create_reservation_auto_table(
    p_customer_id INTEGER,
    p_date DATE,
    p_time TIME,
    p_party_size INTEGER,
    p_status VARCHAR(20) DEFAULT 'confirmed'
)
RETURNS TABLE (
    reservation_id INTEGER,
    customer_id INTEGER,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    party_size INTEGER,
    table_number INTEGER,
    table_type VARCHAR(20),
    status VARCHAR(20),
    message VARCHAR(255)
) AS $$
DECLARE
    v_available_table RECORD;
BEGIN
    SELECT table_number INTO v_available_table
    FROM fn_find_available_tables(p_date, p_time, p_party_size)
    LIMIT 1;
    
    IF v_available_table.table_number IS NULL THEN
        message := 'No tables available for party of ' || p_party_size || ' at ' || p_time;
        reservation_id := NULL;
        customer_id := p_customer_id;
        start_time := MAKE_TIMESTAMP(
            EXTRACT(YEAR FROM p_date)::INTEGER,
            EXTRACT(MONTH FROM p_date)::INTEGER,
            EXTRACT(DAY FROM p_date)::INTEGER,
            EXTRACT(HOUR FROM p_time)::INTEGER,
            EXTRACT(MINUTE FROM p_time)::INTEGER
        );
        end_time := start_time + INTERVAL '2 hours';
        party_size := p_party_size;
        table_number := NULL;
        table_type := NULL;
        status := NULL;
        RETURN NEXT;
        RETURN;
    END IF;
    
    RETURN QUERY
    SELECT * FROM fn_create_reservation(
        p_customer_id,
        p_date,
        p_time,
        p_party_size,
        v_available_table.table_number,
        p_status
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW v_todays_reservations AS
SELECT 
    r.id,
    r.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    r.start_time,
    r.end_time,
    r.party_size,
    r.table_number,
    r.table_type,
    r.status,
    r.created_at
FROM reservations r
JOIN customers c ON r.customer_id = c.id
WHERE r.start_time >= CURRENT_DATE 
  AND r.start_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY r.start_time;

CREATE OR REPLACE VIEW v_table_availability_summary AS
SELECT 
    dt.table_type,
    COUNT(*) AS total_tables,
    COUNT(*) FILTER (WHERE dt.is_active = TRUE) AS active_tables,
    MIN(dt.capacity) AS min_capacity,
    MAX(dt.capacity) AS max_capacity
FROM dining_tables dt
GROUP BY dt.table_type;

CREATE OR REPLACE VIEW v_customer_history AS
SELECT 
    c.id AS customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.created_at AS customer_since,
    COUNT(r.id) AS total_reservations,
    MIN(r.start_time) AS first_reservation,
    MAX(r.start_time) AS last_reservation
FROM customers c
LEFT JOIN reservations r ON c.id = r.id
GROUP BY c.id, c.first_name, c.last_name, c.email, c.phone, c.created_at;

INSERT INTO customers (first_name, last_name, email, phone, newsletter_signup) VALUES
    ('John', 'Doe', 'john.doe@example.com', '555-123-4567', TRUE),
    ('Jane', 'Smith', 'jane.smith@example.com', '555-234-5678', TRUE),
    ('Bob', 'Johnson', 'bob.johnson@example.com', '555-345-6789', FALSE),
    ('Alice', 'Williams', 'alice.williams@example.com', '555-456-7890', TRUE),
    ('Charlie', 'Brown', 'charlie.brown@example.com', '555-567-8901', FALSE);

SELECT tablename AS table_name
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

SELECT table_type, COUNT(*) AS count 
FROM dining_tables 
GROUP BY table_type
ORDER BY table_type;

SELECT COUNT(*) AS total_customers FROM customers;
SELECT * FROM customers;

SELECT proname AS function_name 
FROM pg_proc 
WHERE proname LIKE 'fn_%'
ORDER BY proname;

SELECT viewname AS view_name 
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;

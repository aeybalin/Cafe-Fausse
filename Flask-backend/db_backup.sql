--
-- PostgreSQL database dump
--

\restrict LR37EXvdxOKE7dJEDKL28lfehw8PBZVy8utFrvWhYKN7t50nMsYDZqWNU0lhaEX

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-02 15:17:56 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 228 (class 1255 OID 16708)
-- Name: check_no_overlap(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_no_overlap() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.check_no_overlap() OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16706)
-- Name: check_party_size_vs_capacity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_party_size_vs_capacity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.party_size > (SELECT capacity FROM dining_tables WHERE table_number = NEW.table_number) THEN
        RAISE EXCEPTION 'Party size % exceeds table % capacity %', 
            NEW.party_size, NEW.table_number, 
            (SELECT capacity FROM dining_tables WHERE table_number = NEW.table_number);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_party_size_vs_capacity() OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16716)
-- Name: fn_check_table_availability(integer, date, time without time zone, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_check_table_availability(p_table_number integer, p_date date, p_time time without time zone, p_party_size integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_check_table_availability(p_table_number integer, p_date date, p_time time without time zone, p_party_size integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16739)
-- Name: fn_create_reservation(integer, date, time without time zone, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_create_reservation(p_customer_id integer, p_date date, p_time time without time zone, p_party_size integer, p_table_number integer, p_status character varying, p_occasion character varying) RETURNS TABLE(reservation_id integer, message text, start_time timestamp without time zone, end_time timestamp without time zone, table_number integer, table_type character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_reservation_id INTEGER;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_table_type VARCHAR(20);
BEGIN
    -- Get the table type from dining_tables
    SELECT dt.table_type INTO v_table_type
    FROM dining_tables dt
    WHERE dt.table_number = p_table_number;
    
    -- Calculate start and end times
    v_start_time := p_date::TIMESTAMP + p_time::INTERVAL;
    v_end_time := v_start_time + INTERVAL '2 hours';
    
    -- Insert the reservation (include occasion, NOT end_time since it's generated)
    INSERT INTO reservations (
        customer_id,
        start_time,
        party_size,
        table_number,
        table_type,
        status,
        occasion
    ) VALUES (
        p_customer_id,
        v_start_time,
        p_party_size,
        p_table_number,
        v_table_type,
        p_status,
        p_occasion
    ) RETURNING id INTO v_reservation_id;
    
    -- Set return values
    reservation_id := v_reservation_id;
    message := 'Reservation created successfully';
    start_time := v_start_time;
    end_time := v_end_time;
    table_number := p_table_number;
    table_type := v_table_type;
    
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.fn_create_reservation(p_customer_id integer, p_date date, p_time time without time zone, p_party_size integer, p_table_number integer, p_status character varying, p_occasion character varying) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16718)
-- Name: fn_create_reservation_auto_table(integer, date, time without time zone, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_create_reservation_auto_table(p_customer_id integer, p_date date, p_time time without time zone, p_party_size integer, p_status character varying DEFAULT 'confirmed'::character varying) RETURNS TABLE(reservation_id integer, customer_id integer, start_time timestamp without time zone, end_time timestamp without time zone, party_size integer, table_number integer, table_type character varying, status character varying, message character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_create_reservation_auto_table(p_customer_id integer, p_date date, p_time time without time zone, p_party_size integer, p_status character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16740)
-- Name: fn_find_available_tables(date, time without time zone, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_find_available_tables(p_date date, p_time time without time zone, p_party_size integer) RETURNS TABLE(table_number integer, capacity integer, table_type character varying, min_capacity integer, max_capacity integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    -- Calculate the reservation time block (2 hours)
    v_start_time := p_date::TIMESTAMP + p_time::INTERVAL;
    v_end_time := v_start_time + INTERVAL '2 hours';
    
    -- Return available tables that:
    -- 1. Have capacity >= party size
    -- 2. Do NOT have any reservation overlapping the 2-hour block
    RETURN QUERY
    SELECT 
        dt.table_number,
        dt.capacity,
        dt.table_type,
        dt.min_capacity,
        dt.max_capacity
    FROM dining_tables dt
    WHERE dt.capacity >= p_party_size
      AND dt.is_active = TRUE
      AND NOT EXISTS (
        SELECT 1
        FROM reservations r
        WHERE r.table_number = dt.table_number
          AND r.status NOT IN ('cancelled', 'no_show')
          AND r.start_time < v_end_time
          AND r.end_time > v_start_time
      )
    ORDER BY dt.capacity;
END;
$$;


ALTER FUNCTION public.fn_find_available_tables(p_date date, p_time time without time zone, p_party_size integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16633)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(30),
    newsletter_signup boolean DEFAULT false NOT NULL,
    newsletter_verified boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_email_format CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT chk_phone_format CHECK (((phone IS NULL) OR ((phone)::text ~ '^[0-9\-\+\\(\\) ]+$'::text)))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16632)
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 219
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- TOC entry 221 (class 1259 OID 16656)
-- Name: dining_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dining_tables (
    table_number integer NOT NULL,
    capacity integer NOT NULL,
    table_type character varying(20) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    min_capacity integer,
    max_capacity integer,
    CONSTRAINT chk_table_capacity CHECK (((((table_type)::text = 'small'::text) AND ((capacity >= 1) AND (capacity <= 4))) OR (((table_type)::text = 'medium'::text) AND ((capacity >= 5) AND (capacity <= 8))) OR (((table_type)::text = 'large'::text) AND ((capacity >= 9) AND (capacity <= 12))))),
    CONSTRAINT chk_table_type CHECK (((table_type)::text = ANY ((ARRAY['small'::character varying, 'medium'::character varying, 'large'::character varying])::text[])))
);


ALTER TABLE public.dining_tables OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16672)
-- Name: reservations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservations (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    party_size integer NOT NULL,
    table_number integer NOT NULL,
    table_type character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'confirmed'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    end_time timestamp without time zone GENERATED ALWAYS AS ((start_time + '02:00:00'::interval)) STORED,
    occasion character varying(50),
    CONSTRAINT chk_party_size CHECK (((party_size > 0) AND (party_size <= 12))),
    CONSTRAINT chk_status CHECK (((status)::text = ANY ((ARRAY['confirmed'::character varying, 'checked_in'::character varying, 'completed'::character varying, 'cancelled'::character varying, 'no_show'::character varying])::text[]))),
    CONSTRAINT chk_table_type CHECK (((table_type)::text = ANY ((ARRAY['small'::character varying, 'medium'::character varying, 'large'::character varying])::text[])))
);


ALTER TABLE public.reservations OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16671)
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservations_id_seq OWNER TO postgres;

--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 222
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservations_id_seq OWNED BY public.reservations.id;


--
-- TOC entry 226 (class 1259 OID 16728)
-- Name: v_customer_history; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_customer_history AS
 SELECT c.id AS customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.created_at AS customer_since,
    count(r.id) AS total_reservations,
    min(r.start_time) AS first_reservation,
    max(r.start_time) AS last_reservation
   FROM (public.customers c
     LEFT JOIN public.reservations r ON ((c.id = r.id)))
  GROUP BY c.id, c.first_name, c.last_name, c.email, c.phone, c.created_at;


ALTER VIEW public.v_customer_history OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16724)
-- Name: v_table_availability_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_table_availability_summary AS
 SELECT table_type,
    count(*) AS total_tables,
    count(*) FILTER (WHERE (is_active = true)) AS active_tables,
    min(capacity) AS min_capacity,
    max(capacity) AS max_capacity
   FROM public.dining_tables dt
  GROUP BY table_type;


ALTER VIEW public.v_table_availability_summary OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16719)
-- Name: v_todays_reservations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_todays_reservations AS
 SELECT r.id,
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
   FROM (public.reservations r
     JOIN public.customers c ON ((r.customer_id = c.id)))
  WHERE ((r.start_time >= CURRENT_DATE) AND (r.start_time < (CURRENT_DATE + '1 day'::interval)))
  ORDER BY r.start_time;


ALTER VIEW public.v_todays_reservations OWNER TO postgres;

--
-- TOC entry 3697 (class 2604 OID 16636)
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- TOC entry 3702 (class 2604 OID 16675)
-- Name: reservations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations ALTER COLUMN id SET DEFAULT nextval('public.reservations_id_seq'::regclass);


--
-- TOC entry 3887 (class 0 OID 16633)
-- Dependencies: 220
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, first_name, last_name, email, phone, newsletter_signup, newsletter_verified, created_at) FROM stdin;
1	John	Doe	john.doe@example.com	555-123-4567	t	f	2026-05-30 16:10:17.763838
2	Jane	Smith	jane.smith@example.com	555-234-5678	t	f	2026-05-30 16:10:17.763838
3	Bob	Johnson	bob.johnson@example.com	555-345-6789	f	f	2026-05-30 16:10:17.763838
4	Alice	Williams	alice.williams@example.com	555-456-7890	t	f	2026-05-30 16:10:17.763838
5	Charlie	Brown	charlie.brown@example.com	555-567-8901	f	f	2026-05-30 16:10:17.763838
14	Barry	White	bwhite@gmail.com	4443332222	t	f	2026-05-31 21:41:40.749494
12	Charles	Ma	mchuck@gmail.com	\N	t	f	2026-05-31 21:18:10.530178
23	Bob	White	bobwhite@outlook.com	555-555-1212	t	f	2026-06-02 15:06:47.338916
\.


--
-- TOC entry 3888 (class 0 OID 16656)
-- Dependencies: 221
-- Data for Name: dining_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dining_tables (table_number, capacity, table_type, is_active, min_capacity, max_capacity) FROM stdin;
1	2	small	t	1	4
2	2	small	t	1	4
3	2	small	t	1	4
4	2	small	t	1	4
5	2	small	t	1	4
6	3	small	t	1	4
7	3	small	t	1	4
8	3	small	t	1	4
9	3	small	t	1	4
10	3	small	t	1	4
11	4	small	t	1	4
12	4	small	t	1	4
13	4	small	t	1	4
14	4	small	t	1	4
15	4	small	t	1	4
16	4	small	t	1	4
17	4	small	t	1	4
18	4	small	t	1	4
19	4	small	t	1	4
20	4	small	t	1	4
21	5	medium	t	5	8
22	5	medium	t	5	8
23	5	medium	t	5	8
24	5	medium	t	5	8
25	6	medium	t	5	8
26	6	medium	t	5	8
27	6	medium	t	5	8
28	8	medium	t	5	8
29	10	large	t	9	12
30	12	large	t	9	12
\.


--
-- TOC entry 3890 (class 0 OID 16672)
-- Dependencies: 223
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservations (id, customer_id, start_time, party_size, table_number, table_type, status, created_at, occasion) FROM stdin;
3	12	2026-06-02 17:30:00	4	11	small	confirmed	2026-05-31 21:18:10.530178	\N
4	12	2026-06-03 17:30:00	4	11	small	confirmed	2026-05-31 21:36:06.292982	\N
5	14	2026-06-02 17:00:00	12	30	large	confirmed	2026-05-31 21:41:40.749494	\N
7	12	2026-06-02 17:30:00	4	12	small	confirmed	2026-06-01 11:36:23.670726	\N
8	12	2026-06-02 17:30:00	3	6	small	confirmed	2026-06-01 13:32:54.7997	\N
9	12	2026-06-02 17:15:00	4	13	small	confirmed	2026-06-02 13:45:12.731446	
11	12	2026-06-02 19:00:00	11	30	large	confirmed	2026-06-02 14:20:41.782933	
12	12	2026-06-02 17:45:00	8	28	medium	confirmed	2026-06-02 15:08:38.547562	
\.


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 219
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 23, true);


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 222
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_id_seq', 12, true);


--
-- TOC entry 3714 (class 2606 OID 16652)
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- TOC entry 3716 (class 2606 OID 16650)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- TOC entry 3721 (class 2606 OID 16667)
-- Name: dining_tables dining_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dining_tables
    ADD CONSTRAINT dining_tables_pkey PRIMARY KEY (table_number);


--
-- TOC entry 3731 (class 2606 OID 16690)
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- TOC entry 3717 (class 1259 OID 16655)
-- Name: idx_customers_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_created_at ON public.customers USING btree (created_at);


--
-- TOC entry 3718 (class 1259 OID 16653)
-- Name: idx_customers_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_email ON public.customers USING btree (email);


--
-- TOC entry 3719 (class 1259 OID 16654)
-- Name: idx_customers_last_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_last_name ON public.customers USING btree (last_name);


--
-- TOC entry 3722 (class 1259 OID 16670)
-- Name: idx_dining_tables_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dining_tables_active ON public.dining_tables USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 3723 (class 1259 OID 16668)
-- Name: idx_dining_tables_capacity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dining_tables_capacity ON public.dining_tables USING btree (capacity);


--
-- TOC entry 3724 (class 1259 OID 16669)
-- Name: idx_dining_tables_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dining_tables_type ON public.dining_tables USING btree (table_type);


--
-- TOC entry 3725 (class 1259 OID 16713)
-- Name: idx_reservations_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_customer_id ON public.reservations USING btree (customer_id);


--
-- TOC entry 3726 (class 1259 OID 16710)
-- Name: idx_reservations_start_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_start_time ON public.reservations USING btree (start_time);


--
-- TOC entry 3727 (class 1259 OID 16714)
-- Name: idx_reservations_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_status ON public.reservations USING btree (status) WHERE ((status)::text = ANY ((ARRAY['confirmed'::character varying, 'checked_in'::character varying])::text[]));


--
-- TOC entry 3728 (class 1259 OID 16711)
-- Name: idx_reservations_table_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_table_number ON public.reservations USING btree (table_number);


--
-- TOC entry 3729 (class 1259 OID 16712)
-- Name: idx_reservations_time_table; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_time_table ON public.reservations USING btree (table_number, start_time);


--
-- TOC entry 3734 (class 2620 OID 16709)
-- Name: reservations trg_check_no_overlap; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_no_overlap BEFORE INSERT OR UPDATE ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.check_no_overlap();


--
-- TOC entry 3735 (class 2620 OID 16707)
-- Name: reservations trg_check_party_capacity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_party_capacity BEFORE INSERT OR UPDATE ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.check_party_size_vs_capacity();


--
-- TOC entry 3732 (class 2606 OID 16691)
-- Name: reservations fk_reservations_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservations_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- TOC entry 3733 (class 2606 OID 16696)
-- Name: reservations fk_reservations_table; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservations_table FOREIGN KEY (table_number) REFERENCES public.dining_tables(table_number) ON DELETE RESTRICT;


-- Completed on 2026-06-02 15:17:57 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict LR37EXvdxOKE7dJEDKL28lfehw8PBZVy8utFrvWhYKN7t50nMsYDZqWNU0lhaEX


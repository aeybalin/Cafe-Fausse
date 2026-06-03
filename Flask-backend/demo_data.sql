-----------------------------------------------------------------------
-- DEMO DATA SETUP - not needed if you have restored from the backup --
-----------------------------------------------------------------------

-- Step 1: Reset sequences and clear data
DELETE FROM public.reservations;
DELETE FROM public.customers;
SELECT setval('public.reservations_id_seq', 1, false);
SELECT setval('public.customers_id_seq', 1, false);

-- Step 2: Insert customers (no changes needed)
INSERT INTO public.customers (first_name, last_name, email, phone, newsletter_signup, newsletter_verified) VALUES
('James', 'Anderson', 'james.anderson@email.com', '905-555-0101', true, true),
('Maria', 'Garcia', 'maria.garcia@email.com', NULL, true, true),
('Robert', 'Chen', 'robert.chen@email.com', '416-555-0103', false, false),
('Sarah', 'Thompson', 'sarah.thompson@email.com', NULL, true, true),
('Michael', 'Williams', 'michael.williams@email.com', '647-555-0105', true, false),
('Emily', 'Davis', 'emily.davis@email.com', NULL, false, false),
('David', 'Martinez', 'david.martinez@email.com', '647-555-0107', true, true),
('Jennifer', 'Taylor', 'jennifer.taylor@email.com', NULL, true, true),
('Christopher', 'Brown', 'christopher.brown@email.com', '905-555-0109', false, false),
('Amanda', 'Wilson', 'amanda.wilson@email.com', NULL, true, true),
('Daniel', 'Moore', 'daniel.moore@email.com', '905-555-0111', true, false),
('Jessica', 'Jackson', 'jessica.jackson@email.com', NULL, true, true),
('Matthew', 'White', 'matthew.white@email.com', '647-555-0113', false, false),
('Ashley', 'Harris', 'ashley.harris@email.com', NULL, true, true),
('Joshua', 'Martin', 'joshua.martin@email.com', '416-555-0115', true, false),
('Stephanie', 'Thompson', 'stephanie.thompson@email.com', NULL, false, false),
('Andrew', 'Garcia', 'andrew.garcia@email.com', '905-555-0117', true, true),
('Nicole', 'Martinez', 'nicole.martinez@email.com', NULL, true, true),
('Ryan', 'Robinson', 'ryan.robinson@email.com', '647-555-0119', false, false),
('Elizabeth', 'Clark', 'elizabeth.clark@email.com', NULL, true, true),
('Kevin', 'Rodriguez', 'kevin.rodriguez@email.com', '416-555-0121', true, false),
('Lauren', 'Lewis', 'lauren.lewis@email.com', NULL, true, true),
('Brandon', 'Lee', 'brandon.lee@email.com', '905-555-0123', false, false),
('Megan', 'Walker', 'megan.walker@email.com', NULL, true, true),
('Jason', 'Hall', 'jason.hall@email.com', '647-555-0125', true, false),
('Rachel', 'Allen', 'rachel.allen@email.com', NULL, false, false),
('Justin', 'Young', 'justin.young@email.com', '416-555-0127', true, true),
('Samuel', 'Hernandez', 'samuel.hernandez@email.com', NULL, true, true),
('Brittany', 'King', 'brittany.king@email.com', '905-555-0129', false, false),
('Benjamin', 'Wright', 'benjamin.wright@email.com', NULL, true, true),
('Alexander', 'Lopez', 'alexander.lopez@email.com', '647-555-0131', true, false),
('Kayla', 'Hill', 'kayla.hill@email.com', NULL, true, true),
('Nathan', 'Scott', 'nathan.scott@email.com', '416-555-0133', false, false),
('Victoria', 'Green', 'victoria.green@email.com', NULL, true, true),
('Zachary', 'Adams', 'zachary.adams@email.com', '905-555-0135', true, false);

-- Step 3: Insert reservations WITHOUT table_type column
INSERT INTO public.reservations (customer_id, start_time, party_size, table_number, status, occasion) VALUES
(1, '2026-06-10 17:00:00', 10, 29, 'confirmed', 'birthday'),
(2, '2026-06-10 19:00:00', 10, 29, 'confirmed', NULL),
(3, '2026-06-10 21:00:00', 11, 29, 'confirmed', NULL),
(4, '2026-06-10 17:00:00', 10, 30, 'confirmed', NULL),
(5, '2026-06-10 19:00:00', 10, 30, 'confirmed', NULL),
(6, '2026-06-10 21:00:00', 11, 30, 'confirmed', NULL),
(7, '2026-06-10 17:00:00', 6, 21, 'confirmed', NULL),
(8, '2026-06-10 17:00:00', 5, 22, 'confirmed', 'anniversary'),
(9, '2026-06-10 17:00:00', 7, 23, 'confirmed', NULL),
(10, '2026-06-10 17:00:00', 8, 24, 'confirmed', 'business'),
(11, '2026-06-10 17:00:00', 5, 25, 'confirmed', NULL),
(12, '2026-06-10 17:00:00', 6, 26, 'confirmed', 'celebration'),
(13, '2026-06-10 17:00:00', 7, 27, 'confirmed', NULL),
(14, '2026-06-10 17:00:00', 8, 28, 'confirmed', NULL),
(15, '2026-06-10 19:00:00', 6, 21, 'confirmed', NULL),
(16, '2026-06-10 19:00:00', 5, 22, 'confirmed', NULL),
(17, '2026-06-10 19:00:00', 7, 23, 'confirmed', NULL),
(18, '2026-06-10 19:00:00', 8, 24, 'confirmed', NULL),
(19, '2026-06-10 19:00:00', 5, 25, 'confirmed', NULL),
(20, '2026-06-10 19:00:00', 6, 26, 'confirmed', NULL),
(21, '2026-06-10 19:00:00', 7, 27, 'confirmed', NULL),
(22, '2026-06-10 19:00:00', 8, 28, 'confirmed', NULL),
(23, '2026-06-10 21:00:00', 6, 21, 'confirmed', NULL),
(24, '2026-06-10 21:00:00', 5, 22, 'confirmed', NULL),
(25, '2026-06-10 21:00:00', 7, 23, 'confirmed', NULL),
(26, '2026-06-10 21:00:00', 8, 24, 'confirmed', NULL),
(27, '2026-06-10 21:00:00', 5, 25, 'confirmed', NULL),
(28, '2026-06-10 21:00:00', 6, 26, 'confirmed', NULL),
(29, '2026-06-10 21:00:00', 7, 27, 'confirmed', NULL),
(30, '2026-06-10 21:00:00', 8, 28, 'confirmed', 'date night'),
(1, '2026-06-11 17:00:00', 10, 29, 'confirmed', NULL),
(2, '2026-06-11 19:00:00', 10, 29, 'confirmed', NULL),
(3, '2026-06-11 21:00:00', 11, 29, 'confirmed', NULL),
(4, '2026-06-11 17:00:00', 11, 30, 'confirmed', 'family gathering'),
(5, '2026-06-11 19:00:00', 10, 30, 'confirmed', NULL),
(6, '2026-06-11 21:00:00', 11, 30, 'confirmed', NULL),
(7, '2026-06-11 17:00:00', 2, 1, 'confirmed', NULL),
(8, '2026-06-11 17:00:00', 3, 2, 'confirmed', NULL),
(9, '2026-06-11 17:00:00', 4, 3, 'confirmed', 'birthday'),
(10, '2026-06-11 17:00:00', 2, 4, 'confirmed', NULL),
(11, '2026-06-11 17:00:00', 3, 5, 'confirmed', NULL),
(12, '2026-06-11 17:00:00', 4, 6, 'confirmed', 'anniversary'),
(13, '2026-06-11 17:00:00', 2, 7, 'confirmed', NULL),
(14, '2026-06-11 17:00:00', 3, 8, 'confirmed', NULL),
(15, '2026-06-11 17:00:00', 4, 9, 'confirmed', 'business'),
(16, '2026-06-11 17:00:00', 2, 10, 'confirmed', NULL),
(17, '2026-06-11 17:00:00', 3, 11, 'confirmed', NULL),
(18, '2026-06-11 17:00:00', 4, 12, 'confirmed', 'celebration'),
(19, '2026-06-11 17:00:00', 2, 13, 'confirmed', NULL),
(20, '2026-06-11 17:00:00', 3, 14, 'confirmed', NULL),
(21, '2026-06-11 17:00:00', 4, 15, 'confirmed', 'date night'),
(22, '2026-06-11 17:00:00', 2, 16, 'confirmed', NULL),
(23, '2026-06-11 17:00:00', 3, 17, 'confirmed', NULL),
(24, '2026-06-11 17:00:00', 4, 18, 'confirmed', NULL),
(25, '2026-06-11 17:00:00', 2, 19, 'confirmed', NULL),
(26, '2026-06-11 17:00:00', 3, 20, 'confirmed', 'family'),
(27, '2026-06-11 19:00:00', 2, 1, 'confirmed', NULL),
(28, '2026-06-11 19:00:00', 3, 2, 'confirmed', NULL),
(29, '2026-06-11 19:00:00', 4, 3, 'confirmed', NULL),
(30, '2026-06-11 19:00:00', 2, 4, 'confirmed', NULL),
(31, '2026-06-11 19:00:00', 3, 5, 'confirmed', NULL),
(32, '2026-06-11 19:00:00', 4, 6, 'confirmed', NULL),
(33, '2026-06-11 19:00:00', 2, 7, 'confirmed', NULL),
(34, '2026-06-11 19:00:00', 3, 8, 'confirmed', NULL),
(1, '2026-06-11 19:00:00', 4, 9, 'confirmed', NULL),
(2, '2026-06-11 19:00:00', 2, 10, 'confirmed', NULL),
(3, '2026-06-11 19:00:00', 3, 11, 'confirmed', NULL),
(4, '2026-06-11 19:00:00', 4, 12, 'confirmed', NULL),
(5, '2026-06-11 19:00:00', 2, 13, 'confirmed', NULL),
(6, '2026-06-11 19:00:00', 3, 14, 'confirmed', NULL),
(7, '2026-06-11 19:00:00', 4, 15, 'confirmed', NULL),
(8, '2026-06-11 19:00:00', 2, 16, 'confirmed', NULL),
(9, '2026-06-11 19:00:00', 3, 17, 'confirmed', NULL),
(10, '2026-06-11 19:00:00', 4, 18, 'confirmed', NULL),
(11, '2026-06-11 19:00:00', 2, 19, 'confirmed', NULL),
(12, '2026-06-11 19:00:00', 3, 20, 'confirmed', NULL),
(13, '2026-06-11 21:00:00', 4, 1, 'confirmed', NULL),
(14, '2026-06-11 21:00:00', 2, 2, 'confirmed', NULL),
(15, '2026-06-11 21:00:00', 3, 3, 'confirmed', NULL),
(16, '2026-06-11 21:00:00', 4, 4, 'confirmed', NULL),
(17, '2026-06-11 21:00:00', 2, 5, 'confirmed', NULL),
(18, '2026-06-11 21:00:00', 3, 6, 'confirmed', NULL),
(19, '2026-06-11 21:00:00', 4, 7, 'confirmed', NULL),
(20, '2026-06-11 21:00:00', 2, 8, 'confirmed', NULL),
(21, '2026-06-11 21:00:00', 3, 9, 'confirmed', NULL),
(22, '2026-06-11 21:00:00', 4, 10, 'confirmed', NULL),
(23, '2026-06-11 21:00:00', 2, 11, 'confirmed', NULL),
(24, '2026-06-11 21:00:00', 3, 12, 'confirmed', NULL),
(25, '2026-06-11 21:00:00', 4, 13, 'confirmed', NULL),
(26, '2026-06-11 21:00:00', 2, 14, 'confirmed', NULL),
(27, '2026-06-11 21:00:00', 3, 15, 'confirmed', NULL),
(28, '2026-06-11 21:00:00', 4, 16, 'confirmed', NULL),
(29, '2026-06-11 21:00:00', 2, 17, 'confirmed', NULL),
(30, '2026-06-11 21:00:00', 3, 18, 'confirmed', NULL),
(31, '2026-06-11 21:00:00', 4, 19, 'confirmed', NULL),
(32, '2026-06-11 21:00:00', 2, 20, 'confirmed', NULL);

-- Step 4: Verification with JOIN to get table_type from dining_tables
SELECT 
    'Customers total' as description, COUNT(*) as count,
    COUNT(*) FILTER (WHERE phone IS NOT NULL) as with_phone,
    COUNT(*) FILTER (WHERE phone IS NULL) as without_phone
FROM public.customers
UNION ALL
SELECT 'June 10 total', COUNT(*), NULL, NULL FROM public.reservations WHERE DATE(start_time) = '2026-06-10'
UNION ALL
SELECT 'June 10 medium', COUNT(*), NULL, NULL FROM public.reservations r JOIN dining_tables dt ON r.table_number = dt.table_number WHERE DATE(r.start_time) = '2026-06-10' AND dt.table_type = 'medium'
UNION ALL
SELECT 'June 10 large', COUNT(*), NULL, NULL FROM public.reservations r JOIN dining_tables dt ON r.table_number = dt.table_number WHERE DATE(r.start_time) = '2026-06-10' AND dt.table_type = 'large'
UNION ALL
SELECT 'June 11 total', COUNT(*), NULL, NULL FROM public.reservations WHERE DATE(start_time) = '2026-06-11'
UNION ALL
SELECT 'June 11 small', COUNT(*), NULL, NULL FROM public.reservations r JOIN dining_tables dt ON r.table_number = dt.table_number WHERE DATE(r.start_time) = '2026-06-11' AND dt.table_type = 'small'
UNION ALL
SELECT 'June 11 large', COUNT(*), NULL, NULL FROM public.reservations r JOIN dining_tables dt ON r.table_number = dt.table_number WHERE DATE(r.start_time) = '2026-06-11' AND dt.table_type = 'large';

--
-- PostgreSQL database dump
--

\restrict uXnfwFpDzykaQsU4HYNq64cwt9UxqxgBJOVMDx23Vum9zliVfUetiyCaBdTtj4Y

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-06-06 12:18:44 EDT

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
-- TOC entry 3885 (class 0 OID 16633)
-- Dependencies: 220
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, first_name, last_name, email, phone, newsletter_signup, newsletter_verified, created_at) FROM stdin;
1	James	Anderson	james.anderson@email.com	905-555-0101	t	t	2026-06-06 12:17:59.288884
2	Maria	Garcia	maria.garcia@email.com	\N	t	t	2026-06-06 12:17:59.288884
3	Robert	Chen	robert.chen@email.com	416-555-0103	f	f	2026-06-06 12:17:59.288884
4	Sarah	Thompson	sarah.thompson@email.com	\N	t	t	2026-06-06 12:17:59.288884
5	Michael	Williams	michael.williams@email.com	647-555-0105	t	f	2026-06-06 12:17:59.288884
6	Emily	Davis	emily.davis@email.com	\N	f	f	2026-06-06 12:17:59.288884
7	David	Martinez	david.martinez@email.com	647-555-0107	t	t	2026-06-06 12:17:59.288884
8	Jennifer	Taylor	jennifer.taylor@email.com	\N	t	t	2026-06-06 12:17:59.288884
9	Christopher	Brown	christopher.brown@email.com	905-555-0109	f	f	2026-06-06 12:17:59.288884
10	Amanda	Wilson	amanda.wilson@email.com	\N	t	t	2026-06-06 12:17:59.288884
11	Daniel	Moore	daniel.moore@email.com	905-555-0111	t	f	2026-06-06 12:17:59.288884
12	Jessica	Jackson	jessica.jackson@email.com	\N	t	t	2026-06-06 12:17:59.288884
13	Matthew	White	matthew.white@email.com	647-555-0113	f	f	2026-06-06 12:17:59.288884
14	Ashley	Harris	ashley.harris@email.com	\N	t	t	2026-06-06 12:17:59.288884
15	Joshua	Martin	joshua.martin@email.com	416-555-0115	t	f	2026-06-06 12:17:59.288884
16	Stephanie	Thompson	stephanie.thompson@email.com	\N	f	f	2026-06-06 12:17:59.288884
17	Andrew	Garcia	andrew.garcia@email.com	905-555-0117	t	t	2026-06-06 12:17:59.288884
18	Nicole	Martinez	nicole.martinez@email.com	\N	t	t	2026-06-06 12:17:59.288884
19	Ryan	Robinson	ryan.robinson@email.com	647-555-0119	f	f	2026-06-06 12:17:59.288884
20	Elizabeth	Clark	elizabeth.clark@email.com	\N	t	t	2026-06-06 12:17:59.288884
21	Kevin	Rodriguez	kevin.rodriguez@email.com	416-555-0121	t	f	2026-06-06 12:17:59.288884
22	Lauren	Lewis	lauren.lewis@email.com	\N	t	t	2026-06-06 12:17:59.288884
23	Brandon	Lee	brandon.lee@email.com	905-555-0123	f	f	2026-06-06 12:17:59.288884
24	Megan	Walker	megan.walker@email.com	\N	t	t	2026-06-06 12:17:59.288884
25	Jason	Hall	jason.hall@email.com	647-555-0125	t	f	2026-06-06 12:17:59.288884
26	Rachel	Allen	rachel.allen@email.com	\N	f	f	2026-06-06 12:17:59.288884
27	Justin	Young	justin.young@email.com	416-555-0127	t	t	2026-06-06 12:17:59.288884
28	Samuel	Hernandez	samuel.hernandez@email.com	\N	t	t	2026-06-06 12:17:59.288884
29	Brittany	King	brittany.king@email.com	905-555-0129	f	f	2026-06-06 12:17:59.288884
30	Benjamin	Wright	benjamin.wright@email.com	\N	t	t	2026-06-06 12:17:59.288884
31	Alexander	Lopez	alexander.lopez@email.com	647-555-0131	t	f	2026-06-06 12:17:59.288884
32	Kayla	Hill	kayla.hill@email.com	\N	t	t	2026-06-06 12:17:59.288884
33	Nathan	Scott	nathan.scott@email.com	416-555-0133	f	f	2026-06-06 12:17:59.288884
34	Victoria	Green	victoria.green@email.com	\N	t	t	2026-06-06 12:17:59.288884
35	Zachary	Adams	zachary.adams@email.com	905-555-0135	t	f	2026-06-06 12:17:59.288884
\.


--
-- TOC entry 3886 (class 0 OID 16656)
-- Dependencies: 221
-- Data for Name: dining_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dining_tables (table_number, table_type, is_active, min_capacity, max_capacity) FROM stdin;
1	small	t	1	4
2	small	t	1	4
3	small	t	1	4
4	small	t	1	4
5	small	t	1	4
6	small	t	1	4
7	small	t	1	4
8	small	t	1	4
9	small	t	1	4
10	small	t	1	4
11	small	t	1	4
12	small	t	1	4
13	small	t	1	4
14	small	t	1	4
15	small	t	1	4
16	small	t	1	4
17	small	t	1	4
18	small	t	1	4
19	small	t	1	4
20	small	t	1	4
21	medium	t	5	8
22	medium	t	5	8
23	medium	t	5	8
24	medium	t	5	8
25	medium	t	5	8
26	medium	t	5	8
27	medium	t	5	8
28	medium	t	5	8
29	large	t	9	12
30	large	t	9	12
\.


--
-- TOC entry 3888 (class 0 OID 16672)
-- Dependencies: 223
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservations (id, customer_id, start_time, party_size, table_number, status, created_at, occasion) FROM stdin;
44	14	2026-06-11 17:00:00	3	8	confirmed	2026-06-06 12:17:59.288884	\N
45	15	2026-06-11 17:00:00	4	9	confirmed	2026-06-06 12:17:59.288884	business
46	16	2026-06-11 17:00:00	2	10	confirmed	2026-06-06 12:17:59.288884	\N
47	17	2026-06-11 17:00:00	3	11	confirmed	2026-06-06 12:17:59.288884	\N
48	18	2026-06-11 17:00:00	4	12	confirmed	2026-06-06 12:17:59.288884	celebration
49	19	2026-06-11 17:00:00	2	13	confirmed	2026-06-06 12:17:59.288884	\N
50	20	2026-06-11 17:00:00	3	14	confirmed	2026-06-06 12:17:59.288884	\N
51	21	2026-06-11 17:00:00	4	15	confirmed	2026-06-06 12:17:59.288884	date night
52	22	2026-06-11 17:00:00	2	16	confirmed	2026-06-06 12:17:59.288884	\N
53	23	2026-06-11 17:00:00	3	17	confirmed	2026-06-06 12:17:59.288884	\N
54	24	2026-06-11 17:00:00	4	18	confirmed	2026-06-06 12:17:59.288884	\N
55	25	2026-06-11 17:00:00	2	19	confirmed	2026-06-06 12:17:59.288884	\N
56	26	2026-06-11 17:00:00	3	20	confirmed	2026-06-06 12:17:59.288884	family
57	27	2026-06-11 19:00:00	2	1	confirmed	2026-06-06 12:17:59.288884	\N
58	28	2026-06-11 19:00:00	3	2	confirmed	2026-06-06 12:17:59.288884	\N
59	29	2026-06-11 19:00:00	4	3	confirmed	2026-06-06 12:17:59.288884	\N
60	30	2026-06-11 19:00:00	2	4	confirmed	2026-06-06 12:17:59.288884	\N
61	31	2026-06-11 19:00:00	3	5	confirmed	2026-06-06 12:17:59.288884	\N
62	32	2026-06-11 19:00:00	4	6	confirmed	2026-06-06 12:17:59.288884	\N
63	33	2026-06-11 19:00:00	2	7	confirmed	2026-06-06 12:17:59.288884	\N
64	34	2026-06-11 19:00:00	3	8	confirmed	2026-06-06 12:17:59.288884	\N
65	1	2026-06-11 19:00:00	4	9	confirmed	2026-06-06 12:17:59.288884	\N
66	2	2026-06-11 19:00:00	2	10	confirmed	2026-06-06 12:17:59.288884	\N
67	3	2026-06-11 19:00:00	3	11	confirmed	2026-06-06 12:17:59.288884	\N
68	4	2026-06-11 19:00:00	4	12	confirmed	2026-06-06 12:17:59.288884	\N
69	5	2026-06-11 19:00:00	2	13	confirmed	2026-06-06 12:17:59.288884	\N
70	6	2026-06-11 19:00:00	3	14	confirmed	2026-06-06 12:17:59.288884	\N
71	7	2026-06-11 19:00:00	4	15	confirmed	2026-06-06 12:17:59.288884	\N
72	8	2026-06-11 19:00:00	2	16	confirmed	2026-06-06 12:17:59.288884	\N
73	9	2026-06-11 19:00:00	3	17	confirmed	2026-06-06 12:17:59.288884	\N
74	10	2026-06-11 19:00:00	4	18	confirmed	2026-06-06 12:17:59.288884	\N
75	11	2026-06-11 19:00:00	2	19	confirmed	2026-06-06 12:17:59.288884	\N
76	12	2026-06-11 19:00:00	3	20	confirmed	2026-06-06 12:17:59.288884	\N
77	13	2026-06-11 21:00:00	4	1	confirmed	2026-06-06 12:17:59.288884	\N
78	14	2026-06-11 21:00:00	2	2	confirmed	2026-06-06 12:17:59.288884	\N
79	15	2026-06-11 21:00:00	3	3	confirmed	2026-06-06 12:17:59.288884	\N
80	16	2026-06-11 21:00:00	4	4	confirmed	2026-06-06 12:17:59.288884	\N
81	17	2026-06-11 21:00:00	2	5	confirmed	2026-06-06 12:17:59.288884	\N
82	18	2026-06-11 21:00:00	3	6	confirmed	2026-06-06 12:17:59.288884	\N
83	19	2026-06-11 21:00:00	4	7	confirmed	2026-06-06 12:17:59.288884	\N
84	20	2026-06-11 21:00:00	2	8	confirmed	2026-06-06 12:17:59.288884	\N
85	21	2026-06-11 21:00:00	3	9	confirmed	2026-06-06 12:17:59.288884	\N
86	22	2026-06-11 21:00:00	4	10	confirmed	2026-06-06 12:17:59.288884	\N
87	23	2026-06-11 21:00:00	2	11	confirmed	2026-06-06 12:17:59.288884	\N
88	24	2026-06-11 21:00:00	3	12	confirmed	2026-06-06 12:17:59.288884	\N
89	25	2026-06-11 21:00:00	4	13	confirmed	2026-06-06 12:17:59.288884	\N
90	26	2026-06-11 21:00:00	2	14	confirmed	2026-06-06 12:17:59.288884	\N
91	27	2026-06-11 21:00:00	3	15	confirmed	2026-06-06 12:17:59.288884	\N
92	28	2026-06-11 21:00:00	4	16	confirmed	2026-06-06 12:17:59.288884	\N
93	29	2026-06-11 21:00:00	2	17	confirmed	2026-06-06 12:17:59.288884	\N
94	30	2026-06-11 21:00:00	3	18	confirmed	2026-06-06 12:17:59.288884	\N
95	31	2026-06-11 21:00:00	4	19	confirmed	2026-06-06 12:17:59.288884	\N
96	32	2026-06-11 21:00:00	2	20	confirmed	2026-06-06 12:17:59.288884	\N
1	1	2026-06-10 17:00:00	10	29	confirmed	2026-06-06 12:17:59.288884	birthday
2	2	2026-06-10 19:00:00	10	29	confirmed	2026-06-06 12:17:59.288884	\N
3	3	2026-06-10 21:00:00	11	29	confirmed	2026-06-06 12:17:59.288884	\N
4	4	2026-06-10 17:00:00	10	30	confirmed	2026-06-06 12:17:59.288884	\N
5	5	2026-06-10 19:00:00	10	30	confirmed	2026-06-06 12:17:59.288884	\N
6	6	2026-06-10 21:00:00	11	30	confirmed	2026-06-06 12:17:59.288884	\N
7	7	2026-06-10 17:00:00	6	21	confirmed	2026-06-06 12:17:59.288884	\N
8	8	2026-06-10 17:00:00	5	22	confirmed	2026-06-06 12:17:59.288884	anniversary
9	9	2026-06-10 17:00:00	7	23	confirmed	2026-06-06 12:17:59.288884	\N
10	10	2026-06-10 17:00:00	8	24	confirmed	2026-06-06 12:17:59.288884	business
11	11	2026-06-10 17:00:00	5	25	confirmed	2026-06-06 12:17:59.288884	\N
12	12	2026-06-10 17:00:00	6	26	confirmed	2026-06-06 12:17:59.288884	celebration
13	13	2026-06-10 17:00:00	7	27	confirmed	2026-06-06 12:17:59.288884	\N
14	14	2026-06-10 17:00:00	8	28	confirmed	2026-06-06 12:17:59.288884	\N
15	15	2026-06-10 19:00:00	6	21	confirmed	2026-06-06 12:17:59.288884	\N
16	16	2026-06-10 19:00:00	5	22	confirmed	2026-06-06 12:17:59.288884	\N
17	17	2026-06-10 19:00:00	7	23	confirmed	2026-06-06 12:17:59.288884	\N
18	18	2026-06-10 19:00:00	8	24	confirmed	2026-06-06 12:17:59.288884	\N
19	19	2026-06-10 19:00:00	5	25	confirmed	2026-06-06 12:17:59.288884	\N
20	20	2026-06-10 19:00:00	6	26	confirmed	2026-06-06 12:17:59.288884	\N
21	21	2026-06-10 19:00:00	7	27	confirmed	2026-06-06 12:17:59.288884	\N
22	22	2026-06-10 19:00:00	8	28	confirmed	2026-06-06 12:17:59.288884	\N
23	23	2026-06-10 21:00:00	6	21	confirmed	2026-06-06 12:17:59.288884	\N
24	24	2026-06-10 21:00:00	5	22	confirmed	2026-06-06 12:17:59.288884	\N
25	25	2026-06-10 21:00:00	7	23	confirmed	2026-06-06 12:17:59.288884	\N
26	26	2026-06-10 21:00:00	8	24	confirmed	2026-06-06 12:17:59.288884	\N
27	27	2026-06-10 21:00:00	5	25	confirmed	2026-06-06 12:17:59.288884	\N
28	28	2026-06-10 21:00:00	6	26	confirmed	2026-06-06 12:17:59.288884	\N
29	29	2026-06-10 21:00:00	7	27	confirmed	2026-06-06 12:17:59.288884	\N
30	30	2026-06-10 21:00:00	8	28	confirmed	2026-06-06 12:17:59.288884	date night
31	1	2026-06-11 17:00:00	10	29	confirmed	2026-06-06 12:17:59.288884	\N
32	2	2026-06-11 19:00:00	10	29	confirmed	2026-06-06 12:17:59.288884	\N
33	3	2026-06-11 21:00:00	11	29	confirmed	2026-06-06 12:17:59.288884	\N
34	4	2026-06-11 17:00:00	11	30	confirmed	2026-06-06 12:17:59.288884	family gathering
35	5	2026-06-11 19:00:00	10	30	confirmed	2026-06-06 12:17:59.288884	\N
36	6	2026-06-11 21:00:00	11	30	confirmed	2026-06-06 12:17:59.288884	\N
37	7	2026-06-11 17:00:00	2	1	confirmed	2026-06-06 12:17:59.288884	\N
38	8	2026-06-11 17:00:00	3	2	confirmed	2026-06-06 12:17:59.288884	\N
39	9	2026-06-11 17:00:00	4	3	confirmed	2026-06-06 12:17:59.288884	birthday
40	10	2026-06-11 17:00:00	2	4	confirmed	2026-06-06 12:17:59.288884	\N
41	11	2026-06-11 17:00:00	3	5	confirmed	2026-06-06 12:17:59.288884	\N
42	12	2026-06-11 17:00:00	4	6	confirmed	2026-06-06 12:17:59.288884	anniversary
43	13	2026-06-11 17:00:00	2	7	confirmed	2026-06-06 12:17:59.288884	\N
\.


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 219
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 35, true);


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 222
-- Name: reservations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_id_seq', 96, true);


-- Completed on 2026-06-06 12:18:44 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict uXnfwFpDzykaQsU4HYNq64cwt9UxqxgBJOVMDx23Vum9zliVfUetiyCaBdTtj4Y


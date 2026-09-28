-- ==========================================================
-- Source (OLTP) Database Setup
-- Simulates day-to-day transactional order processing
-- ==========================================================

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_name TEXT,
    region TEXT,
    product TEXT,
    order_date DATE,
    amount NUMERIC
);

-- Seed 20,000 realistic sample orders across past 180 days
INSERT INTO orders (customer_name, region, product, order_date, amount)
SELECT
    'Customer_' || i,
    (ARRAY['North', 'South', 'East', 'West'])[floor(random() * 4 + 1)],
    (ARRAY['Laptop', 'Phone', 'Tablet', 'Monitor', 'Keyboard'])[floor(random() * 5 + 1)],
    CURRENT_DATE - (floor(random() * 180))::int,
    round((random() * 50000 + 500)::numeric, 2)
FROM generate_series(1, 20000) AS i;

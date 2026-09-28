-- ==========================================================
-- Data Warehouse Star Schema Setup
-- Dimension Tables (Context) + Fact Table (Numeric Measures)
-- ==========================================================

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_region CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;

-- 1. Date Dimension Table
CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    month INT,
    day INT
);

-- 2. Region Dimension Table
CREATE TABLE dim_region (
    region_key SERIAL PRIMARY KEY,
    region_name TEXT UNIQUE
);

-- 3. Product Dimension Table
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_name TEXT UNIQUE
);

-- 4. Central Fact Table
CREATE TABLE fact_sales (
    fact_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dim_date(date_key),
    region_key INT REFERENCES dim_region(region_key),
    product_key INT REFERENCES dim_product(product_key),
    amount NUMERIC
);

-- ==========================================================
-- Traditional Data Warehouse: OLAP-Style Analysis Queries
-- ==========================================================

-- 1. ROLL-UP: High-level aggregation (Total sales by region)
SELECT 
    r.region_name, 
    round(sum(f.amount), 2) AS total_sales
FROM fact_sales f
JOIN dim_region r ON f.region_key = r.region_key
GROUP BY r.region_name
ORDER BY total_sales DESC;

-- 2. DRILL-DOWN: Adding finer granularity (Total sales by region AND product)
SELECT 
    r.region_name, 
    p.product_name, 
    round(sum(f.amount), 2) AS total_sales
FROM fact_sales f
JOIN dim_region r ON f.region_key = r.region_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY r.region_name, p.product_name
ORDER BY r.region_name, total_sales DESC;

-- 3. SLICE: Filtering by a single dimension member (e.g. Month = 8, Year = 2026)
SELECT 
    p.product_name, 
    round(sum(f.amount), 2) AS total_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2026 AND d.month = 8
GROUP BY p.product_name
ORDER BY total_sales DESC;

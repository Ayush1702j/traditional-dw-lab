import psycopg2
from datetime import datetime

def run_etl():
    print(f"--- Batch ETL job started at {datetime.now()} ---")

    # STEP 1: EXTRACT from source (OLTP)
    source_conn = psycopg2.connect(
        host="localhost",
        port=5433,
        dbname="postgres",
        user="postgres",
        password="source123"
    )
    source_cur = source_conn.cursor()
    source_cur.execute("SELECT region, product, order_date, amount FROM orders;")
    rows = source_cur.fetchall()
    print(f"Extracted {len(rows)} rows from source database.")

    # Connect to Data Warehouse
    dw_conn = psycopg2.connect(
        host="localhost",
        port=5434,
        dbname="postgres",
        user="postgres",
        password="dw123"
    )
    dw_cur = dw_conn.cursor()

    inserted = 0
    for region, product, order_date, amount in rows:
        # STEP 2: TRANSFORM — look up or create dimension keys

        # Region Dimension
        dw_cur.execute("SELECT region_key FROM dim_region WHERE region_name = %s;", (region,))
        result = dw_cur.fetchone()
        if result:
            region_key = result[0]
        else:
            dw_cur.execute(
                "INSERT INTO dim_region (region_name) VALUES (%s) RETURNING region_key;",
                (region,)
            )
            region_key = dw_cur.fetchone()[0]

        # Product Dimension
        dw_cur.execute("SELECT product_key FROM dim_product WHERE product_name = %s;", (product,))
        result = dw_cur.fetchone()
        if result:
            product_key = result[0]
        else:
            dw_cur.execute(
                "INSERT INTO dim_product (product_name) VALUES (%s) RETURNING product_key;",
                (product,)
            )
            product_key = dw_cur.fetchone()[0]

        # Date Dimension
        dw_cur.execute("SELECT date_key FROM dim_date WHERE full_date = %s;", (order_date,))
        result = dw_cur.fetchone()
        if result:
            date_key = result[0]
        else:
            dw_cur.execute(
                """
                INSERT INTO dim_date (full_date, year, month, day)
                VALUES (%s, %s, %s, %s)
                RETURNING date_key;
                """,
                (order_date, order_date.year, order_date.month, order_date.day)
            )
            date_key = dw_cur.fetchone()[0]

        # STEP 3: LOAD into the central fact table
        dw_cur.execute(
            """
            INSERT INTO fact_sales (date_key, region_key, product_key, amount)
            VALUES (%s, %s, %s, %s);
            """,
            (date_key, region_key, product_key, amount)
        )
        inserted += 1

    dw_conn.commit()
    print(f"Loaded {inserted} rows into fact_sales.")
    print(f"--- Batch ETL job finished at {datetime.now()} ---")

    source_cur.close()
    source_conn.close()
    dw_cur.close()
    dw_conn.close()

if __name__ == "__main__":
    run_etl()

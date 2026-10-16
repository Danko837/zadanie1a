-- Spustite po pripojení na databázu retail

CREATE TABLE retail_sales (
    invoice_no   VARCHAR(20),
    stock_code   VARCHAR(50),
    description  TEXT,
    quantity     INTEGER,
    invoice_date TIMESTAMP,
    unit_price   NUMERIC(10, 2),
    customer_id  INTEGER,
    country      VARCHAR(100)
);

-- Kontrola po importe cez pgAdmin (Import/Export Data)
SELECT *
FROM retail_sales;
/*2*/
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    quantity * unit_price AS revenue,
    SUM(quantity * unit_price) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;
/*3*/
SELECT
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER (
            PARTITION BY stock_code, country
            ORDER BY invoice_date
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ),
        2
    ) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;
/*4*/
WITH orders AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        invoice_date::date AS invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
next_orders AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date) OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date
        ) AS next_invoice_date
    FROM orders
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date - invoice_date AS days_to_next_invoice
FROM next_orders
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

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

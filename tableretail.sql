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

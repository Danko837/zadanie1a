-- Active: 1790164021180@@127.0.0.1@5432@superstore@public
-- Active: 1790164021180@@127.0.0.1@5432@superstore
CREATE DATABASE superstore;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;


CREATE TABLE customers (
    customer_id   VARCHAR(20)  PRIMARY KEY,
    customer_name VARCHAR(100),
    segment       VARCHAR(50),
    country       VARCHAR(50),
    region        VARCHAR(50)
);


CREATE TABLE products (
    product_id   VARCHAR(20)  PRIMARY KEY,
    category     VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);


CREATE TABLE orders (
    order_id    VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers (customer_id),
    product_id  VARCHAR(20) REFERENCES products (product_id),
    order_date  DATE,
    ship_date   DATE,
    sales       NUMERIC(12,2),
    quantity    INTEGER,
    discount    NUMERIC(5,2),
    profit      NUMERIC(12,2)
);

SELECT * FROM customers;
SELECT orders.order_id,customers.customer_name,orders.sales  FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id WHERE sales>500 

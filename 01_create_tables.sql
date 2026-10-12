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
/*2*/
SELECT orders.order_id,customers.customer_name,orders.sales  FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id WHERE sales>500; 
/*3*/
SELECT orders.order_id,customers.customer_name,products.category,orders.sales  FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id INNER JOIN products ON products.product_id = orders.product_id;
/*4*/
SELECT customers.region, SUM(orders.sales) FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;
/*5*/
SELECT products.product_name, SUM(orders.sales) AS SPOLU FROM products INNER JOIN orders ON orders.product_id = products.product_id GROUP BY products.product_name;
/*6*/
SELECT customers.customer_name, orders.order_id, orders.sales FROM customers FULL OUTER JOIN orders ON orders.customer_id = customers.customer_id;
/*7*/
SELECT customers.region, SUM(orders.sales) AS celkovy_predaj FROM orders INNER JOIN customers ON customers.customer_id = orders.customer_id GROUP BY customers.region;
/*8*/
SELECT customers.customer_name, COUNT(orders.order_id) AS pocet_objednavok FROM customers LEFT JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.customer_id, customers.customer_name;
/*9*/
SELECT products.category, AVG(orders.discount) AS priemerna_zlava FROM products INNER JOIN orders ON orders.product_id = products.product_id GROUP BY products.category;
/*10*/
SELECT customers.customer_name, SUM(orders.sales) AS celkovy_nakup FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.customer_id, customers.customer_name HAVING SUM(orders.sales) > 2000;
/*11*/
SELECT customers.region, SUM(orders.sales) AS celkovy_predaj, AVG(orders.discount) AS priemerna_zlava, COUNT(orders.order_id) AS pocet_objednavok FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;
/*11*/
SELECT customers.region, SUM(orders.sales) AS celkovy_predaj, AVG(orders.discount) AS priemerna_zlava, COUNT(orders.order_id) AS pocet_objednavok FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;;
/*12*/
SELECT customers.region, SUM(CASE WHEN orders.sales > 1000 THEN 1 ELSE 0 END) AS high_value, SUM(CASE WHEN orders.sales <= 1000 THEN 1 ELSE 0 END) AS low_value FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.region;
/*13*/
SELECT customers.customer_name, SUM(orders.sales) AS celkovy_predaj, AVG(orders.discount) AS priemerna_zlava, COUNT(orders.order_id) AS pocet_objednavok, CASE WHEN SUM(orders.sales) > 2500 THEN 'VIP' ELSE 'REGULAR' END AS typ_zakaznika FROM customers INNER JOIN orders ON orders.customer_id = customers.customer_id GROUP BY customers.customer_id, customers.customer_name ORDER BY celkovy_predaj DESC;
/*seminar3*/
/*1*/
CREATE VIEW high_value_customers AS
SELECT
c.customer_id,
c.customer_name,
SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
c.customer_id,
c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT * FROM high_value_customers; --??????
/*2*/
CREATE VIEW regional_monthly_sales AS
SELECT
c.region,
DATE_TRUNC('month', o.order_date) AS month,
SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o
on c.customer_id = o.customer_id
GROUP BY
c.region,
DATE_TRUNC('month', o.order_date);

/*3*/
CREATE VIEW analyst_orders AS
SELECT
order_id,
customer_id,
product_id,
sales,
quantity,
discount
FROM orders;


SELECT *
FROM analyst_orders;

/*4*/
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);

-- Zobrazenie
SELECT *
FROM orders
WHERE customer_id = 'C001';

/*5*/
CREATE INDEX idx_orders_order_date
ON orders (order_date);

-- predaj mesiac
SELECT
DATE_TRUNC('month', order_date) AS mesiac,
SUM(sales) AS celkovy_predaj
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY mesiac ASC;
/*6*/
CREATE INDEX idx_orders_region_category
ON orders (customer_id, order_date);

-- objednavky west
SELECT
o.order_id,
o.customer_id,
o.product_id,
o.order_date,
o.ship_date,
o.sales,
o.quantity,
o.discount,
o.profit
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE c.region = 'West'
AND o.order_date >= '2024-01-01';
/*7*/
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';

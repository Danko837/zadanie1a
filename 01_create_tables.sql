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
/*seminar4_1d*/
/*1*/
WITH ranked AS (
    SELECT
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date DESC
        ) AS rn
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
)
SELECT
    customer_name,
    order_id,
    order_date
FROM ranked
WHERE rn <= 2
ORDER BY customer_name, rn;
/*2*/
WITH customer_profit AS (
    SELECT
        c.region,
        c.customer_name,
        SUM(o.profit) AS total_profit
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.region, c.customer_id, c.customer_name
)
SELECT
    region,
    customer_name,
    total_profit,
    RANK()       OVER (PARTITION BY region ORDER BY total_profit DESC) AS profit_rank,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY total_profit DESC) AS profit_dense_rank
FROM customer_profit
ORDER BY region, profit_rank;
/*3*/
WITH customer_sales AS (
    SELECT
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM customer_sales
ORDER BY total_sales DESC;
/*4*/
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    monthly_sales,
    LAG(monthly_sales, 1)  OVER (ORDER BY month) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month) AS next_month_sales
FROM monthly
ORDER BY month;
/*5*/
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        product_sales * 100.0 /
        SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
FROM product_sales
ORDER BY category, product_name;
/*6*/
WITH order_dates AS (
    SELECT
        o.customer_id,
        c.customer_name,
        MAX(o.order_date) OVER (PARTITION BY o.customer_id) AS last_order_date,
        MAX(o.order_date) OVER ()                           AS latest_order_date
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
)
SELECT DISTINCT
    customer_id,
    customer_name,
    last_order_date
FROM order_dates
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date DESC;

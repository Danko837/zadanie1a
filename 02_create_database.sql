
CREATE DATABASE datacraftinglab_db;

DROP TABLE IF EXISTS flourmills_sales;

CREATE TABLE flourmills_sales (
    sales_id          INTEGER PRIMARY KEY,
    sale_date         DATE,
    region            VARCHAR(100),
    state             VARCHAR(100),
    product_category  VARCHAR(100),
    product_name      VARCHAR(150),
    customer_type     VARCHAR(100),
    customer_id       INTEGER,
    quantity_sold     INTEGER,
    unit_price        NUMERIC(12,2),
    discount_rate     INTEGER,
    payment_method    VARCHAR(100),
    sales_rep         VARCHAR(150),
    warehouse         VARCHAR(100),
    delivery_status   VARCHAR(100),
    order_channel     VARCHAR(100),
    batch_number      INTEGER,
    production_date   DATE,
    total_amount      NUMERIC(14,2)
);



SELECT * FROM flourmills_sales;


SELECT COUNT(*) AS pocet_riadkov FROM flourmills_sales;


SELECT MIN(sale_date) AS prvy_predaj,
       MAX(sale_date) AS posledny_predaj
FROM flourmills_sales;


SELECT COUNT(*) AS chybajuce_hodnoty
FROM flourmills_sales
WHERE sale_date IS NULL
   OR product_name IS NULL
   OR total_amount IS NULL;
/*1*/
SELECT product_name,
       total_amount
FROM flourmills_sales
WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);


SELECT COUNT(*) AS pocet_transakcii
FROM flourmills_sales
WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);
/*2*/
SELECT *
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;
/*3*/
SELECT product_name,
       total_amount,
       (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount
FROM flourmills_sales;
/*4*/
SELECT product_name,
       total_amount,
       total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) AS amount_share
FROM flourmills_sales;
/*5*/
SELECT month, monthly_sales
FROM (
    SELECT EXTRACT(MONTH FROM sale_date) AS month,
           SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY EXTRACT(MONTH FROM sale_date)
) AS monthly
ORDER BY monthly_sales DESC;
/*6*/
SELECT product_category, total_sales
FROM (
    SELECT product_category,
           SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS cat_sales
WHERE total_sales > 50000000
ORDER BY total_sales DESC;
/*7*/
SELECT f.product_name,
       f.product_category,
       f.total_amount
FROM flourmills_sales AS f
WHERE f.total_amount > (
    SELECT AVG(s.total_amount)
    FROM flourmills_sales AS s
    WHERE s.product_category = f.product_category
);
/*8*/
SELECT f.product_name,
       f.region,
       f.total_amount,
       (SELECT MIN(s.total_amount)
        FROM flourmills_sales AS s
        WHERE s.region = f.region) AS region_min_amount
FROM flourmills_sales AS f;
/*9*/
SELECT f.product_name,
       f.sale_date,
       f.total_amount
FROM flourmills_sales AS f
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS s
    WHERE s.product_name = f.product_name
    GROUP BY s.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM s.sale_date)) > 1
);
/*10*/
SELECT f.product_category,
       f.product_name,
       f.total_amount
FROM flourmills_sales AS f
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS s
    WHERE s.product_category = f.product_category
      AND s.total_amount > 200000
);

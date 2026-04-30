-- =========================================
-- E-COMMERCE SALES ANALYSIS (PostgreSQL)
-- Author: Prem
-- =========================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_name, city, country) VALUES
('Alice', 'New York', 'USA'),
('Bob', 'London', 'UK'),
('Charlie', 'Mumbai', 'India');

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 800),
('Phone', 'Electronics', 500),
('Table', 'Furniture', 200);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2024-01-10'),
(2, '2024-02-15'),
(3, '2024-03-20');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 2, 1),
(3, 3, 3);


--Total Revenue
SELECT 
    SUM(p.price * oi.quantity) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

--Revenue by Customer
SELECT 
    c.customer_name,
    SUM(p.price * oi.quantity) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY revenue DESC;

--Top Selling Product
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

--Monthly Sales Trend
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(p.price * oi.quantity) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

--Category wise revenue
SELECT p.category, SUM(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

--Find top customers using clean logic using CTE WITH
WITH customer_revenue AS(
		SELECT
			c.customer_id,
			c.customer_name,
			SUM(p.price * oi.quantity) AS total_spent
		FROM customers c
		JOIN orders o ON c.customer_id = o.customer_id
   	    JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
		GROUP BY c.customer_id, c.customer_name
)
SELECT * FROM customer_revenue
ORDER  BY total_spent DESC;

--Rank customers by spending using Window Function
SELECT c.customer_name,  SUM(p.price *oi.quantity) AS total_spent, RANK() OVER(ORDER BY SUM(p.price *oi.quantity) DESC) AS rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;

--Top product per category
SELECT * FROM(
		SELECT p.category, p.product_name, SUM(oi.quantity) AS total_sold,
			RANK() OVER(PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rank
		FROM order_items oi
    	JOIN products p ON oi.product_id = p.product_id
    	GROUP BY p.category, p.product_name
) ranked
WHERE rank = 1;


--BUSINESS QUERIES:
--1. Who are our top customers?
WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(p.price * oi.quantity) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_revenue
ORDER BY total_spent DESC
LIMIT 5;

--2. What are best selling Products?
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;

--3. Monthly revenue trend.
SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(p.price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

--4. Which category generates most Revenue?
SELECT 
    p.category,
    SUM(p.price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

--5. Customer ranking (using windows function)
SELECT 
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.price * oi.quantity) DESC) AS rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;
 

--KEY INSIGHTS FROM THE DATA:
--1) The top customer generated $1800 in total revenue.
--2) The 'Electronics' category generates the most revenue followed by the 'Furniture' category.
--3) The top 3 best selling products are 'Phone' & 'Table' followed by 'Laptop'.
	
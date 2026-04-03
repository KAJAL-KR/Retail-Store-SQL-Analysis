-- ============================================
-- 📊 Retail Store SQL Analysis Project
-- Author: Kajal Kumari
-- ============================================

-- ================================
-- 🔹 LEVEL 1: BASIC QUERIES
-- ================================

-- Customer emails for marketing
SELECT name, email FROM customers;

-- View all products
SELECT * FROM products;

-- Unique product categories
SELECT DISTINCT category FROM products;

-- High-priced products
SELECT name, category, price 
FROM products 
WHERE price > 1000;

-- Mid-range products
SELECT name, category, price 
FROM products 
WHERE price BETWEEN 2000 AND 5000;

-- Specific customers
SELECT * 
FROM customers 
WHERE customer_id IN (1,2,3,4,5,6,7,8);

-- Customers starting with 'A'
SELECT customer_id, name, email 
FROM customers 
WHERE name LIKE 'A%';

-- Electronics under ₹3000
SELECT name, price 
FROM products 
WHERE category = 'Electronics' AND price < 3000;

-- Sort by price
SELECT name, price 
FROM products 
ORDER BY price DESC;

-- Sort by price + name
SELECT name, price 
FROM products 
ORDER BY price DESC, name ASC;


-- ================================
-- 🔹 LEVEL 2: FILTERING & FORMATTING
-- ================================

-- Orders with missing customers
SELECT order_id, order_date, status, total_amount 
FROM orders 
WHERE customer_id IS NULL;

-- Column aliases
SELECT name AS 'Customer Name', email AS 'Email Address' 
FROM customers;

-- Line total per order item
SELECT order_item_id, order_id, product_id, quantity, item_price,
       quantity * item_price AS line_total 
FROM order_items;

-- Combine name + phone
SELECT CONCAT(name, ' - ', COALESCE(phone, 'No Phone')) AS customer_contact 
FROM customers;

-- Extract date
SELECT order_id, DATE(order_date) AS order_date_only, status, total_amount 
FROM orders;

-- Out of stock products
SELECT product_id, name, category 
FROM products 
WHERE stock_quantity = 0;


-- ================================
-- 🔹 LEVEL 3: AGGREGATIONS
-- ================================

-- Total orders
SELECT COUNT(*) AS total_orders FROM orders;

-- Total revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- Average order value
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value FROM orders;

-- Active customers
SELECT COUNT(DISTINCT customer_id) AS active_customers 
FROM orders;

-- Orders per customer
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC;

-- Customer spending
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC;

-- Products sold per category
SELECT p.category, COUNT(oi.order_item_id) AS items_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY items_sold DESC;

-- Avg price per category
SELECT category, ROUND(AVG(price),2) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;

-- Orders per day
SELECT DATE(order_date) AS order_day, COUNT(*) AS orders_count
FROM orders
GROUP BY order_day
ORDER BY order_day;

-- Revenue per payment method
SELECT method, COUNT(*) AS transactions,
       SUM(amount_paid) AS total_collected
FROM payments
GROUP BY method
ORDER BY total_collected DESC;


-- ================================
-- 🔹 LEVEL 4: JOINS
-- ================================

-- Orders with customer names
SELECT o.order_id, c.name, o.order_date, o.status, o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Sold products
SELECT DISTINCT p.product_id, p.name, p.category
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id;

-- Orders with payment details
SELECT o.order_id, o.order_date, o.total_amount,
       p.method, p.amount_paid
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id;

-- Customers with orders
SELECT c.customer_id, c.name, o.order_id, o.order_date, o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Products with order quantity
SELECT p.product_id, p.name, p.category,
       oi.quantity, oi.order_id
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id;

-- All payments (even unmatched)
SELECT p.payment_id, p.amount_paid, p.method,
       o.order_id, o.status
FROM orders o
RIGHT JOIN payments p ON o.order_id = p.order_id;

-- Full customer transaction view
SELECT c.name, o.order_id, o.order_date, o.total_amount,
       p.method, p.amount_paid
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN payments p ON o.order_id = p.order_id;


-- ================================
-- 🔹 LEVEL 5: SUBQUERIES
-- ================================

-- Above average priced products
SELECT name, category, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Customers with orders
SELECT customer_id, name
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM orders
);

-- High value orders per customer
SELECT o.order_id, o.customer_id, o.total_amount
FROM orders o
WHERE o.total_amount > (
    SELECT AVG(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- Customers without orders
SELECT customer_id, name, email
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

-- Products never ordered
SELECT product_id, name, category, price
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM order_items
);

-- Highest order per customer
SELECT customer_id, MAX(total_amount) AS highest_order_value
FROM orders
GROUP BY customer_id
ORDER BY highest_order_value DESC;

-- Highest order with names
SELECT c.name, sub.customer_id, sub.highest_order_value
FROM (
    SELECT customer_id, MAX(total_amount) AS highest_order_value
    FROM orders
    GROUP BY customer_id
) sub
JOIN customers c ON sub.customer_id = c.customer_id
ORDER BY sub.highest_order_value DESC;


-- ================================
-- 🔹 LEVEL 6: SET OPERATIONS
-- ================================

-- Customers who ordered OR reviewed
SELECT DISTINCT customer_id FROM orders
UNION
SELECT DISTINCT customer_id FROM product_reviews;

-- Customers who ordered AND reviewed
SELECT customer_id
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders)
AND customer_id IN (SELECT customer_id FROM product_reviews);
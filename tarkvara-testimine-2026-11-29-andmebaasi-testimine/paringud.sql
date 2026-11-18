-- Jegor Onoprijuk · TA-24B · Andmebaasi testimine (shop-database.sql)
.headers on
.mode column
.print '=== R1: kliendil puudub e-post ==='
SELECT id, name, email FROM customers WHERE email IS NULL OR TRIM(email) = '';
.print ''
.print '=== R2: tellimus viitab olematule kliendile ==='
SELECT o.id AS order_id, o.customer_id, o.status, o.total FROM orders o LEFT JOIN customers c ON c.id = o.customer_id WHERE c.id IS NULL;
.print ''
.print '=== R3: tellimuse rea kogus < 1 ==='
SELECT id, order_id, product_id, quantity, unit_price FROM order_items WHERE quantity IS NULL OR quantity < 1;
.print ''
.print '=== R4: toote hind <= 0 ==='
SELECT id, name, price, active FROM products WHERE price IS NULL OR price <= 0;
.print ''
.print '=== R5: lubamatu staatus ==='
SELECT id, customer_id, status FROM orders WHERE status IS NULL OR status NOT IN ('NEW','PAID','SHIPPED','CANCELLED');
.print ''
.print '=== R6: tellimus tulevikus ==='
SELECT id, customer_id, created_at FROM orders WHERE created_at > datetime('now');
.print ''
.print '=== R7 (valikuline): tellimuse summa != ridade summa (ROUND 2) ==='
SELECT o.id AS order_id, o.total, ROUND(SUM(i.quantity * i.unit_price), 2) AS items_sum
FROM orders o JOIN order_items i ON i.order_id = o.id
GROUP BY o.id, o.total
HAVING o.total <> ROUND(SUM(i.quantity * i.unit_price), 2);
.print ''
.print '=== R7 ilma ROUND-ita (tellimus 106 jt) ==='
SELECT o.id AS order_id, o.total, SUM(i.quantity * i.unit_price) AS items_sum_raw,
       printf('%.17g', SUM(i.quantity * i.unit_price)) AS raw_17,
       (o.total = SUM(i.quantity * i.unit_price)) AS equal_without_round
FROM orders o JOIN order_items i ON i.order_id = o.id
GROUP BY o.id, o.total ORDER BY o.id;
.print ''
.print '=== JOIN vs LEFT JOIN (orders x customers) ==='
SELECT 'INNER JOIN' AS paring, COUNT(*) AS ridu FROM orders o JOIN customers c ON c.id = o.customer_id
UNION ALL
SELECT 'LEFT JOIN', COUNT(*) FROM orders o LEFT JOIN customers c ON c.id = o.customer_id;
.print ''
SELECT o.id AS order_id, o.customer_id, c.name FROM orders o LEFT JOIN customers c ON c.id = o.customer_id ORDER BY o.id;

-- ============================================================
-- Performance demo: populate pg_stat_statements with
-- realistic slow queries (seq scans on large tables)
-- ============================================================

-- Ensure extension is active
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Slow query 1: Full table scan on orders (no index on user_id)
-- Run multiple times to build up stats
DO $$
DECLARE i int;
BEGIN
    FOR i IN 1..15 LOOP
        PERFORM COUNT(*) FROM orders WHERE user_id = (i % 20) + 2;
        PERFORM * FROM orders o
            JOIN order_items oi ON oi.order_id = o.id
            JOIN products p ON p.id = oi.product_id
            WHERE o.status = 'delivered'
            ORDER BY o.created_at DESC;
    END LOOP;
END$$;

-- Slow query 2: Complex aggregation without index
DO $$
DECLARE i int;
BEGIN
    FOR i IN 1..10 LOOP
        PERFORM
            u.name,
            COUNT(o.id) AS order_count,
            SUM(o.total) AS total_spent,
            AVG(o.total) AS avg_order
        FROM users u
        LEFT JOIN orders o ON o.user_id = u.id
        LEFT JOIN payments p ON p.order_id = o.id
        WHERE p.status = 'completed'
        GROUP BY u.id, u.name
        ORDER BY total_spent DESC NULLS LAST;
    END LOOP;
END$$;

-- Slow query 3: Search without index
DO $$
DECLARE i int;
BEGIN
    FOR i IN 1..20 LOOP
        PERFORM * FROM products
        WHERE name ILIKE '%' || (ARRAY['phone','book','laptop','shoe','jacket'])[ceil(random()*5)::int] || '%'
           OR description ILIKE '%premium%';
    END LOOP;
END$$;

-- Slow query 4: Notifications full scan
DO $$
DECLARE i int;
BEGIN
    FOR i IN 1..8 LOOP
        PERFORM COUNT(*) FROM notifications WHERE is_read = false;
        PERFORM * FROM notifications
            WHERE type = 'order_shipped'
            AND sent_at > NOW() - INTERVAL '30 days'
            ORDER BY sent_at DESC;
    END LOOP;
END$$;

-- Slow query 5: Revenue report (expensive join)
DO $$
DECLARE i int;
BEGIN
    FOR i IN 1..5 LOOP
        PERFORM
            c.name AS category,
            COUNT(DISTINCT o.id) AS orders,
            SUM(oi.quantity * oi.unit_price) AS revenue
        FROM categories c
        JOIN products p ON p.category_id = c.id
        JOIN order_items oi ON oi.product_id = p.id
        JOIN orders o ON o.id = oi.order_id
        WHERE o.status != 'cancelled'
        GROUP BY c.id, c.name
        ORDER BY revenue DESC;
    END LOOP;
END$$;

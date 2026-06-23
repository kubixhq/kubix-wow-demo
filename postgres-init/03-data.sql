-- ============================================================
-- Demo data — realistic e-commerce dataset
-- ============================================================

-- Categories
INSERT INTO categories (name, slug) VALUES
    ('Electronics',    'electronics'),
    ('Clothing',       'clothing'),
    ('Books',          'books'),
    ('Home & Garden',  'home-garden'),
    ('Sports',         'sports');

INSERT INTO categories (name, slug, parent_id) VALUES
    ('Smartphones',    'smartphones',    1),
    ('Laptops',        'laptops',        1),
    ('Audio',          'audio',          1),
    ('Men',            'men',            2),
    ('Women',          'women',          2),
    ('Fiction',        'fiction',        3),
    ('Technical',      'technical',      3),
    ('Running',        'running',        5),
    ('Cycling',        'cycling',        5);

-- Users (50 users)
INSERT INTO users (email, name, role, created_at) VALUES
    ('admin@kubix.dev',       'Admin User',         'admin',    NOW() - INTERVAL '180 days'),
    ('alice@example.com',     'Alice Johnson',      'customer', NOW() - INTERVAL '120 days'),
    ('bob@example.com',       'Bob Smith',          'customer', NOW() - INTERVAL '100 days'),
    ('carol@example.com',     'Carol Williams',     'customer', NOW() - INTERVAL '95 days'),
    ('dave@example.com',      'Dave Brown',         'customer', NOW() - INTERVAL '90 days'),
    ('eve@example.com',       'Eve Davis',          'customer', NOW() - INTERVAL '85 days'),
    ('frank@example.com',     'Frank Miller',       'customer', NOW() - INTERVAL '80 days'),
    ('grace@example.com',     'Grace Wilson',       'customer', NOW() - INTERVAL '75 days'),
    ('henry@example.com',     'Henry Moore',        'customer', NOW() - INTERVAL '70 days'),
    ('ivy@example.com',       'Ivy Taylor',         'customer', NOW() - INTERVAL '65 days'),
    ('jack@example.com',      'Jack Anderson',      'customer', NOW() - INTERVAL '60 days'),
    ('kate@example.com',      'Kate Thomas',        'customer', NOW() - INTERVAL '55 days'),
    ('liam@example.com',      'Liam Jackson',       'customer', NOW() - INTERVAL '50 days'),
    ('mia@example.com',       'Mia White',          'customer', NOW() - INTERVAL '45 days'),
    ('noah@example.com',      'Noah Harris',        'customer', NOW() - INTERVAL '40 days'),
    ('olivia@example.com',    'Olivia Martin',      'customer', NOW() - INTERVAL '35 days'),
    ('peter@example.com',     'Peter Garcia',       'customer', NOW() - INTERVAL '30 days'),
    ('quinn@example.com',     'Quinn Martinez',     'customer', NOW() - INTERVAL '25 days'),
    ('rose@example.com',      'Rose Robinson',      'customer', NOW() - INTERVAL '20 days'),
    ('sam@example.com',       'Sam Clark',          'customer', NOW() - INTERVAL '15 days');

-- Products (30 products)
INSERT INTO products (name, description, price, stock, sku, category_id) VALUES
    ('iPhone 15 Pro',       'Apple flagship smartphone',             1199.00, 45,  'APPL-IP15P-256',  6),
    ('Samsung Galaxy S24',  'Android flagship',                       999.00, 67,  'SAMS-GS24-128',   6),
    ('Google Pixel 8',      'Pure Android experience',                699.00, 38,  'GOOG-PX8-128',    6),
    ('MacBook Pro M3',      '14-inch professional laptop',           1999.00, 22,  'APPL-MBP-M3-14',  7),
    ('Dell XPS 15',         'Windows powerhouse',                    1499.00, 18,  'DELL-XPS15-2024', 7),
    ('Sony WH-1000XM5',     'Premium noise cancelling headphones',    349.00, 89,  'SONY-WH1000XM5',  8),
    ('AirPods Pro 2',       'Apple wireless earbuds',                 249.00, 134, 'APPL-APP2-USB',   8),
    ('Bose QC45',           'Comfortable over-ear headphones',        279.00, 56,  'BOSE-QC45-BLK',   8),
    ('Nike Air Max 270',    'Lifestyle running shoe',                 150.00, 200, 'NIKE-AM270-M10',  13),
    ('Adidas Ultraboost',   'Performance running shoe',               190.00, 175, 'ADID-UB23-M10',   13),
    ('Levi 501 Jeans',      'Classic straight fit',                    89.00, 300, 'LEVI-501-32-32',   9),
    ('Champion Hoodie',     'Heavyweight cotton blend',                75.00, 250, 'CHMP-HW-M-GRY',    9),
    ('Patagonia Fleece',    'Recycled materials fleece',              149.00, 120, 'PATA-FLCE-M-BLU',  9),
    ('Yoga Pants Pro',      'High-waist compression',                  65.00, 180, 'YGP-HW-M-BLK',   10),
    ('Sports Bra Elite',    'Impact support',                          55.00, 220, 'SBE-HI-M-PNK',   10),
    ('Clean Code',          'Robert C. Martin - must read',            45.00, 89,  'BOOK-CC-RMART',   12),
    ('The Pragmatic Prog',  'Andrew Hunt & David Thomas',              50.00, 76,  'BOOK-PP-HUNT',    12),
    ('Designing Data-Int',  'Martin Kleppmann',                        60.00, 54,  'BOOK-DDI-KLEP',   12),
    ('Dune',                'Frank Herbert sci-fi classic',            18.00, 200, 'BOOK-DUNE-HERB',  11),
    ('The Great Gatsby',    'F. Scott Fitzgerald',                     12.00, 150, 'BOOK-GG-FITZ',    11),
    ('Instant Pot Duo',     '7-in-1 electric pressure cooker',         99.00, 110, 'INST-DUO-7IN1',    4),
    ('Dyson V15',           'Cordless vacuum cleaner',                 749.00, 35,  'DYSO-V15-DET',    4),
    ('Weber Kettle Grill',  '22-inch charcoal grill',                 219.00, 28,  'WEBE-KETT-22',    4),
    ('Trek FX3 Disc',       'Fitness hybrid bicycle',                 899.00, 12,  'TREK-FX3D-M',    14),
    ('Giant Contend',       'Road bicycle for beginners',             799.00, 8,   'GIAN-CONT-M',    14),
    ('Standing Desk',       'Electric height adjustable',             549.00, 25,  'FLEX-STAND-60',   4),
    ('Monitor 27 4K',       'LG 27-inch 4K IPS display',             599.00, 40,  'LG-27UK850',      1),
    ('Mechanical Keyboard', 'Keychron K2 wireless',                    99.00, 78,  'KEYC-K2-RGB',     1),
    ('MX Master 3',         'Logitech ergonomic mouse',                99.00, 95,  'LOGI-MXM3-BLK',   1),
    ('USB-C Hub 10-in-1',   'Multi-port adapter',                      49.00, 200, 'ANKE-HUB-10P1',   1);

-- Orders (200 orders across different users and statuses)
INSERT INTO orders (user_id, status, total, created_at, updated_at)
SELECT
    (ARRAY[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20])[ceil(random()*19)::int],
    (ARRAY['pending','processing','shipped','delivered','cancelled','refunded'])[ceil(random()*6)::int],
    round((random() * 2000 + 50)::numeric, 2),
    NOW() - (random() * INTERVAL '180 days'),
    NOW() - (random() * INTERVAL '10 days')
FROM generate_series(1, 200);

-- Order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.id,
    (ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,16,17,18,19,21,22,27,28,29,30])[ceil(random()*22)::int],
    ceil(random()*3)::int,
    round((random() * 500 + 20)::numeric, 2)
FROM orders o
JOIN generate_series(1, 3) s ON random() > 0.3;

-- Payments
INSERT INTO payments (order_id, amount, status, payment_method, transaction_id, created_at)
SELECT
    o.id,
    o.total,
    CASE o.status
        WHEN 'pending'    THEN 'pending'
        WHEN 'processing' THEN 'processing'
        WHEN 'shipped'    THEN 'completed'
        WHEN 'delivered'  THEN 'completed'
        WHEN 'cancelled'  THEN 'cancelled'
        WHEN 'refunded'   THEN 'refunded'
        ELSE 'pending'
    END,
    (ARRAY['credit_card','debit_card','paypal','bank_transfer','crypto'])[ceil(random()*5)::int],
    'TXN-' || upper(md5(o.id::text || random()::text)),
    o.created_at + INTERVAL '2 minutes'
FROM orders o;

-- Product reviews
INSERT INTO product_reviews (product_id, user_id, rating, comment, created_at)
SELECT
    ceil(random()*30)::int,
    (ARRAY[2,3,4,5,6,7,8,9,10,11])[ceil(random()*10)::int],
    ceil(random()*5)::int,
    (ARRAY[
        'Great product, highly recommend!',
        'Good value for money.',
        'Exactly as described.',
        'Fast shipping, excellent quality.',
        'Would buy again.',
        'Decent product but could be better.',
        'Not exactly what I expected.',
        'Superb quality and fast delivery!'
    ])[ceil(random()*8)::int],
    NOW() - (random() * INTERVAL '90 days')
FROM generate_series(1, 80);

-- Coupons
INSERT INTO coupons (code, discount_pct, max_uses, used_count, expires_at) VALUES
    ('WELCOME10',   10.00, 1000, 347, NOW() + INTERVAL '30 days'),
    ('SUMMER25',    25.00, 500,  198, NOW() + INTERVAL '60 days'),
    ('VIP50',       50.00, 100,  42,  NOW() + INTERVAL '90 days'),
    ('FLASH20',     20.00, 200,  200, NOW() - INTERVAL '5 days'),
    ('LOYALTY15',   15.00, NULL, 891, NOW() + INTERVAL '365 days');

-- Notifications (150 entries)
INSERT INTO notifications (user_id, type, title, body, is_read, sent_at)
SELECT
    (ARRAY[2,3,4,5,6,7,8,9,10,11,12,13,14,15])[ceil(random()*14)::int],
    (ARRAY['order_confirmed','order_shipped','order_delivered','payment_success','payment_failed','promotion'])[ceil(random()*6)::int],
    (ARRAY[
        'Your order has been confirmed',
        'Your order is on its way',
        'Your order has been delivered',
        'Payment successful',
        'Payment failed - please update your card',
        'Exclusive offer just for you!'
    ])[ceil(random()*6)::int],
    'Thank you for shopping with us.',
    random() > 0.4,
    NOW() - (random() * INTERVAL '60 days')
FROM generate_series(1, 150);

-- User sessions (some active)
INSERT INTO user_sessions (user_id, token, expires_at) VALUES
    (2,  'tok_' || md5('alice_session'),   NOW() + INTERVAL '7 days'),
    (3,  'tok_' || md5('bob_session'),     NOW() + INTERVAL '3 days'),
    (5,  'tok_' || md5('dave_session'),    NOW() - INTERVAL '1 day'),
    (10, 'tok_' || md5('ivy_session'),     NOW() + INTERVAL '14 days');

-- ============================================================
-- Kubix WOW Demo — E-Commerce Platform Schema
-- ============================================================

-- Users & Auth
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    email       VARCHAR(255) UNIQUE NOT NULL,
    name        VARCHAR(255) NOT NULL,
    role        VARCHAR(50)  NOT NULL DEFAULT 'customer',
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE user_sessions (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       VARCHAR(512) UNIQUE NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Catalog
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    slug        VARCHAR(100) UNIQUE NOT NULL,
    parent_id   INTEGER REFERENCES categories(id)
);

CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       NUMERIC(10,2)  NOT NULL CHECK (price >= 0),
    stock       INTEGER        NOT NULL DEFAULT 0,
    sku         VARCHAR(100)   UNIQUE NOT NULL,
    category_id INTEGER        REFERENCES categories(id),
    is_active   BOOLEAN        NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE product_reviews (
    id          SERIAL PRIMARY KEY,
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id     INTEGER NOT NULL REFERENCES users(id),
    rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER        NOT NULL REFERENCES users(id),
    status      VARCHAR(50)    NOT NULL DEFAULT 'pending',
    total       NUMERIC(10,2),
    notes       TEXT,
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  INTEGER        NOT NULL REFERENCES products(id),
    quantity    INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2)  NOT NULL
);

-- Payments
CREATE TABLE payments (
    id              SERIAL PRIMARY KEY,
    order_id        INTEGER        NOT NULL REFERENCES orders(id),
    amount          NUMERIC(10,2)  NOT NULL,
    status          VARCHAR(50)    NOT NULL DEFAULT 'pending',
    payment_method  VARCHAR(50),
    transaction_id  VARCHAR(255)   UNIQUE,
    error_message   TEXT,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- Coupons
CREATE TABLE coupons (
    id              SERIAL PRIMARY KEY,
    code            VARCHAR(50)   UNIQUE NOT NULL,
    discount_pct    NUMERIC(5,2)  NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
    max_uses        INTEGER,
    used_count      INTEGER       NOT NULL DEFAULT 0,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER      NOT NULL REFERENCES users(id),
    type        VARCHAR(50)  NOT NULL,
    title       VARCHAR(255) NOT NULL,
    body        TEXT,
    is_read     BOOLEAN      NOT NULL DEFAULT false,
    sent_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    read_at     TIMESTAMPTZ
);

-- ── indexes on FK columns (missing some intentionally for demo) ──
CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_reviews_product    ON product_reviews(product_id);
CREATE INDEX idx_order_items_order  ON order_items(order_id);
CREATE INDEX idx_payments_order     ON payments(order_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
-- NOTE: orders.user_id intentionally has NO index (shows as "missing" in Kubix)
-- NOTE: user_sessions.user_id intentionally has NO index

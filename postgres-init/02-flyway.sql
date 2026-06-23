-- ============================================================
-- Flyway migration history — simulates real project history
-- ============================================================

CREATE TABLE flyway_schema_history (
    installed_rank  INTEGER      NOT NULL,
    version         VARCHAR(50),
    description     VARCHAR(200) NOT NULL,
    type            VARCHAR(20)  NOT NULL,
    script          VARCHAR(1000) NOT NULL,
    checksum        INTEGER,
    installed_by    VARCHAR(100) NOT NULL,
    installed_on    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    execution_time  INTEGER      NOT NULL,
    success         BOOLEAN      NOT NULL,
    CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank)
);

INSERT INTO flyway_schema_history
    (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success)
VALUES
    (1,  '1',   'initial schema',          'SQL', 'V1__initial_schema.sql',          -1234567890, 'postgres', NOW() - INTERVAL '90 days', 842,  true),
    (2,  '2',   'add user roles',          'SQL', 'V2__add_user_roles.sql',            987654321,  'postgres', NOW() - INTERVAL '75 days', 123,  true),
    (3,  '3',   'add product reviews',     'SQL', 'V3__add_product_reviews.sql',       111222333,  'deploy-bot', NOW() - INTERVAL '60 days', 287,  true),
    (4,  '4',   'add coupons table',       'SQL', 'V4__add_coupons_table.sql',         444555666,  'deploy-bot', NOW() - INTERVAL '45 days', 195,  true),
    (5,  '5',   'add notifications',       'SQL', 'V5__add_notifications.sql',         777888999,  'deploy-bot', NOW() - INTERVAL '30 days', 341,  true),
    (6,  '6',   'add payment error msg',   'SQL', 'V6__payment_error_column.sql',      112233445,  'deploy-bot', NOW() - INTERVAL '14 days', 89,   true),
    (7,  '7',   'add order notes',         'SQL', 'V7__order_notes_column.sql',        556677889,  'deploy-bot', NOW() - INTERVAL '7 days',  67,   true),
    (8,  '8',   'add product is active',   'SQL', 'V8__product_soft_delete.sql',       998877665,  'deploy-bot', NOW() - INTERVAL '2 days',  134,  true);

CREATE INDEX flyway_schema_history_s_idx ON flyway_schema_history(success);

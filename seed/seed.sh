#!/bin/sh
set -e

CATALOG_URL="${CATALOG_URL:-http://kubix-catalog:8082}"
SCHEMA_URL="${SCHEMA_URL:-http://kubix-schema:8080}"
PGHOST="${PGHOST:-demo-postgres}"
PGPORT="${PGPORT:-5432}"
PGDATABASE="${PGDATABASE:-ecommerce_demo}"
PGUSER="${PGUSER:-kubix}"
PGPASSWORD="${PGPASSWORD:-kubix_demo_2024}"
export PGPASSWORD

echo "⏳ Waiting for kubix-schema..."
until curl -sf "$SCHEMA_URL/api/health" > /dev/null 2>&1; do
  sleep 2
done
echo "✅ kubix-schema is ready"

echo "⏳ Waiting for kubix-catalog..."
until curl -sf "$CATALOG_URL/api/health" > /dev/null 2>&1; do
  sleep 2
done
echo "✅ kubix-catalog is ready"

# ══════════════════════════════════════════════════════════════
# SCHEMA DIFF SETUP
# Save a "before-migration" snapshot, then add real changes,
# so user can see a meaningful diff in the Diff page.
# ══════════════════════════════════════════════════════════════
echo ""
echo "📸 Saving schema snapshot: before-v8..."
curl -sf -X POST "$SCHEMA_URL/api/schema/snapshots" \
  -H "Content-Type: application/json" \
  -d '{"name":"before-v8"}' > /dev/null
echo "✅ Snapshot 'before-v8' saved (current schema without audit tables)"

# Now simulate a new migration: add audit_logs table + column
echo "⚙️  Applying migration V9 — adding audit_logs + orders.shipped_at..."
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" <<'SQL'
-- V9__add_audit_logging.sql
CREATE TABLE IF NOT EXISTS audit_logs (
    id          SERIAL PRIMARY KEY,
    table_name  VARCHAR(100) NOT NULL,
    record_id   INTEGER      NOT NULL,
    action      VARCHAR(20)  NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
    old_data    JSONB,
    new_data    JSONB,
    changed_by  INTEGER      REFERENCES users(id),
    changed_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_logs_table ON audit_logs(table_name, record_id);

-- Also add a new column to orders
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS shipped_at   TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS tracking_no  VARCHAR(100);

-- Populate some audit entries
INSERT INTO audit_logs (table_name, record_id, action, new_data, changed_by, changed_at)
SELECT 'orders', id, 'UPDATE',
       jsonb_build_object('status', status, 'total', total),
       CASE WHEN user_id <= 20 THEN user_id ELSE 2 END,
       updated_at
FROM orders
WHERE status IN ('shipped','delivered')
LIMIT 50;
SQL
echo "✅ Migration V9 applied — audit_logs table + orders.shipped_at added"

echo "📸 Saving schema snapshot: after-v9..."
curl -sf -X POST "$SCHEMA_URL/api/schema/snapshots" \
  -H "Content-Type: application/json" \
  -d '{"name":"after-v9"}' > /dev/null
echo "✅ Snapshot 'after-v9' saved"
echo ""
echo "👉 Go to Diff page → compare 'before-v8' vs 'after-v9' to see changes!"
echo ""

# ── Helper ────────────────────────────────────────────────────
ingest() {
  local svc="$1"
  local version="$2"
  local spec="$3"
  echo "📦 Registering $svc $version..."
  curl -sf -X POST "$CATALOG_URL/api/catalog/specs" \
    -H "Content-Type: application/json" \
    -d "{\"service_name\":\"$svc\",\"spec_version\":\"$version\",\"spec\":$spec}" \
    > /dev/null
}

add_dep() {
  local svc="$1"
  local deps="$2"
  echo "🔗 Dependencies: $svc → $deps"
  curl -sf -X POST "$CATALOG_URL/api/catalog/services/$svc/dependencies" \
    -H "Content-Type: application/json" \
    -d "{\"dependsOn\":$deps}" \
    > /dev/null
}

# ══════════════════════════════════════════════════════════════
# 1. USER SERVICE — v1 and v2 (to demo breaking changes)
# ══════════════════════════════════════════════════════════════
USER_V1=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "User Service", "version": "1.0.0", "description": "Manages users and authentication" },
  "paths": {
    "/users": {
      "get": { "summary": "List all users", "tags": ["users"], "parameters": [{"name":"page","in":"query","schema":{"type":"integer"}},{"name":"limit","in":"query","schema":{"type":"integer"}}] },
      "post": { "summary": "Create a new user", "tags": ["users"] }
    },
    "/users/{id}": {
      "get": { "summary": "Get user by ID", "tags": ["users"] },
      "put": { "summary": "Update user", "tags": ["users"] },
      "delete": { "summary": "Delete user", "tags": ["users"] }
    },
    "/users/{id}/profile": {
      "get": { "summary": "Get user profile", "tags": ["users"] },
      "patch": { "summary": "Update user profile", "tags": ["users"] }
    },
    "/auth/login": {
      "post": { "summary": "Login with email and password", "tags": ["auth"] }
    },
    "/auth/logout": {
      "post": { "summary": "Logout current session", "tags": ["auth"] }
    },
    "/auth/me": {
      "get": { "summary": "Get current authenticated user", "tags": ["auth"] }
    },
    "/auth/refresh": {
      "post": { "summary": "Refresh access token", "tags": ["auth"] }
    }
  }
}
SPEC
)

USER_V2=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "User Service", "version": "2.0.0", "description": "Manages users and authentication - v2 with new role system" },
  "paths": {
    "/v2/users": {
      "get": { "summary": "List all users", "tags": ["users"] },
      "post": { "summary": "Create a new user", "tags": ["users"] }
    },
    "/v2/users/{id}": {
      "get": { "summary": "Get user by ID", "tags": ["users"] },
      "put": { "summary": "Update user", "tags": ["users"] },
      "delete": { "summary": "Delete user", "tags": ["users"] }
    },
    "/v2/users/{id}/roles": {
      "get": { "summary": "Get user roles", "tags": ["users"] },
      "post": { "summary": "Assign role to user", "tags": ["users"] }
    },
    "/v2/auth/login": {
      "post": { "summary": "Login with email and password", "tags": ["auth"] }
    },
    "/v2/auth/me": {
      "get": { "summary": "Get current authenticated user", "tags": ["auth"] }
    },
    "/v2/auth/mfa/setup": {
      "post": { "summary": "Setup MFA for account", "tags": ["auth"] }
    }
  }
}
SPEC
)

ingest "user-service" "v1.0" "$USER_V1"
sleep 1
ingest "user-service" "v2.0" "$USER_V2"

# ══════════════════════════════════════════════════════════════
# 2. PRODUCT SERVICE
# ══════════════════════════════════════════════════════════════
PRODUCT_SPEC=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "Product Service", "version": "1.2.0", "description": "Product catalog management" },
  "paths": {
    "/products": {
      "get": { "summary": "List products", "tags": ["products"], "parameters": [{"name":"category","in":"query","schema":{"type":"string"}},{"name":"minPrice","in":"query","schema":{"type":"number"}},{"name":"maxPrice","in":"query","schema":{"type":"number"}},{"name":"inStock","in":"query","schema":{"type":"boolean"}}] },
      "post": { "summary": "Create product", "tags": ["products"] }
    },
    "/products/{id}": {
      "get": { "summary": "Get product by ID", "tags": ["products"] },
      "put": { "summary": "Update product", "tags": ["products"] },
      "delete": { "summary": "Delete product", "tags": ["products"] }
    },
    "/products/{id}/reviews": {
      "get": { "summary": "Get product reviews", "tags": ["reviews"] },
      "post": { "summary": "Add a review", "tags": ["reviews"] }
    },
    "/products/search": {
      "get": { "summary": "Full-text search products", "tags": ["products"] }
    },
    "/products/bulk": {
      "post": { "summary": "Bulk create/update products", "tags": ["products"] }
    },
    "/categories": {
      "get": { "summary": "List all categories", "tags": ["categories"] },
      "post": { "summary": "Create category", "tags": ["categories"] }
    },
    "/categories/{id}": {
      "get": { "summary": "Get category", "tags": ["categories"] }
    },
    "/categories/{id}/products": {
      "get": { "summary": "Get products in category", "tags": ["categories"] }
    },
    "/inventory/{id}": {
      "get": { "summary": "Get stock level", "tags": ["inventory"] },
      "patch": { "summary": "Update stock", "tags": ["inventory"] }
    }
  }
}
SPEC
)
ingest "product-service" "v1.2" "$PRODUCT_SPEC"

# ══════════════════════════════════════════════════════════════
# 3. ORDER SERVICE — depends on user-service + product-service + payment-service
# ══════════════════════════════════════════════════════════════
ORDER_SPEC=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "Order Service", "version": "1.5.0", "description": "Order lifecycle management - orchestrates user, product, and payment services" },
  "paths": {
    "/orders": {
      "get": { "summary": "List orders", "tags": ["orders"], "parameters": [{"name":"userId","in":"query","schema":{"type":"integer"}},{"name":"status","in":"query","schema":{"type":"string"}},{"name":"from","in":"query","schema":{"type":"string","format":"date"}},{"name":"to","in":"query","schema":{"type":"string","format":"date"}}] },
      "post": { "summary": "Create a new order", "tags": ["orders"], "description": "Validates user via user-service, checks stock via product-service" }
    },
    "/orders/{id}": {
      "get": { "summary": "Get order details", "tags": ["orders"] },
      "patch": { "summary": "Update order", "tags": ["orders"] }
    },
    "/orders/{id}/status": {
      "put": { "summary": "Update order status", "tags": ["orders"] }
    },
    "/orders/{id}/items": {
      "get": { "summary": "Get order items", "tags": ["orders"] },
      "post": { "summary": "Add item to order", "tags": ["orders"] }
    },
    "/orders/{id}/items/{itemId}": {
      "delete": { "summary": "Remove item from order", "tags": ["orders"] }
    },
    "/orders/{id}/pay": {
      "post": { "summary": "Initiate payment for order", "tags": ["payments"], "description": "Calls payment-service to process payment" }
    },
    "/orders/{id}/cancel": {
      "post": { "summary": "Cancel an order", "tags": ["orders"] }
    },
    "/orders/{id}/refund": {
      "post": { "summary": "Request refund", "tags": ["payments"] }
    },
    "/coupons/apply": {
      "post": { "summary": "Apply coupon to order", "tags": ["orders"] }
    },
    "/orders/analytics": {
      "get": { "summary": "Order analytics report", "tags": ["analytics"] }
    }
  }
}
SPEC
)
ingest "order-service" "v1.5" "$ORDER_SPEC"

# ══════════════════════════════════════════════════════════════
# 4. PAYMENT SERVICE — depends on order-service
# ══════════════════════════════════════════════════════════════
PAYMENT_SPEC=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "Payment Service", "version": "2.1.0", "description": "Payment processing and financial transactions" },
  "paths": {
    "/payments": {
      "get": { "summary": "List payments", "tags": ["payments"] },
      "post": { "summary": "Create payment intent", "tags": ["payments"] }
    },
    "/payments/{id}": {
      "get": { "summary": "Get payment details", "tags": ["payments"] }
    },
    "/payments/{id}/capture": {
      "post": { "summary": "Capture a payment intent", "tags": ["payments"] }
    },
    "/payments/{id}/cancel": {
      "post": { "summary": "Cancel payment", "tags": ["payments"] }
    },
    "/payments/{id}/refund": {
      "post": { "summary": "Process refund", "tags": ["payments"] }
    },
    "/payments/webhook": {
      "post": { "summary": "Payment provider webhook", "tags": ["webhooks"] }
    },
    "/payment-methods": {
      "get": { "summary": "List saved payment methods", "tags": ["payment-methods"] },
      "post": { "summary": "Add payment method", "tags": ["payment-methods"] }
    },
    "/payment-methods/{id}": {
      "delete": { "summary": "Remove payment method", "tags": ["payment-methods"] }
    },
    "/transactions": {
      "get": { "summary": "List all transactions", "tags": ["transactions"] }
    },
    "/transactions/{id}": {
      "get": { "summary": "Get transaction details", "tags": ["transactions"] }
    }
  }
}
SPEC
)
ingest "payment-service" "v2.1" "$PAYMENT_SPEC"

# ══════════════════════════════════════════════════════════════
# 5. NOTIFICATION SERVICE — depends on user-service
# ══════════════════════════════════════════════════════════════
NOTIF_SPEC=$(cat <<'SPEC'
{
  "openapi": "3.0.0",
  "info": { "title": "Notification Service", "version": "1.0.3", "description": "Email, SMS and push notification delivery" },
  "paths": {
    "/notifications": {
      "post": { "summary": "Send notification", "tags": ["notifications"] }
    },
    "/notifications/bulk": {
      "post": { "summary": "Send bulk notifications", "tags": ["notifications"] }
    },
    "/notifications/{userId}": {
      "get": { "summary": "Get user notifications", "tags": ["notifications"] }
    },
    "/notifications/{id}/read": {
      "put": { "summary": "Mark notification as read", "tags": ["notifications"] }
    },
    "/notifications/{id}": {
      "delete": { "summary": "Delete notification", "tags": ["notifications"] }
    },
    "/templates": {
      "get": { "summary": "List notification templates", "tags": ["templates"] },
      "post": { "summary": "Create template", "tags": ["templates"] }
    },
    "/templates/{id}": {
      "get": { "summary": "Get template", "tags": ["templates"] },
      "put": { "summary": "Update template", "tags": ["templates"] }
    },
    "/preferences/{userId}": {
      "get": { "summary": "Get notification preferences", "tags": ["preferences"] },
      "put": { "summary": "Update preferences", "tags": ["preferences"] }
    },
    "/stats": {
      "get": { "summary": "Delivery statistics", "tags": ["analytics"] }
    }
  }
}
SPEC
)
ingest "notification-service" "v1.0.3" "$NOTIF_SPEC"

# ══════════════════════════════════════════════════════════════
# Service Dependencies (builds the graph)
# ══════════════════════════════════════════════════════════════
echo ""
echo "🔗 Setting up service dependency graph..."
sleep 2

add_dep "order-service"        '["user-service","product-service","payment-service"]'
add_dep "payment-service"      '["order-service"]'
add_dep "notification-service" '["user-service"]'

echo ""
echo "✅ Demo seeding complete!"
echo ""
echo "═══════════════════════════════════════════════"
echo " KUBIX DEMO — Quick Start Guide"
echo "═══════════════════════════════════════════════"
echo ""
echo "📊 SCHEMA PAGE"
echo "   → 17 tables, 108 columns, 13 FK"
echo "   → Switch to ERD view for visual diagram"
echo "   → Click 'risk' on any table to see migration risk"
echo ""
echo "📜 MIGRATIONS PAGE"
echo "   → Flyway auto-detected!"
echo "   → 8 migrations: V1 initial schema → V8 soft delete"
echo ""
echo "🔀 DIFF PAGE"
echo "   → Snapshots: 'before-v8' and 'after-v9' are saved"
echo "   → Select 'before-v8' → 'after-v9' → Compare"
echo "   → See: +audit_logs table, +orders.shipped_at column"
echo ""
echo "⚡ DB PERFORMANCE"
echo "   → Slow queries: check threshold 50ms"
echo "   → Index Analysis: 'orders.user_id' has no index!"
echo "   → EXPLAIN: try SELECT * FROM orders WHERE user_id = 5"
echo "   → Set alert: 100ms threshold"
echo ""
echo "🔌 API CATALOG"
echo "   → 5 services: user, product, order, payment, notification"
echo "   → Search: type '/payment', '/users', 'reviews'"
echo "   → Dependency Graph: shows order→user, order→payment"
echo "   → user-service: v1.0 and v2.0 registered!"
echo "   → Go to user-service → 'Check Breaking Changes'"
echo "      (v1.0 has /users/{id}/profile → removed in v2.0)"
echo ""
echo "🌐 Open: http://localhost:3000"
echo "═══════════════════════════════════════════════"
echo ""
echo "Services registered:"
echo "  • user-service        (v1.0, v2.0) — 7 endpoints each"
echo "  • product-service     (v1.2)        — 9 endpoints"
echo "  • order-service       (v1.5)        — 10 endpoints"
echo "  • payment-service     (v2.1)        — 10 endpoints"
echo "  • notification-service(v1.0.3)      — 9 endpoints"
echo ""
echo "Dependencies:"
echo "  order-service → user-service, product-service, payment-service"
echo "  payment-service → order-service"
echo "  notification-service → user-service"
echo ""
echo "🌐 Open http://localhost:3000 to explore Kubix Dashboard"

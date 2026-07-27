# Design: Handmade Ceramics Online Store

## 1. Overview

A single-seller e-commerce system for a handmade ceramics studio. A public
storefront web-app lets registered customers browse a mixed catalog of
stocked and one-of-a-kind products, manage a cart, and check out through a
third-party payment gateway. A separate, staff-only admin console manages
products, inventory, and order fulfillment. Both surfaces are backed by one
Go API service that owns all persistence in a relational database, delegates
sign-in to the platform identity provider, and integrates with a payment
gateway and an email provider for order confirmations.

## 2. Components

- **ceramics-webapp** (`web-application`) — Public storefront: catalog
browsing, search, cart, account/profile, checkout, order history. Exposed
to the internet.
- **admin-webapp** (`web-application`) — Staff-only admin console: product &amp;
inventory management, order list &amp; fulfillment. A distinct user base and
lifecycle from the storefront, so it is a separate deployable web-app.
Exposed to the org intranet only.
- **ceramics-api** (`service`) — Go backend owning the catalog, inventory,
cart, checkout, order, and admin-management APIs, plus all persistence.
- **ceramics-db** (`platform-resource`, Postgres) — Relational database
owned by `ceramics-api` holding products, inventory, accounts (profile
extension), carts, orders, and audit records (NFR-8).

## 3. Capabilities

### ceramics-webapp

- Catalog browsing: paginated/filterable/sortable product list, category
filter, keyword search (FR-1, FR-7).
- Product detail page with images, description, dimensions/materials, and
availability status (FR-2, FR-3, FR-6).
- Cart management: add/update/remove items, stock/uniqueness re-validation
(FR-8–FR-12).
- Registration/login/logout via the platform identity provider (FR-13,
FR-14).
- Profile &amp; shipping address management (FR-15).
- Checkout flow: address confirmation, order summary (subtotal, flat
shipping, tax, total), payment via the payment gateway, confirmation
screen (FR-18–FR-23).
- Order history &amp; status view (FR-16).

### admin-webapp

- Product CRUD, including stocked-vs-unique flag and variant management
(FR-28, FR-29).
- Product image upload/management (FR-30).
- Manual "mark sold/unavailable" action for unique products (FR-31).
- Stock quantity adjustment (FR-29).
- Order list with status filter, order detail view (FR-24, FR-25).
- Order status update (pending → paid → shipped → delivered → cancelled),
including cancellation restocking (FR-26, FR-27).
- Distinct staff sign-in via the same identity provider, gated to the Store
Admin/Staff role (FR-17).

### ceramics-api

- Catalog service: product listing/search/filter/sort, product detail,
availability computation for stocked vs. unique products (FR-1–FR-7).
- Cart service: per-account cart persistence, stock/uniqueness validation on
add and at checkout (FR-8–FR-12).
- Account service: registration, profile, and shipping-address management,
backed by the platform identity provider for credentials (FR-13, FR-15).
- Checkout &amp; payment service: order summary computation (subtotal, flat
domestic shipping, tax), payment-intent creation against the payment
gateway, order creation on success, inventory decrement/unique-sold
marking, confirmation email trigger (FR-18–FR-23).
- Order service: customer order history/status (FR-16); admin order
list/detail/status update with restocking on cancellation (FR-24–FR-27).
- Inventory/product management service: admin CRUD for products, variants,
stock levels, images, and manual unique-item delisting (FR-28–FR-31).
- Audit logging: timestamped, actor-attributed record of order-status and
inventory changes (NFR-7).

## 4. Data model

- **Product** — id, name, description, category, price, images\[\],
dimensions/materials, kind (`stocked` | `unique`), status
(`active`/`sold`/`archived`), createdAt/updatedAt.
- **ProductVariant** — id, productId, name (e.g. glaze/size), sku,
quantityOnHand (stocked products only).
- **UniqueItem** — implicit: a `unique`-kind Product has no variant/quantity;
its own `status` (`available`/`sold`) IS its inventory state.
- **Account** — id (maps to identity-provider subject), name, email,
createdAt.
- **Address** — id, accountId, line1/line2, city, region, postalCode,
country, isDefault.
- **Cart** — id, accountId, updatedAt.
- **CartItem** — id, cartId, productId, variantId (nullable), quantity,
unitPriceSnapshot.
- **Order** — id, accountId, status (`pending`|`paid`|`shipped`|`delivered`|
`cancelled`), subtotal, shippingFee, tax, total, shippingAddress,
paymentReference, createdAt/updatedAt.
- **OrderItem** — id, orderId, productId, variantId (nullable),
productNameSnapshot, unitPrice, quantity.
- **AuditLogEntry** — id, entityType, entityId, action, actorId,
timestamp, details.

## 5. Roles &amp; access

- **Customer** — must register/sign in (FR-13) to use cart/checkout; can
view/edit own profile, addresses, cart, and order history; cannot access
admin functions.
- **Store Admin/Staff** — distinct role (FR-17), granted via the identity
provider's group claim; exclusive access to `admin-webapp` and the
`ceramics-api` admin endpoints (product/inventory management, order
management). `ceramics-api` authorizes admin endpoints by checking the
caller's role group; a signed-in caller with no recognized role is
rejected with 403.

## 6. Interactions

- `ceramics-webapp -> ceramics-api` — all storefront reads/writes (catalog,
cart, checkout, account, orders).
- `ceramics-webapp -> user-auth` — OIDC sign-in/sign-up for customers.
- `admin-webapp -> ceramics-api` — all admin reads/writes (product,
inventory, order management).
- `admin-webapp -> user-auth` — OIDC sign-in for staff.
- `ceramics-api -> user-auth` — validates end-user tokens (gateway-enforced)
for both customer and staff callers.
- `ceramics-api -> ceramics-db` — persists all catalog, account, cart,
order, and audit data (NFR-8).
- `ceramics-api -> payment-provider` — creates/confirms payments during
checkout (FR-20).
- `ceramics-api -> email-provider` — sends order confirmation emails
(FR-23).

## 7. Data flow

1. **Browse &amp; add to cart:** Customer opens `ceramics-webapp`, browses/
 searches the catalog (`ceramics-api` queries `ceramics-db`), and adds a
 stocked or unique product to their cart, which `ceramics-api` validates
 against current availability and persists.
2. **Checkout:** Customer proceeds to checkout; `ceramics-api` re-validates
 price/availability for every cart item, computes the order summary (flat
 shipping + tax), creates a payment intent with `payment-provider`, and on
 confirmed payment creates the `Order`/`OrderItem`s, decrements stocked
 inventory or marks unique items sold, writes an audit entry, and triggers
 a confirmation via `email-provider`.
3. **Order fulfillment:** Store Admin/Staff signs into `admin-webapp`, views
 the order list/detail via `ceramics-api`, and updates order status through
 its lifecycle; cancelling an order restores stocked inventory or relists
 a unique item and writes an audit entry.
4. **Catalog upkeep:** Store Admin/Staff creates/edits products, variants,
 stock levels, and images through `admin-webapp`, persisted by
 `ceramics-api` into `ceramics-db`; a unique item may also be manually
 marked sold outside the online flow.
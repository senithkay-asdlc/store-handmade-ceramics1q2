# Requirements Specification: Handmade Ceramics Online Store

## 1. Overview

A single-seller e-commerce web application for a handmade ceramics studio.
The store presents a product catalog, supports a shopping cart, and completes
purchases via checkout with third-party payment processing. Customers must
register and sign in to make a purchase. Studio staff have an admin console
to manage products, inventory, and orders.

**Success criterion:** A customer can browse the catalog, create an account,
add items to a cart, check out with a real payment gateway, and receive
order confirmation — while staff can manage the catalog and fulfill orders
from an admin console.

## 2. Stakeholders / Actors

- **Customer** — a registered, signed-in shopper who browses, buys, and
tracks their own orders.
- **Store Admin / Staff** — manages products, inventory, and order
fulfillment for the single studio.
- **Payment Gateway (third party)** — external service (e.g. Stripe) that
processes card payments; the store never stores raw card data.

## 3. Scope

### In scope

- Product catalog with categories, images, descriptions, and pricing.
- Two inventory models, since handmade ceramics are a mix of stocked and
one-of-a-kind items:
  - **Stocked products**: quantity-tracked, optionally with variants
  (e.g. glaze color, size), decremented on order.
  - **Unique/one-of-a-kind products**: a single physical piece; once sold,
  automatically delisted/marked sold, never restocked under the same
  listing.
- Shopping cart (add/update/remove items, persists for signed-in customers).
- Account registration, login, and session management (account required to
purchase).
- Checkout flow: shipping address, order review, payment via third-party
gateway, order confirmation.
- Flat-rate domestic shipping (single fixed fee, single country/region).
- Order history and order status tracking for customers.
- Admin console: product CRUD, inventory management (stock levels and
one-of-a-kind status), order list, and order status updates
(e.g. pending → paid → shipped → delivered → cancelled).
- Basic tax calculation appropriate to domestic sales (flat/region rate).

### Out of scope

- Multi-vendor marketplace features (seller onboarding, payouts, per-seller
storefronts).
- Guest checkout.
- International shipping / calculated freight rates.
- Storing or processing raw payment card data directly (delegated to the
payment gateway).
- Product reviews/ratings, wishlists, gift cards, discount/coupon engine
(may be considered later; not required for v1).
- Marketing/CRM features (email campaigns, abandoned-cart recovery).

## 4. Functional Requirements

### 4.1 Product Catalog

- FR-1: The system shall display a browsable, paginated catalog of ceramic
products, filterable by category and sortable by price/newest.
- FR-2: Each product listing shall show name, description, price, images,
category, and availability status (in stock / limited / sold / unique
piece).
- FR-3: Each product shall be flagged as either a **stocked** product
(has a quantity and optional variants) or a **unique** product (single
piece, no quantity).
- FR-4: A stocked product with zero remaining quantity shall be shown as
"out of stock" and not addable to cart.
- FR-5: A unique product that has been purchased shall be automatically
marked "sold" and removed from purchasable listings, while remaining
viewable in a "sold" archive if desired.
- FR-6: The system shall provide a product detail page with full
description, dimensions/materials (ceramics-specific attributes), and
multiple images.
- FR-7: The system shall support basic keyword search across product
name/description.

### 4.2 Shopping Cart

- FR-8: A signed-in customer shall be able to add a stocked product
(with chosen variant/quantity, subject to available stock) or a unique
product (quantity fixed at 1) to their cart.
- FR-9: The cart shall prevent adding more of a stocked item than is
currently available, and shall prevent adding a unique item that has
since been sold to another customer.
- FR-10: A customer shall be able to view, update quantities in, and remove
items from their cart.
- FR-11: The cart shall persist across sessions for a signed-in customer
(i.e. tied to the account, not just browser storage).
- FR-12: The system shall re-validate price and availability of all cart
items at checkout time, before payment.

### 4.3 Accounts &amp; Authentication

- FR-13: A visitor must register an account (name, email, password, and
shipping address) before they can complete checkout.
- FR-14: Registered customers shall be able to log in and log out.
- FR-15: A signed-in customer shall be able to view and edit their profile
and shipping address(es).
- FR-16: A signed-in customer shall be able to view their past orders and
current order statuses.
- FR-17: Store Admin/Staff shall have a distinct role with access to the
admin console, separate from customer accounts.

### 4.4 Checkout &amp; Payment

- FR-18: Checkout shall collect/confirm a domestic shipping address and
display an order summary (line items, subtotal, flat shipping fee, tax,
total) before payment.
- FR-19: The system shall apply a single flat-rate domestic shipping fee to
every order (no multi-tier or international rates in v1).
- FR-20: Payment shall be processed through a third-party payment gateway;
the system shall never receive or store raw card numbers, only a
tokenized reference and the payment outcome.
- FR-21: On successful payment, the system shall create an order, decrement
stocked-item inventory, mark any unique items sold, and show an order
confirmation with an order number.
- FR-22: On payment failure or decline, the system shall leave the cart
intact, show an actionable error, and create no order.
- FR-23: The system shall send (or display) an order confirmation to the
customer upon successful checkout.

### 4.5 Order Management (Admin)

- FR-24: Store Admin/Staff shall be able to view a list of all orders,
filterable by status.
- FR-25: Store Admin/Staff shall be able to view full order details
(items, customer, shipping address, payment status).
- FR-26: Store Admin/Staff shall be able to update an order's fulfillment
status (e.g. pending, paid, shipped, delivered, cancelled).
- FR-27: Cancelling an order shall restore stocked-item inventory and
relist any unique item that was reserved/sold for that order (subject to
payment/refund handling being addressed by the payment gateway).

### 4.6 Product &amp; Inventory Management (Admin)

- FR-28: Store Admin/Staff shall be able to create, edit, and remove
products, including marking a product as stocked or unique.
- FR-29: Store Admin/Staff shall be able to update stock quantities and
variant details for stocked products.
- FR-30: Store Admin/Staff shall be able to upload and manage product
images.
- FR-31: Store Admin/Staff shall be able to manually mark a unique product
as sold/unavailable outside of the online checkout flow (e.g. sold at a
craft fair).

## 5. Non-Functional Requirements

- NFR-1 (Security): All payment card handling shall be delegated to a
PCI-compliant third-party gateway; the application shall never persist
raw card data.
- NFR-2 (Security): Passwords shall be stored using a strong salted hash;
customer and admin sessions shall be authenticated and access to admin
functions restricted to the Store Admin/Staff role.
- NFR-3 (Data integrity): Inventory decrements/holds shall be consistent
under concurrent purchase attempts — two customers must not both
successfully buy the last unit of a stocked item or the same unique
item.
- NFR-4 (Availability): The catalog and cart shall remain browsable even if
the payment gateway is briefly unavailable; only the final checkout step
depends on it.
- NFR-5 (Performance): Catalog browsing and search pages shall return
results within 2 seconds under normal load.
- NFR-6 (Usability): The storefront shall be responsive and usable on
both desktop and mobile browsers.
- NFR-7 (Auditability): Order status changes and inventory adjustments
made by Admin/Staff shall be recorded with a timestamp and actor for
traceability.

## 6. Assumptions

- Single seller/studio; no multi-vendor marketplace concerns.
- Domestic shipping only, at a single flat rate; no international orders
in v1.
- Payment processing is delegated to a third-party gateway (e.g. Stripe);
integration details (specific provider) are a design-time decision.
- Tax handling is a simple flat/region-based calculation, not a full
multi-jurisdiction tax engine.
- "Mixed" inventory means the catalog contains both stocked (quantity/
variant) products and one-of-a-kind unique products side by side.
- Email delivery for order confirmations may be a best-effort notification;
exact provider is a design-time decision.

## 7. Open Questions

- None blocking; provider selection for payment gateway and email
notifications is deferred to design.


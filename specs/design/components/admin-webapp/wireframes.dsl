// Admin Console — staff-facing flow

screen ProductList "Staff manage the product catalog and inventory"
  navbar "Ceramics Admin"
  sidebar "Products | Orders | Settings"
  row
    heading "Products"
    right
    search "Search products…"
    button "New product" primary -> ProductEditor
  row
    badge "All (58)" info
    badge "Stocked (41)"
    badge "Unique (17)"
    badge "Out of stock (4)" warning
  table "Product | Kind | Stock | Price | Status | "
    row "Glazed Stoneware Mug | Stocked | 12 | $32 | Active | Edit →"
    row "Speckled Serving Bowl | Stocked | 2 | $58 | Active | Edit →"
    row "Raku Vase | Unique | — | $210 | Available | Edit →"
    row "Carved Teapot | Unique | — | $175 | Sold | Edit →"

screen ProductEditor "Staff create or edit a product, its kind, variants, and images"
  navbar "Ceramics Admin"
  sidebar "Products | Orders | Settings"
  breadcrumb "Products / Raku Vase"
  heading "Edit Product"
  input "Name"
  textarea "Description, dimensions, materials"
  row
    select "Category: Vases"
    input "Price ($)"
  row
    radio "Stocked (quantity-tracked)"
    radio "Unique (one-of-a-kind)" active
  input "Quantity on hand (stocked only)"
  heading "Images"
  row
    image "Photo 1" 100x80
    image "Photo 2" 100x80
    button "Upload image"
  toggle "Mark sold / unavailable" active
  row
    right
    button "Cancel"
    button "Save product" primary -> ProductList

screen OrderQueue "Staff view and filter orders by fulfillment status"
  navbar "Ceramics Admin"
  sidebar "Products | Orders | Settings"
  row
    heading "Orders"
    right
    select "Status: All"
  tabs "All (312) | Pending (4) | Paid (9) | Shipped (21) | Delivered (270) | Cancelled (8)"
  table "Order | Customer | Total | Status | Placed | "
    row "#10482 | J. Alvarez | $298.92 | Paid | Jul 20, 2026 | View →"
    row "#10481 | R. Kim | $58.00 | Pending | Jul 20, 2026 | View →"
    row "#10310 | M. Chen | $58.00 | Shipped | Jun 2, 2026 | View →"

screen OrderDetail "Staff views order detail and updates fulfillment status"
  navbar "Ceramics Admin"
  sidebar "Products | Orders | Settings"
  breadcrumb "Orders / #10482"
  row
    heading "Order #10482"
    badge "Paid" info
  text "Customer: J. Alvarez — Placed Jul 20, 2026"
  split 60/40
    left
      heading "Items"
      table "Item | Qty | Price"
        row "Glazed Stoneware Mug (Blue) | 2 | $64"
        row "Raku Vase (unique) | 1 | $210"
      text "Shipping: 12 Kiln Street, Portland, OR 97201"
      row
        right
        button "Cancel order"
        button "Mark as shipped" primary
    right
      card "Audit trail"
        text "Jul 20, 2026 — payment confirmed (Stripe)"
        text "Jul 20, 2026 — inventory decremented"

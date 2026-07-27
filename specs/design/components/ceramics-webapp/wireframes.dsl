// Ceramics Storefront — customer-facing flow

screen Catalog "Customer browses and searches the ceramics catalog"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  row
    heading "Handmade Ceramics"
    right
    search "Search mugs, bowls, vases…"
    select "Category: All"
  row
    card "Glazed Stoneware Mug | $32 | In stock"
    card "Speckled Serving Bowl | $58 | Only 2 left"
    card "Raku Vase — One of a kind | $210 | Unique piece"
  row
    card "Blue Celadon Plate | $28 | In stock"
    card "Textured Planter | $44 | Out of stock"
    card "Carved Teapot — One of a kind | $175 | Sold" -> ProductDetail

screen ProductDetail "Customer views one product and adds it to cart"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  breadcrumb "Shop / Raku Vase"
  row
    heading "Raku Vase"
    badge "Unique piece" info
  image "Product photo 1" 320x240
  row
    image "Thumbnail 2" 100x80
    image "Thumbnail 3" 100x80
    image "Thumbnail 4" 100x80
  text "Hand-thrown stoneware, raku-fired copper glaze. 28cm tall, 14cm diameter."
  text "$210 — one-of-a-kind, will not be restocked"
  row
    select "Quantity: 1"
    button "Add to cart" primary -> Cart

screen Cart "Customer reviews cart contents before checkout"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  heading "Your Cart"
  table "Item | Variant | Qty | Price | "
    row "Glazed Stoneware Mug | Blue glaze | 2 | $64 | Remove"
    row "Raku Vase (unique) | — | 1 | $210 | Remove"
  row
    right
    text "Subtotal: $274"
  row
    right
    button "Continue shopping"
    button "Checkout" primary -> Checkout

screen Checkout "Customer confirms shipping address and pays"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  heading "Checkout"
  split 60/40
    left
      heading "Shipping address"
      input "Full name"
      input "Address line 1"
      row
        input "City"
        input "Postal code"
      heading "Payment"
      input "Card number"
      row
        input "Expiry"
        input "CVC"
    right
      card "Order summary"
        text "Subtotal: $274"
        text "Shipping (flat rate): $8"
        text "Tax: $16.92"
        text "Total: $298.92"
      button "Pay & place order" primary -> OrderConfirmation

screen OrderConfirmation "Customer sees confirmation after successful payment"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  heading "Thank you for your order!"
  badge "Order #10482 confirmed" success
  text "A confirmation email is on its way to you."
  text "Estimated delivery: 5-7 business days (domestic flat-rate shipping)."
  button "View order history" primary -> OrderHistory

screen OrderHistory "Customer views past orders and their status"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  heading "My Orders"
  table "Order | Date | Total | Status | "
    row "#10482 | Jul 20, 2026 | $298.92 | Paid | View →"
    row "#10310 | Jun 2, 2026 | $58.00 | Shipped | View →"
    row "#10221 | Apr 14, 2026 | $210.00 | Delivered | View →"

screen Profile "Customer manages profile and shipping addresses"
  navbar "Ceramics Studio | Shop | Cart | Orders | Account"
  heading "Account"
  input "Name"
  input "Email"
  heading "Shipping addresses"
  card "Home | 12 Kiln Street, Portland, OR 97201 | Default"
  row
    right
    button "Add address"
    button "Save changes" primary

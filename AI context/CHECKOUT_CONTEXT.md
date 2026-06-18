# FRONTEND CHECKOUT & BAG SYSTEM CONTEXT

*Last Updated: 2026-06-17*

## 1. Hệ thống Provider (Riverpod)
- **`cart_provider.dart`:** Tự động parse cấu trúc JSON `CartResponse` từ API. Đã xử lý triệt để lỗi `TypeError` thông qua toán tử `.toString()` an toàn khi parse chuỗi UUID động từ Backend.
- **`checkout_provider.dart`:** Quản lý State xuyên suốt quá trình mua hàng bao gồm `selectedAddress`, `selectedPaymentMethod`, và `selectedDeliveryMethod`. Hàm `submitOrder` tự động gom đầy đủ Data và đẩy lên Payload của BE.

## 2. Giao diện (Screens) theo Basement.pdf
- Các màn hình `BagScreen`, `CheckoutScreen`, `ShippingAddressesScreen`, `AddingShippingAddressScreen`, `PaymentMethodsScreen`, `SuccessScreen` đã được thiết kế và liên kết Navigation 100% liền mạch.
- Màn hình thêm địa chỉ được làm nút nhấn to hơn, title đổi thành `"Adding Shipping Address"` thân thiện với ngón tay to.

## 3. UI/UX Polishing (Hiệu ứng tinh xỉnh)
- **Delivery Method Selection:** Trang bị hiệu ứng "lõm xuống" (Neumorphism / Inner Shadow) kết hợp đổi màu viền, sử dụng `BoxShadow` với thuộc tính `blurStyle: BlurStyle.inner` và GestureDetector trên nền `Container`. 
- **Payment Method Security:** Chuỗi 16 số của thẻ ngân hàng được gửi vào State (ví dụ `"5546 8205 3693 3947"`), nhưng khi render lên UI, nó sử dụng logic `substring(length - 4)` siêu an toàn để xuất ra giao diện chuẩn xác: `**** **** **** 3947` (mã hoá hoàn toàn 12 số đầu).

# Frontend (Flutter) - AI Context

**Ngày cập nhật**: 08/06/2026
**Dự án**: E-commerce Frontend (Flutter)

## 1. Công nghệ & Kiến trúc
- **Ngôn ngữ**: Dart
- **Framework**: Flutter (Đa nền tảng: Android, iOS, Web, Windows...)
- **State Management**: Riverpod (sử dụng `FutureProvider`, `Provider`...)
- **Networking**: `Dio`
- **Storage**: `flutter_secure_storage` cho JWT token.
- **Backend**: Giao tiếp với Spring Boot qua REST API (`https://ecommerce-backend-24ii.onrender.com/api`).
- **Media**: Sử dụng Supabase Storage trực tiếp qua URL.

## 2. Trạng thái hiện tại (Cập nhật mới nhất)
- Đã cấu trúc thư mục chuẩn mở rộng (`screens/`, `widgets/`, `services/`, `providers/`, `models/`).
- Đã thiết kế các màn hình xác thực tĩnh (Login, Signup, Forgot Password) với UI hiện đại.
- **Luồng Xác thực (Authentication Flow):**
  - Đã tích hợp **Supabase** kết hợp với `google_sign_in` và `flutter_facebook_auth` cho chức năng Social Login.
  - Đã chốt luồng: Đăng ký thành công -> Chuyển hướng sang Login -> Chuyển hướng sang Home.
- **[MỚI] Triển khai màn hình Home (Home Screen):**
  - Đã hoàn thiện giao diện trang chủ theo bản thiết kế `Basement.pdf` (Trang 44 - 56).
  - Tích hợp thành công API lấy Slideshow Banner (`GET /api/slideshows`) và Sản phẩm theo Tag (`GET /api/products/home/tags/New`, `GET /api/products/home/tags/Sale`).

## 3. Cấu trúc các File/Thành phần mới tạo
- **Models (`lib/models/`)**:
  - `slideshow.dart`: Map dữ liệu banner.
  - `product_home.dart`: Map dữ liệu sản phẩm hiển thị trên trang chủ (có xử lý tính % giảm giá từ `comparePrice` và `salePrice`).
- **Services (`lib/services/`)**:
  - `api_service.dart`: Đã bổ sung hàm `getSlideshows()` và `getProductsByTag(tagName)`.
- **Providers (`lib/providers/`)**:
  - `home_provider.dart`: Chứa các `FutureProvider` (`slideshowsProvider`, `newProductsProvider`, `saleProductsProvider`) để lấy dữ liệu bất đồng bộ.
- **Widgets (`lib/widgets/`)**:
  - `slideshow_banner.dart`: Khối Banner to trên cùng (có nút Check đỏ, hiệu ứng gradient đen).
  - `product_section.dart`: Khối cuộn ngang chứa danh sách sản phẩm ("New", "Sale").
  - `product_card.dart`: Thẻ sản phẩm (hiển thị ảnh lỗi dự phòng, badge `-20%`, tag `NEW`, rating sao vàng).
  - `custom_bottom_nav.dart`: Thanh điều hướng dưới cùng, dùng asset ảnh tĩnh (`assets/images/nav_bar/...`) và đổi màu khi được chọn.
- **Screens (`lib/screens/`)**:
  - `home_screen.dart`: Màn hình chính lắp ráp toàn bộ các Widgets trên với `SingleChildScrollView`, xử lý trạng thái Loading/Error/Data bằng Riverpod `.when()`.

## 4. Các bước tiếp theo (Next Steps)
1. **Hoàn thiện UI/UX**: Phát triển tiếp các luồng chi tiết sản phẩm (Product Detail), giỏ hàng (Cart) và danh mục (Shop/Catalog).
2. **Quản lý Token**: Xử lý logic refresh token và tự động đăng nhập khi mở lại app nếu JWT token vẫn còn hạn.
3. **Favorites (Yêu thích)**: Lập trình chức năng click vào icon trái tim trên `ProductCard` để thêm/xóa sản phẩm yêu thích (cần tích hợp API BE tương ứng).
4. **Bottom Navigation Logic**: Xây dựng cơ chế `IndexedStack` hoặc go_router để chuyển đổi qua lại mượt mà giữa 5 tab (Home, Shop, Bag, Favorites, Profile).

---
*Lưu ý đối với AI Gemini: Hãy tự động cập nhật lại file này bất cứ khi nào có thay đổi lớn ở Frontend (như thêm màn hình mới, thay đổi thư viện cốt lõi, hay kết nối xong các API quan trọng) để đồng bộ khi commit code lên Github.*

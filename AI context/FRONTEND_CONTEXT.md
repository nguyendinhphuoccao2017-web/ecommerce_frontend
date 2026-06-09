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
  - Tích hợp thành công API lấy Slideshow Banner (`GET /api/slideshows/home` - giới hạn 2 ảnh) và Sản phẩm theo Tag (`GET /api/products/home/tags/New`, `GET /api/products/home/tags/Sale`).
  - **Pull-to-Refresh**: Đã tích hợp tính năng vuốt xuống để tải lại bằng `RefreshIndicator` kết hợp với hàm `ref.invalidate()` của Riverpod để xóa cache và tự động fetch lại toàn bộ dữ liệu mới nhất từ Backend (rất hữu ích khi cần test cập nhật Tag tức thời).

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
  - `product_section.dart`: Khối cuộn ngang chứa danh sách sản phẩm ("New", "Sale"). Nhận thêm tham số `isNewSection` để phân biệt logic hiển thị.
  - `product_card.dart`: Thẻ sản phẩm dùng chung.
    - **Logic phần "Sale"**: Hiển thị badge đỏ `-20%`, giá gốc bị gạch ngang và giá Sale màu đỏ.
    - **Logic phần "New"**: Hiển thị chữ `NEW` trên nền trắng chuẩn typography (Metropolis, size 11px), chỉ hiển thị duy nhất 1 mức giá gốc (không gạch ngang).
  - `custom_bottom_nav.dart`: Thanh điều hướng dưới cùng, dùng asset ảnh tĩnh (`assets/images/nav_bar/...`) và đổi màu khi được chọn.
- **Screens (`lib/screens/`)**:
  - `home_screen.dart`: Màn hình chính lắp ráp toàn bộ các Widgets trên với `SingleChildScrollView`, xử lý trạng thái Loading/Error/Data bằng Riverpod `.when()`. Đã được bọc ngoài bằng `RefreshIndicator` để hỗ trợ thao tác kéo thả làm mới trang.

## 4. Các chỉnh sửa & Bug Fixes mới nhất
- **UI Tweaks**:
  - Đã xóa bỏ hiệu ứng cuộn kéo giãn (Overscroll Glow) khi lướt tới cuối danh sách bằng `ClampingScrollPhysics()`.
  - Căn chỉnh lại `CrossAxisAlignment.center` để chữ "View all" nằm cân bằng hoàn hảo với tiêu đề khối.
  - Sửa lỗi khoảng trống thừa thãi giữa ảnh sản phẩm và đánh giá 5 sao (`SizedBox(height: 8)`).
- **Ánh xạ SKU**: Thay thế chữ "Brand Name" tĩnh bằng dữ liệu mã `sku` từ Database (Đã đồng bộ bổ sung trường `sku` vào `ProductHomeResponseDTO.java` ở Backend).
- **Phân quyền API**: Đã cấu hình `SecurityConfig.java` (Backend) cho phép truy cập public đối với API `GET /api/slideshows` để khắc phục lỗi 403 Forbidden trên màn hình Home.
- **Slideshow API**: Đã cập nhật `api_service.dart` gọi đến API `/api/slideshows/home` (thay vì `/api/slideshows`) để lấy chính xác 2 banner đang được publish cho trang chủ. Đã tái cấu trúc biến `apiBaseUrl` giúp dễ dàng switch qua lại giữa test Local (localhost/10.0.2.2) và Production (Render).
- **Slideshow Swipe Gesture**: Cập nhật `home_screen.dart` sử dụng `PageView.builder` thay vì widget đơn lẻ để hỗ trợ thao tác vuốt ngang (swipe) xem toàn bộ ảnh Slideshow Banner. Dữ liệu luôn được tự động sắp xếp theo `displayOrder`.
## 5. Các bước tiếp theo (Next Steps)
1. **Hoàn thiện UI/UX**: Phát triển tiếp các luồng chi tiết sản phẩm (Product Detail), giỏ hàng (Cart) và danh mục (Shop/Catalog).
2. **Quản lý Token**: Xử lý logic refresh token và tự động đăng nhập khi mở lại app nếu JWT token vẫn còn hạn.
3. **Favorites (Yêu thích)**: Lập trình chức năng click vào icon trái tim trên `ProductCard` để thêm/xóa sản phẩm yêu thích (cần tích hợp API BE tương ứng).
4. **Bottom Navigation Logic**: Xây dựng cơ chế `IndexedStack` hoặc go_router để chuyển đổi qua lại mượt mà giữa 5 tab (Home, Shop, Bag, Favorites, Profile).

---
*Lưu ý đối với AI Gemini: Hãy tự động cập nhật lại file này bất cứ khi nào có thay đổi lớn ở Frontend (như thêm màn hình mới, thay đổi thư viện cốt lõi, hay kết nối xong các API quan trọng) để đồng bộ khi commit code lên Github.*

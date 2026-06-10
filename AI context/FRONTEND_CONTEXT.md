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
  - **Pull-to-Refresh**: Đã tích hợp tính năng vuốt xuống để tải lại bằng `RefreshIndicator` kết hợp với hàm `ref.invalidate()` của Riverpod để xóa cache và tự động fetch lại toàn bộ dữ liệu mới nhất từ Backend.
- **[MỚI] Triển khai luồng Danh mục (Shop) & Yêu thích (Favorites):**
  - **Shop Flow**: Cấu trúc thành công `ShopScreen` -> `CategoriesScreen` -> `CategoryProductsScreen` mô phỏng Nested Navigation bằng `Navigator.push`. 
  - **State Management**: Sử dụng `IndexedStack` trong `home_screen.dart` để quản lý BottomNavigationBar giúp chuyển tab không làm mất lịch sử cuộn.
  - **Tích hợp API**: Đã cấu hình `api_service.dart` lấy toàn bộ danh mục (`GET /api/categories`), sản phẩm theo danh mục (`GET /api/categories/{id}/products`), và các API liên quan đến Yêu thích (`POST /api/favorites/{productId}/toggle`, `GET /api/favorites`).
  - **Optimistic UI**: Đã triển khai `favoriteNotifierProvider` sử dụng StateNotifier để thay đổi giao diện trái tim ngay lập tức khi người dùng thả tim, và gọi `ref.invalidate` để làm mới danh sách sản phẩm.

## 3. Cấu trúc các File/Thành phần mới tạo
- **Models (`lib/models/`)**:
  - `slideshow.dart`, `product_home.dart` (Bổ sung `isFavorite`), `category.dart`.
- **Services (`lib/services/`)**:
  - `api_service.dart`: Đã bổ sung hàm `getCategories()`, `getProductsByCategory()`, `toggleFavorite()`, `getFavoriteProducts()`.
- **Providers (`lib/providers/`)**:
  - `home_provider.dart`: Chứa `FutureProvider` cho trang chủ.
  - `category_provider.dart`: Chứa `categoriesProvider`, `categoryProductsProvider`.
  - `favorite_provider.dart`: Quản lý logic thả tim (`FavoriteNotifier`) và tải sản phẩm yêu thích.
- **Widgets (`lib/widgets/`)**:
  - `slideshow_banner.dart`, `product_section.dart`, `custom_bottom_nav.dart`.
  - `product_card.dart`: Cập nhật bọc trong `ConsumerWidget` để lắng nghe thao tác click Thả tim thông qua `favoriteNotifierProvider`.
- **Screens (`lib/screens/`)**:
  - `home_screen.dart`: Cập nhật cấu trúc dùng `IndexedStack`.
  - `shop_screen.dart`: Giao diện gốc tab Shop (Banner, Thẻ phân loại tĩnh).
  - `categories_screen.dart`: Màn hình liệt kê các category lấy từ BE.
  - `category_products_screen.dart`: Màn hình danh sách sản phẩm (Hỗ trợ đổi Grid/List Mode).

## 4. Các chỉnh sửa & Bug Fixes mới nhất
- **UI Tweaks**:
  - Đã xóa bỏ hiệu ứng cuộn kéo giãn (Overscroll Glow) khi lướt tới cuối danh sách bằng `ClampingScrollPhysics()`.
  - Căn chỉnh lại `CrossAxisAlignment.center` để chữ "View all" nằm cân bằng hoàn hảo với tiêu đề khối.
  - Sửa lỗi khoảng trống thừa thãi giữa ảnh sản phẩm và đánh giá 5 sao (`SizedBox(height: 8)`).
- **Ánh xạ SKU**: Thay thế chữ "Brand Name" tĩnh bằng dữ liệu mã `sku` từ Database (Đã đồng bộ bổ sung trường `sku` vào `ProductHomeResponseDTO.java` ở Backend).
- **Phân quyền API**: Đã cấu hình `SecurityConfig.java` (Backend) cho phép truy cập public đối với API `GET /api/slideshows` để khắc phục lỗi 403 Forbidden trên màn hình Home.
- **Slideshow API**: Đã cập nhật `api_service.dart` gọi đến API `/api/slideshows/home` (thay vì `/api/slideshows`) để lấy chính xác 2 banner đang được publish cho trang chủ. Đã tái cấu trúc biến `apiBaseUrl` giúp dễ dàng switch qua lại giữa test Local (localhost/10.0.2.2) và Production (Render).
- **Slideshow Swipe Gesture**: Cập nhật `home_screen.dart` sử dụng `PageView.builder` thay vì widget đơn lẻ để hỗ trợ thao tác vuốt ngang (swipe) xem toàn bộ ảnh Slideshow Banner. Dữ liệu luôn được tự động sắp xếp theo `displayOrder`. Tăng chiều cao (height) của khu vực Banner lên `500` để hình ảnh rộng rãi hơn.
- **Slideshow Banner Overlay**: Cập nhật `slideshow_banner.dart` chỉ hiển thị lớp phủ (Title và Nút Check) cho Banner đầu tiên (`displayOrder == 1`), các banner sau chỉ hiện hình ảnh. Tiêu đề hiển thị chuẩn font Metropolis 48px, trắng. Nút Check sử dụng hình nền `check_button.png` kết hợp màu nền đỏ `#DB3022`.
## 5. Các bước tiếp theo (Next Steps)
1. **Màn hình Favorites**: Luồng Backend và Controller đã xong, thao tác Like đã xong. Bước tiếp theo là tạo màn hình `favorites_screen.dart` (Gắn vào tab thứ 4 của IndexedStack) để hiển thị lưới các sản phẩm người dùng đã thả tim thông qua `favoriteProductsProvider`.
2. **Luồng Bag (Giỏ hàng)**: Tích hợp Backend & Frontend cho chức năng Giỏ hàng.
3. **Quản lý Token**: Xử lý triệt để logic Interceptor của Dio để tự động đính kèm Token hoặc làm mới Token khi hết hạn.

---
*Lưu ý đối với AI Gemini: Hãy tự động cập nhật lại file này bất cứ khi nào có thay đổi lớn ở Frontend (như thêm màn hình mới, thay đổi thư viện cốt lõi, hay kết nối xong các API quan trọng) để đồng bộ khi commit code lên Github.*

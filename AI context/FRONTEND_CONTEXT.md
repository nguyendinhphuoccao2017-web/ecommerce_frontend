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
- **[MỚI] Triển khai luồng Danh mục (Shop) & Yêu thích (Favorites):**
  - **Shop Flow**: Cấu trúc thành công `ShopScreen` -> `CategoriesScreen` -> `CategoryProductsScreen` mô phỏng Nested Navigation bằng `Navigator.push`. 
  - **State Management**: Sử dụng `IndexedStack` trong `home_screen.dart` để quản lý BottomNavigationBar giúp chuyển tab không làm mất lịch sử cuộn.
  - **Tích hợp API**: Đã cấu hình `api_service.dart` lấy toàn bộ danh mục (`GET /api/categories`), sản phẩm theo danh mục (`GET /api/categories/{id}/products`), và các API liên quan đến Yêu thích (`POST /api/favorites/{productId}/toggle`, `GET /api/favorites`).
  - **Optimistic UI**: Đã triển khai `favoriteNotifierProvider` sử dụng StateNotifier để thay đổi giao diện trái tim ngay lập tức khi người dùng thả tim, và gọi `ref.invalidate` để làm mới danh sách sản phẩm.
  - **Giao diện chọn Biến thể (Variants)**: Đã tích hợp Button "Trái tim" ở `ProductCard` và `HorizontalProductCard`. Khi bấm sẽ hiển thị `SizeSelectionBottomSheet` mượt mà để chọn Variant (Size và Màu Sắc chuẩn hóa từ DB).
  - Chọn Size tự động lưu vào hệ thống, tắt Bottom Sheet, và chuyển hướng trực tiếp qua trang Favorites trên thanh Bottom Navigation Bar.
  - Xây dựng hoàn chỉnh màn hình `FavoritesScreen` (Tab 3) hỗ trợ chuyển đổi linh hoạt Grid/List view qua Icon.
  - Tích hợp số đếm (Badge) đỏ tại biểu tượng Favorites trên Bottom Navigation Bar khi có sản phẩm được yêu thích.
  - Thiết kế `FavoriteProductCard` hiển thị chi tiết tên Variant đã chọn (Ví dụ: "White, M" hoặc "Blue, M" nhờ việc API test-seeder đã map đúng màu sản phẩm) và logic giá bán tương tự trang Shop.

## 3. Cấu trúc các File/Thành phần mới tạo
- **Models (`lib/models/`)**:
  - `slideshow.dart`, `product_home.dart` (Bổ sung `isFavorite`), `category.dart`.
- **Models (`lib/models/`)**:
  - `slideshow.dart`: Map dữ liệu banner.
  - `product_home.dart`: Map dữ liệu sản phẩm hiển thị trên trang chủ (có xử lý tính % giảm giá từ `comparePrice` và `salePrice`, bổ sung `isFavorite`).
  - `category.dart`: Model danh mục.
  - `variant_option.dart`: Model cho thông tin Variant (Size, Màu sắc).
  - `favorite_product.dart`: Model đặc tả riêng cho API danh sách Yêu thích.
- **Services (`lib/services/`)**:
  - `api_service.dart`: Đã bổ sung hàm `getCategories()`, `getProductsByCategory()`, `toggleFavorite()`, `getFavoriteProducts()`.
- **Providers (`lib/providers/`)**:
  - `home_provider.dart`: Chứa các `FutureProvider` (`slideshowsProvider`, `newProductsProvider`, `saleProductsProvider`) để lấy dữ liệu bất đồng bộ.
  - `category_provider.dart`: Chứa `categoriesProvider`, `categoryProductsProvider`.
  - `favorite_provider.dart`: Quản lý danh sách Yêu thích và trạng thái Toggle (làm mới mọi cache khi trạng thái favorite thay đổi).
  - `nav_provider.dart`: Cung cấp State toàn cục (`StateProvider<int>`) để điều khiển Tab chuyển đổi ở Bottom Navigation.
  - `loading_provider.dart`: **[MỚI]** Cung cấp trạng thái bật/tắt hiệu ứng Blur (Lớp phủ Loading) trên toàn app để chống thao tác liên tục vào API.
- **Widgets (`lib/widgets/`)**:
  - `slideshow_banner.dart`: Khối Banner to trên cùng (có nút Check đỏ, hiệu ứng gradient đen).
  - `product_section.dart`: Khối cuộn ngang chứa danh sách sản phẩm ("New", "Sale"). Nhận thêm tham số `isNewSection` để phân biệt logic hiển thị.
  - `product_card.dart`: Thẻ sản phẩm dùng chung, đã được bọc `ConsumerWidget` và thêm khối `try-catch` kết hợp SnackBar để bắt lỗi khi thêm Yêu Thích.
    - **Logic phần "Sale"**: Hiển thị badge đỏ `-20%`, giá gốc bị gạch ngang và giá Sale màu đỏ.
    - **Logic phần "New"**: Hiển thị chữ `NEW` trên nền trắng chuẩn typography (Metropolis, size 11px), chỉ hiển thị duy nhất 1 mức giá gốc (không gạch ngang).
  - `custom_bottom_nav.dart`: Thanh điều hướng dưới cùng, dùng asset ảnh tĩnh (`assets/images/nav_bar/...`) và đổi màu khi được chọn. Được kết nối vào Riverpod để hiện số lượng đếm (Badge) sản phẩm yêu thích.
  - `size_selection_bottom_sheet.dart`: Giao diện Component trượt từ dưới lên cho phép lấy danh sách Size của Product ID từ API, khi nhấn chọn Size -> Tự động đánh dấu Yêu Thích.
  - `favorite_product_card.dart` & `horizontal_favorite_product_card.dart`: Tương tự thẻ sản phẩm thông thường, có hiển thị giá Variant đặc thù. Bổ sung nút X (để Unlike) có kèm hiệu ứng Blur Loading.
  - `loading_overlay.dart`: **[MỚI]** Widget độc lập (sử dụng BackdropFilter) bọc ở `main.dart` để tạo lớp sương mờ chặn thao tác người dùng khi gọi API.
- **Screens (`lib/screens/`)**:
  - `home_screen.dart`: Cập nhật cấu trúc dùng `IndexedStack`. Xử lý trạng thái Loading/Error/Data bằng Riverpod `.when()`. Đã được bọc ngoài bằng `RefreshIndicator` để hỗ trợ thao tác kéo thả làm mới trang.
  - `shop_screen.dart`: Giao diện gốc tab Shop (Banner, Thẻ phân loại tĩnh).
  - `categories_screen.dart`: Màn hình liệt kê các category lấy từ BE.
  - `category_products_screen.dart`: Màn hình danh sách sản phẩm (Hỗ trợ đổi Grid/List Mode).
  - `favorites_screen.dart`: Giao diện chính tab Favorites với tuỳ chọn Grid View / List View. Sử dụng Riverpod AsyncValue để render UI mà không kích hoạt Loading Blur toàn cục gây trải nghiệm xấu.

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
- **Refactor Màn Hình Danh Mục (Shop & Categories)**:
  - Tách `TabBar` (Women, Men, Kids) ra khỏi `AppBar` trên `ShopScreen`. Bổ sung thanh chỉ đỏ (indicator) trải rộng toàn bộ tab (`TabBarIndicatorSize.tab`).
  - Xóa title khỏi `AppBar` trong `CategoryProductsScreen`, thay bằng khối Heading cực lớn với định dạng `Women's {tên_danh_mục}` (tự động loại bỏ các từ dư thừa như & / bằng Regex).
  - Tích hợp thanh cuộn ngang "Viên thuốc" (Pills) cho phép chuyển đổi danh mục nhanh chóng.
  - Khởi tạo Widget mới `HorizontalProductCard` phục vụ chế độ xem danh sách (List View). Cho phép linh hoạt chuyển đổi giữa List View và Grid View qua nút bấm.
- **Hiển thị Tags và Giá sản phẩm (Product Card)**:
  - Đồng bộ hoá hoàn toàn logic đọc `tags` từ Backend (`product.tags`) ở cả `ProductCard` (Dạng lưới) và `HorizontalProductCard` (Dạng danh sách). Xóa bỏ hoàn toàn việc dùng biến cờ hardcode.
  - Hỗ trợ hiển thị xếp chồng nhiều Tag cùng lúc (Ví dụ: Sản phẩm vừa có Tag "New" vừa có "Sale").
  - **Logic Giá cho Tag NEW**: Cập nhật font chữ giá gốc của sản phẩm có tag NEW chuẩn Figma (Metropolis, FontWeight.w500, size 14px, line-height 20px, màu đen `#222222`), loại bỏ phần gạch ngang giá giảm.
  - Tăng khoảng cách `margin-bottom` của thẻ sản phẩm dạng danh sách lên `32px` để khung tròn bao quanh trái tim Favorites không đè lên thẻ bên dưới.
- **Thanh Điều Hướng Dưới Cùng (Bottom Navigation Bar)**:
  - Cấu hình quản lý State toàn cục cho Bottom Navigation Bar bằng Riverpod (`navIndexProvider`).
  - Tích hợp thanh điều hướng vào các trang con sâu hơn như `CategoriesScreen` và `CategoryProductsScreen`.
  - Hỗ trợ thao tác vuốt pop-back: Khi ấn vào tab trên thanh điều hướng từ một trang con, hệ thống sẽ sử dụng `Navigator.popUntil` lùi thẳng về thư mục gốc để chuyển tab, giúp giữ vững thanh điều hướng ở mọi nơi mà không bị che mất.
- **[MỚI] Tối ưu UX UI & Sửa lỗi Favorite**:
  - **Tối ưu hiển thị Size**: Ẩn các tiền tố màu sắc khỏi thẻ chọn Size trên Bottom Sheet, chỉ hiển thị tên Size gọn gàng (XS, S, M, L, XL) đúng ý đồ UX của thiết kế.
  - **Khắc phục lỗi Double-Tap**: Triệt tiêu hoàn toàn lỗi người dùng bấm đúp nhanh tay khiến API `/toggle` chạy kép (Thêm xong bị Xóa) bằng cách sử dụng `LoadingOverlay`. Đã nâng cấp hàm `toggle` trong `favorite_provider.dart` kéo dài thời gian duy trì hiệu ứng làm mờ và loading (delay thêm 3 giây) sau khi API phản hồi thành công/thất bại, nhằm chặn mọi hành động bấm đúp liên tục trong thời gian hệ thống render trạng thái thay đổi.
  - **Tối ưu Giao diện Thẻ Sản phẩm (Product Card)**:
    - **Nút Giỏ Hàng**: Phóng to kích thước nút thêm vào giỏ màu đỏ (từ `36x36` lên `44x44`, icon `size: 22`) ở toàn bộ thẻ sản phẩm để người dùng dễ chạm hơn.
    - **Hiển thị Biến Thể**: Cắt chuỗi `variantTitle` gốc từ Backend (vd: "Orange, S") để render thành giao diện chuẩn `Color: Orange   Size: S` qua `RichText`.
    - **Đồng bộ Logic Màu Sao Đánh Giá**: Ngôi sao đã đánh giá (`index < rating`) được tô màu Vàng Cam (`#FFBA49`), ngôi sao trống (hoặc chưa có đánh giá nào) hiển thị màu Xám (`#9B9B9B`).
    - **Ánh xạ SKU**: Đồng bộ hoàn toàn dữ liệu mã SKU (thay thế chữ "Brand Name" tĩnh) cho cả giao diện thẻ lưới, thẻ ngang trên màn hình Home, Shop và Favorites.
## 5. Các bước tiếp theo (Next Steps)
1. **Hoàn thiện UI/UX Danh mục (Shop/Catalog)**: Backend API `GET /api/categories/{id}/products` đã hoàn thiện 100%, sẵn sàng fetch data với cơ chế gửi Token bảo mật.
2. **Triển khai Tính năng Giỏ Hàng (Bag/Cart)**: 
   - Tích hợp sự kiện vào nút "Giỏ Xách" tại các Product Card.
   - Hiển thị danh sách sản phẩm trong giỏ ở Tab Bag.
3. **Quản lý Token & Dio Interceptor**: Xử lý triệt để logic Interceptor của Dio để tự động đính kèm Token hoặc làm mới Token khi hết hạn (Refresh Token).

---
*Lưu ý đối với AI Gemini: Hãy tự động cập nhật lại file này bất cứ khi nào có thay đổi lớn ở Frontend (như thêm màn hình mới, thay đổi thư viện cốt lõi, hay kết nối xong các API quan trọng) để đồng bộ khi commit code lên Github.*

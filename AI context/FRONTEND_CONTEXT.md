# Frontend (Flutter) - AI Context

**Ngày cập nhật**: 07/06/2026
**Dự án**: E-commerce Frontend (Flutter)

## 1. Công nghệ & Kiến trúc
- **Ngôn ngữ**: Dart
- **Framework**: Flutter (Đa nền tảng: Android, iOS, Web, Windows...)

## 2. Trạng thái hiện tại
- Đã cấu trúc thư mục chuẩn (`screens/`, `widgets/`, `services/`, `providers/`).
- Đã áp dụng **Riverpod** làm State Management (`auth_provider.dart`).
- Đã thiết kế các màn hình xác thực tĩnh (Login, Signup, Forgot Password) với UI hiện đại.
- Đã kết nối thành công với REST API Backend (`api_service.dart`) thông qua `Dio`.
- **Luồng Xác thực (Authentication Flow):**
  - Đã tích hợp **Supabase** kết hợp với `google_sign_in` và `flutter_facebook_auth` cho chức năng Social Login (Native Pop-up trên iOS).
  - Đã chốt luồng: Đăng ký thành công (qua Email hoặc Social) -> Chuyển hướng sang trang Login. Từ trang Login nếu đăng nhập thành công -> Chuyển hướng sang trang Home.
  - Backend đã được deploy tại `https://ecommerce-backend-24ii.onrender.com`.

## 3. Các bước tiếp theo (Next Steps)
1. **Hoàn thiện UI/UX**: Phát triển tiếp các luồng chính như trang chủ (Home), chi tiết sản phẩm (Product Detail), giỏ hàng (Cart).
2. **Quản lý Token**: Xử lý logic refresh token và tự động đăng nhập khi mở lại app nếu JWT token vẫn còn hạn.
3. **Phân tích dữ liệu**: Triển khai luồng theo dõi hành vi người dùng nếu cần.

---
*Lưu ý đối với AI Gemini: Hãy tự động cập nhật lại file này bất cứ khi nào có thay đổi lớn ở Frontend (như thêm màn hình mới, thay đổi thư viện cốt lõi, hay kết nối xong các API quan trọng) để đồng bộ khi commit code lên Github.*

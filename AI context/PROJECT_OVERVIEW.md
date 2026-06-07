# 🚀 E-commerce Project Overview

**Ngày cập nhật**: 07/06/2026
**Mục đích**: Tài liệu này đóng vai trò là "bộ nhớ trung tâm" (Central Memory Bank) cho AI và các kỹ sư phần mềm khi làm việc trên dự án E-commerce này. Chứa toàn bộ thông tin mới nhất về kiến trúc, cấu trúc thư mục, công nghệ sử dụng của cả hai phần Frontend (FE) và Backend (BE).

---

## 📂 1. Cấu trúc thư mục tổng quan

Dự án được chia làm 2 phần chính:
- **Frontend (`D:\ecommerce_project\FE\ecommerce`)**: Ứng dụng di động/web được xây dựng bằng **Flutter**.
- **Backend (`D:\ecommerce_project\BE\ecommerce`)**: Hệ thống API máy chủ được xây dựng bằng **Spring Boot** (Java 17).

---

## 🛠️ 2. Chi tiết Backend (BE)
*Thư mục: `D:\ecommerce_project\BE\ecommerce`*

### 2.1 Công nghệ cốt lõi
- **Ngôn ngữ**: Java 17
- **Framework**: Spring Boot
- **Cơ sở dữ liệu**: PostgreSQL (`ecommerce_test`, Port: 5432)
- **Dependencies**: Spring Web, Spring Data JPA, PostgreSQL Driver, Lombok, GraphQL (đã thêm sẵn vào `pom.xml` cho mục đích mở rộng).
- **Công cụ quản lý build**: Maven

### 2.2 Kiến trúc hệ thống
Dự án được thiết kế theo mô hình **5 Tầng (5 Layers)** tiêu chuẩn với tổng cộng 34 bảng CSDL được map thành 170 tệp Java:
1. **Entity**: Ánh xạ CSDL (`@Entity`, `@Table`), sử dụng `UUID` tự động sinh cho toàn bộ PK và FK.
2. **Repository**: Kế thừa `JpaRepository` cho các thao tác CSDL.
3. **Service (Interface)**: Khai báo chuẩn CRUD API.
4. **ServiceImpl**: Thực thi nghiệp vụ (`@Service`, `@Transactional`).
5. **Controller**: Cung cấp RESTful APIs chuẩn (`/api/<entity-plural>`).

### 2.3 Thành tựu hiện tại & Các thiết kế quan trọng
- Đã phân tích 34 bảng (Sản phẩm, Danh mục, Đơn hàng, Biến thể, User, v.v.).
- Đã thiết lập đầy đủ quan hệ JPA:
  - **1-N**: `@OneToMany(mappedBy = "...")` cho 13 bảng chủ chốt.
  - **1-1**: `@OneToOne` cho các liên kết mở rộng.
  - **Đệ quy**: Bảng `Category` (cha - con).
- **Phòng chống đệ quy JSON**: Đã dùng `@JsonIgnore` cho các collection ngược để tránh `StackOverflowError`.
- Các entity trung gian (Many-to-Many) được giữ nguyên và map thành 2 quan hệ One-to-Many để dễ mở rộng.
- Các trường Audit (`created_at`, `updated_at`...) map `@ManyToOne` 1 chiều với `StaffAccount` để tối ưu.
- Fetch type: Sử dụng `fetch = FetchType.LAZY` cho toàn bộ quan hệ `ManyToOne` để tối ưu truy vấn.
- Hệ thống đã build thành công (`mvn clean compile`).

### 2.4 Bước tiếp theo cho Backend
1. **Chạy DB & Hibernate**: Chạy `mvnw spring-boot:run` để tự động DDL tạo 34 bảng trên PostgreSQL.
2. **Business Logic**: Thêm `@Query` và logic nghiệp vụ giỏ hàng, mã giảm giá, tính tiền.
3. **Bảo mật**: Tích hợp Spring Security / OAuth2 cho `Customer` và `StaffAccount`.

---

## 📱 3. Chi tiết Frontend (FE)
*Thư mục: `D:\ecommerce_project\FE\ecommerce`*

### 3.1 Công nghệ cốt lõi
- **Ngôn ngữ**: Dart
- **Framework**: Flutter (Hỗ trợ đa nền tảng: Android, iOS, Web, Windows, macOS, Linux)

### 3.2 Tình trạng hiện tại
- Dự án vừa được khởi tạo mới hoàn toàn bằng công cụ Flutter CLI (`flutter create`).
- Đã chứa đầy đủ các thư mục nền tảng (`android/`, `ios/`, `web/`, v.v.) và file cấu hình `pubspec.yaml`.
- Đang ở trạng thái mặc định ban đầu của một app Flutter.

### 3.3 Bước tiếp theo cho Frontend
1. Cấu trúc lại thư mục code (`lib/`) theo các pattern quản lý state phù hợp (ví dụ: BLOC, Provider, GetX, hoặc Riverpod).
2. Xây dựng các màn hình giao diện UI tĩnh (Home, Product Detail, Cart, Login, v.v.).
3. Kết nối với các RESTful API từ Spring Boot thông qua package như `http` hoặc `dio`.
4. Triển khai phân tích luồng dữ liệu của người dùng, xác thực (Authentication).

---

## 📌 4. Hướng dẫn sử dụng file này
- **Đối với người dùng**: Mỗi khi có thay đổi lớn về kiến trúc hoặc hoàn thành một module tính năng lớn, vui lòng cập nhật lại file này.
- **Đối với AI/LLM**: Luôn tham chiếu đến file này để hiểu bức tranh toàn cảnh, tránh đề xuất giải pháp lệch pha với kiến trúc đã chọn (Java 17 + UUID + Spring Boot ở BE và Flutter ở FE).

# Flutter E-commerce App với Firebase

Đây là một dự án ứng dụng thương mại điện tử đơn giản được xây dựng bằng Flutter và sử dụng Firebase làm backend. Ứng dụng bao gồm các chức năng cơ bản như quản lý sản phẩm, giỏ hàng, và quy trình đặt hàng.

## Tính Năng Chính

- **Xác thực người dùng:** Đăng ký và Đăng nhập (lưu trạng thái bằng `SharedPreferences`).
- **Quản lý sản phẩm:**
  - Hiển thị danh sách sản phẩm theo thời gian thực từ Firestore.
  - Tìm kiếm sản phẩm theo tên, mô tả.
  - Lọc sản phẩm theo danh mục.
  - Xem chi tiết thông tin sản phẩm.
- **Giỏ hàng:**
  - Thêm sản phẩm vào giỏ.
  - Cập nhật số lượng sản phẩm.
  - Xem tổng tiền.
- **Đặt hàng:**
  - Form đặt hàng với địa chỉ và phương thức thanh toán.
  - Cập nhật kho hàng (giảm số lượng khi đặt, tăng lại khi hủy).
- **Lịch sử đơn hàng:**
  - Xem danh sách các đơn hàng đã đặt.
  - Lọc đơn hàng theo trạng thái.
  - Xem chi tiết đơn hàng.
  - Hủy đơn hàng (khi ở trạng thái "pending").
- **Dữ liệu mẫu:** Cung cấp script để tự động tạo dữ liệu mẫu cho `customers`, `products`, và `orders`.

## Hướng Dẫn Cài Đặt và Chạy Dự Án

### 1. Yêu Cầu
- Flutter SDK (phiên bản 3.x trở lên).
- Một IDE như Android Studio hoặc VS Code.
- Một máy ảo Android hoặc thiết bị thật.

### 2. Cấu Hình Firebase
Đây là bước quan trọng nhất.

**a. Tạo Project Firebase:**
   - Truy cập [Firebase Console](https://console.firebase.google.com/) và tạo một project mới.

**b. Đăng ký Ứng Dụng Android:**
   - Trong Project Settings của Firebase, chọn thêm ứng dụng Android.
   - **Android package name:** Nhập chính xác `com.example.msv2351060461`.
   - **App nickname (tùy chọn):** Đặt tên bất kỳ, ví dụ "Bán Hàng App".
   - Nhấn "Register app".

**c. Tải và Đặt File Cấu Hình:**
   - Ở bước tiếp theo, tải về file `google-services.json`.
   - Kéo file này vào thư mục `android/app` trong dự án Flutter của bạn.

**d. Cấu Hình Firestore Database:**
   - Từ menu bên trái của Firebase Console, chọn **Build > Firestore Database**.
   - Nhấn "Create database" và chọn khởi tạo ở chế độ **Production mode**.
   - Sau khi tạo xong, chuyển qua tab **Rules**.
   - Thay thế nội dung mặc định bằng quy tắc sau để cho phép ứng dụng truy cập dữ liệu trong giai đoạn phát triển:
     ```
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           // Cho phép đọc, ghi đến ngày 30/01/2026
           allow read, write: if request.time < timestamp.date(2026, 1, 30);
         }
       }
     }
     ```
   - Nhấn **"Publish"**.

### 3. Chạy Dự Án
**a. Cài đặt các gói phụ thuộc:**
   - Mở terminal trong thư mục gốc của dự án và chạy lệnh:
     ```
     flutter pub get
     ```

**b. (Tùy chọn nhưng khuyến khích) Đẩy Dữ Liệu Mẫu:**
   - Để có dữ liệu để thử nghiệm, hãy chạy script tạo dữ liệu mẫu. Script này sẽ tự động xóa dữ liệu cũ và tạo mới 5 khách hàng, 15 sản phẩm và 8 đơn hàng.
     ```
     flutter run lib/seed_database.dart
     ```
   - Đợi cho đến khi terminal báo `==> SEEDING COMPLETE! <==`.

**c. Chạy Ứng Dụng Chính:**
   - Sau khi có dữ liệu, hãy chạy ứng dụng như bình thường:
     ```
     flutter run
     ```
   - Ứng dụng sẽ khởi động ở màn hình Đăng nhập. Bạn có thể đăng ký một tài khoản mới hoặc đăng nhập bằng một email bất kỳ để bắt đầu.

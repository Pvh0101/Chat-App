# Flutter ChatApp

Ứng dụng nhắn tin đa nền tảng được xây dựng bằng Flutter và Firebase.


## 📋 Mô tả

Flutter ChatApp là một ứng dụng nhắn tin thời gian thực với đầy đủ tính năng, cho phép người dùng gửi tin nhắn, hình ảnh, âm thanh và video. Ứng dụng hỗ trợ cả trò chuyện riêng tư và nhóm, cùng với nhiều tính năng khác.

## ✨ Tính năng

- 🔐 Xác thực bằng số điện thoại
- 💬 Nhắn tin thời gian thực
- 👥 Tạo và quản lý nhóm trò chuyện
- 🌙 Giao diện tối/sáng
- 📷 Chia sẻ hình ảnh, âm thanh và video
- 👍 Phản ứng với tin nhắn
- 📱 Thiết kế responsive trên nhiều nền tảng
- 🔔 Thông báo đẩy (push notifications)
- 👫 Quản lý bạn bè và yêu cầu kết bạn

## 🚀 Cài đặt

1. **Yêu cầu**: 
   - Flutter SDK 3.5.3 trở lên
   - Dart SDK 3.5.3 trở lên
   - Tài khoản Firebase


## 🔧 Cấu hình Firebase

1. Tạo một dự án trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm ứng dụng Android, iOS, web, và các nền tảng khác theo yêu cầu
3. Tải xuống và cấu hình file cấu hình Firebase 
4. Bật các dịch vụ sau trên Firebase:
   - Authentication (xác thực qua số điện thoại)
   - Cloud Firestore
   - Storage
   - Cloud Messaging

## 🏗️ Cấu trúc dự án

```
lib/
├── authentication/    # Màn hình xác thực 
├── main_screen/       # Màn hình chính
├── models/            # Các model dữ liệu
├── providers/         # State management
├── push_notification/ # Dịch vụ thông báo
├── streams/           # Xử lý stream data
├── utilities/         # Các tiện ích
└── widgets/           # Widget tái sử dụng
```

## 📱 Màn hình

- Màn hình đăng nhập
- Xác thực OTP
- Màn hình chính
- Màn hình trò chuyện
- Màn hình hồ sơ
- Cài đặt
- Màn hình bạn bè
- Quản lý nhóm
- Và nhiều màn hình khác...

## 🛠️ Công nghệ sử dụng

- **Frontend**: Flutter
- **State Management**: Provider
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Messaging
- **UI Components**: Material Design 3

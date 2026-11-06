# CafeSpot — CT484 Nhóm Thông & Vương

Ứng dụng **Flutter** giúp khám phá và quản lý danh sách quán cà phê: xem chi tiết, yêu thích, đánh giá, tìm kiếm và cài đặt. Dữ liệu lưu cục bộ bằng **SQLite**, điều hướng bằng **go_router**, quản lý trạng thái bằng **Provider**.

**GitHub:** https://github.com/vuongdc24v7x414/CT484_CafeSpot_ThongVuong

---

## Giới thiệu ứng dụng

CafeSpot mô phỏng quy trình dùng app review quán cà phê hàng ngày:

1. Mở app (Splash) → vào trang chủ xem danh sách quán  
2. Lọc theo danh mục / tìm kiếm  
3. Xem chi tiết, đánh giá, đánh dấu yêu thích  
4. Thêm / sửa / xóa quán  
5. Quản lý đánh giá, cài đặt giao diện và thông báo cục bộ  

Ứng dụng có **≥ 6 màn hình**, bố cục **responsive** (điện thoại dùng NavigationBar, màn rộng dùng NavigationRail), đã tùy biến **tên app, icon và splash screen**.

---

## Thành viên

| MSSV | Họ tên | Phụ trách chính |
|------|--------|-----------------|
| BK24V7X703 | Lưu Minh Thông | Splash, Home, Chi tiết quán, Form thêm/sửa, SQLite, go_router |
| DC24V7X414 | Nguyễn Quốc Vương | Yêu thích, Đánh giá của tôi, Tìm kiếm, Cài đặt, Local notification |

Chi tiết phân công: xem `CONTRIBUTORS.md`.

---

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|------------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| Điều hướng | `go_router` (truyền dữ liệu, custom transition) |
| State management | `provider` (`ChangeNotifier`) |
| Cơ sở dữ liệu cục bộ | `sqflite` + `path` (CRUD quán & đánh giá) |
| Lưu cấu hình | `shared_preferences` (dark mode, tên hiển thị, bật thông báo) |
| Thông báo | `flutter_local_notifications` |
| UI / UX | Material 3, ListView / GridView, responsive layout |
| Branding | `flutter_launcher_icons`, `flutter_native_splash` |

**Kiến trúc code (tóm tắt):**

```
lib/
  main.dart                 # Khởi tạo app, Provider, router
  models/                   # Cafe, Review
  data/                     # DatabaseHelper, CafeRepository
  providers/                # CafeProvider, SettingsProvider
  router/                   # go_router + shell tabs
  screens/                  # Các màn hình UI
  services/                 # NotificationService
  widgets/                  # CafeCard, RatingStars, ResponsiveCenter
  theme/                    # AppTheme
```

---

## Yêu cầu môi trường

- Flutter SDK (stable) — khuyến nghị ≥ 3.22  
- Git  
- Để chạy **Android**:
  - JDK 17 hoặc 21  
  - Android SDK cmdline-tools (không bắt buộc cài Android Studio đầy đủ), gồm tối thiểu:
    - `platform-tools`
    - `platforms;android-36` (Flutter 3.47+)
    - `build-tools;36.0.0`
    - (tuỳ chọn emulator) `emulator` + `system-images;android-34;google_apis;x86_64`  
- Hoặc chạy trên **Chrome** để xem UI nhanh (web không dùng SQLite native; app có fallback bộ nhớ tạm)

---

## Hướng dẫn cài đặt

Xem [hướng dẫn chạy trên máy khác](HUONG_DAN_CHAY_MAY_KHAC.md) để chuẩn bị SDK, JDK và cấu hình máy nhận.

### 1) Cài Flutter

```bash
# Windows: clone Flutter stable rồi thêm vào PATH
git clone https://github.com/flutter/flutter.git -b stable
# Thêm <flutter>/bin vào PATH, sau đó:
flutter doctor
```

### 2) Clone dự án

```bash
git clone https://github.com/vuongdc24v7x414/CT484_CafeSpot_ThongVuong.git
cd CT484_CafeSpot_ThongVuong
flutter pub get
```

### 3) Cài Android SDK siêu nhẹ (không cần Android Studio đầy đủ)

```powershell
# Ví dụ thư mục SDK
$env:ANDROID_HOME = "C:\Android\sdk"
$env:Path = "$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:Path"

# Cài gói tối thiểu (Flutter 3.47 cần platform 36)
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

# (Tuỳ chọn) Emulator nhẹ để chạy / chụp màn hình
sdkmanager "emulator" "platforms;android-34" "system-images;android-34;google_apis;x86_64"
echo no | avdmanager create avd -n CafeSpot_Lite -k "system-images;android-34;google_apis;x86_64" -d pixel_4a --force

flutter config --android-sdk $env:ANDROID_HOME
flutter doctor --android-licenses
```

Chấp nhận các license khi được hỏi (`y`).

Khởi chạy emulator nhẹ:

```powershell
emulator -avd CafeSpot_Lite -no-audio -no-boot-anim -gpu swiftshader_indirect -memory 1536
```

### 4) Chạy ứng dụng

```bash
# Xem thiết bị
flutter devices

# Android emulator / máy thật
flutter run -d <ID_THIET_BI>

# Hoặc Chrome (xem UI nhanh)
flutter run -d chrome
```

### 5) Build APK (tuỳ chọn)

```bash
flutter build apk --debug
# File: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Tính năng đáp ứng tiêu chí CT484

- ≥ 6 màn hình, ListView/GridView, tương tác người dùng, responsive  
- Điều hướng `go_router` (truyền dữ liệu + hiệu ứng chuyển trang)  
- State management: Provider, kiến trúc tách `models / data / providers / screens`  
- Lưu trữ SQLite qua các lần chạy; CRUD thêm/sửa/xóa  
- Local notifications  
- Đổi tên app **CafeSpot**, icon và splash screen  

### Ảnh chụp trên Android emulator

Ảnh thật từ AVD `CafeSpot_Lite` (Android 14) nằm trong `docs/screenshots/android/`:

| Màn hình | File |
|----------|------|
| Splash | `docs/screenshots/android/splash.png` |
| Trang chủ | `docs/screenshots/android/home.png` |
| Yêu thích | `docs/screenshots/android/favorites.png` |
| Đánh giá | `docs/screenshots/android/reviews.png` |
| Tìm kiếm | `docs/screenshots/android/search.png` |
| Cài đặt | `docs/screenshots/android/settings.png` |
| Chi tiết quán | `docs/screenshots/android/detail.png` |
| Form thêm quán | `docs/screenshots/android/form.png` |

Hai báo cáo cá nhân được tạo bằng `docs/build_final_reports.py` với tên `Baocao_BK24V7X703_LuuMinhThong.docx` và `Baocao_DC24V7X414_NguyenQuocVuong.docx`.

---

## Phân công

Xem file `CONTRIBUTORS.md`.

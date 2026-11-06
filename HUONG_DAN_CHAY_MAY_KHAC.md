# Chạy CafeSpot trên máy khác

## Phiên bản và công cụ

- Flutter 3.47.6 stable với Dart 3.13.5, phiên bản SDK dùng để kiểm tra giao diện.
- Android SDK Platform 36, Build-Tools 36.0.0, Platform-Tools, Command-line Tools.
- NDK 28.2.13676358 theo cấu hình Flutter 3.47.6.
- JDK 17 hoặc 21. Máy chuẩn bị dùng JDK 21.
- Gradle 9.3.1, Android Gradle Plugin 9.1.0, Kotlin 2.4.0 theo cấu hình dự án.
- Điện thoại hoặc trình giả lập Android API 24 trở lên.
- Mạng để tải thư viện, công cụ dựng và ảnh quán.

## Giải nén

Dùng đường dẫn ngắn như C:/Projects/CT484_CafeSpot_ThongVuong.
Tránh ký tự & trong đường dẫn. Lần dựng tại máy chuẩn bị đã gặp lỗi do thư mục cha chứa ký tự này.

## Chuẩn bị môi trường

Cài Flutter 3.47.6 và thêm thư mục bin vào PATH.
Cài Android Studio hoặc Android SDK Command-line Tools, JDK và các gói SDK phía trên.
Mở terminal mới và kiểm tra.

~~~powershell
flutter --version
java -version
flutter doctor -v
~~~

Nếu Flutter nhận sai SDK hoặc JDK, thay đường dẫn ví dụ bằng vị trí thật trên máy nhận.

~~~powershell
flutter config --android-sdk "C:/Android/sdk"
flutter config --jdk-dir "C:/Program Files/Java/jdk-21"
flutter doctor --android-licenses
~~~

Đọc và chấp nhận giấy phép khi được yêu cầu.

## Chuẩn bị dự án

Mở terminal tại thư mục chứa pubspec.yaml.

~~~powershell
flutter pub get
flutter doctor -v
flutter devices
~~~

pubspec.lock khóa phiên bản các thư viện. Flutter tạo lại .dart_tool và cấu hình theo máy hiện tại.
Khi chạy hoặc dựng Android, Flutter chuẩn bị android/local.properties chứa flutter.sdk và sdk.dir.
Nếu mở bằng Gradle trực tiếp và bị thiếu tệp này, trước tiên chạy flutter build apk --debug từ thư mục gốc.
Khi cần, tự tạo android/local.properties theo đường dẫn thật trên máy nhận.

~~~properties
flutter.sdk=C:/src/flutter
sdk.dir=C:/Android/sdk
~~~

## Chạy Android

Bật giả lập hoặc kết nối điện thoại đã bật USB debugging.
Dùng ID mà flutter devices liệt kê. emulator-5554 dưới đây là ví dụ.

~~~powershell
flutter run -d emulator-5554
flutter build apk --debug
~~~

APK nằm tại build/app/outputs/flutter-apk/app-debug.apk.
Gói có gradlew, gradlew.bat, gradle-wrapper.jar và gradle-wrapper.properties.
Lần dựng đầu cần tải Gradle và thư viện Android.
Nếu bị timeout, kiểm tra kết nối đến services.gradle.org, Google Maven, Maven Central và pub.dev.

## Cấu hình và dữ liệu

Mã hiện tại dùng SQLite trên Android và SharedPreferences cho cài đặt.
Dự án hoạt động với dữ liệu cục bộ, không cần .env, API key hoặc tài khoản máy chủ.
cafe_spot.db được tạo và nạp bốn quán mẫu khi mở ứng dụng lần đầu.
Mỗi thiết bị có dữ liệu riêng. Dữ liệu quán, đánh giá và cài đặt đang có trên thiết bị của máy gửi không tự chuyển trong ZIP.
Ảnh quán tải từ picsum.photos.

## Nền tảng khác

Gói giữ các thư mục ios, macos, windows, linux và web.
Web dùng MemoryStore, dữ liệu quán và đánh giá chỉ nằm trong phiên.
iOS cần macOS, Xcode và cấu hình ký ứng dụng của người nhận.
Luồng SQLite hiện tập trung vào Android. Cần kiểm tra riêng các chức năng dữ liệu trên Windows, Linux và macOS.

## Phạm vi kiểm tra

- ZIP đọc được, có cấu trúc dự án và các tệp cấu hình bắt buộc.
- Mọi tệp trong ZIP trước được giữ lại. README được cập nhật và thêm hướng dẫn này.
- Kiểm thử Flutter màn Cài đặt trên điện thoại và màn rộng đã đạt.
- Chưa xác nhận dựng APK thành công. Lần thử tại máy chuẩn bị dừng ở bước tải Gradle 9.3.1.
- Chưa kiểm tra trực tiếp trên máy nhận.

## Tài liệu công cụ

https://docs.flutter.dev/platform-integration/android/setup
https://docs.flutter.dev/install/troubleshoot

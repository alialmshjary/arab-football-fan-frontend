# Madraj Frontend Starter

هذا المشروع Starter نظيف للفرونت اند.

## الموجود بالكود

- Core جاهز:
  - API constants
  - API client
  - API response/error handling
  - Storage service
  - Theme
  - Shared widgets
- Auth جاهز:
  - Login
  - Register
  - Logout
  - Token storage
  - GetX binding/controller/service/model
- Home تجريبية فقط بنفس ستايل مدرج.
- باقي الميزات موجودة كهيكلة فارغة:
  - fans
  - posts
  - comments
  - likes
  - bookmarks
  - predictions
  - follow
  - matches
  - chats
  - teams
  - notifications
  - settings

## تشغيل على Android Emulator

شغل الباك اند أولاً، ثم نفذ:

```powershell
flutter clean
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5259
```

## تشغيل على جهاز حقيقي

استبدل 10.0.2.2 بعنوان IP جهاز الكمبيوتر الذي يشغل الباك اند:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5259
```

# خطوات رفع IDRIS Schools إلى Apple App Store

## قبل الرفع

تحتاج:

- جهاز Mac.
- Xcode آخر إصدار متاح.
- حساب Apple Developer فعال.
- إنشاء التطبيق في App Store Connect.
- Bundle ID مطابق:

```text
com.idrisschool.app
```

## البناء من Flutter

افتح Terminal داخل المشروع وشغّل:

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

## الرفع من Xcode

1. افتح:

```text
ios/Runner.xcworkspace
```

2. من Runner > Signing & Capabilities اختار Team.
3. اختار جهاز البناء:

```text
Any iOS Device (arm64)
```

4. اختار:

```text
Product > Archive
```

5. بعد ما يفتح Organizer:

```text
Distribute App > App Store Connect > Upload
```

## وصف النسخة المقترح

```text
Improved online student discussion stability and interactive learning experience.
```

أو بالعربي:

```text
تحسين استقرار المناقشات وتجربة الطالب في المحتوى التفاعلي.
```

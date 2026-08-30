# إصلاح iOS Blank Screen - IDRIS Schools V28

تم تجهيز هذه النسخة خصيصاً لإعادة الإرسال إلى Apple بعد رفض التطبيق بسبب شاشة داكنة ثابتة بعد اللوقو.

## التعديل الجذري
- `runApp` أصبح يبدأ فوراً، بدون انتظار `SystemChrome`.
- إعدادات System UI أصبحت تعمل بعد تشغيل الواجهة وبشكل آمن.
- Splash صار عنده fallback navigation حتى لا يعلق على iOS.
- لو فشل تحميل الجلسة المحفوظة، التطبيق يدخل للصفحة الرئيسية بدل شاشة فاضية.
- خلفية iOS Main storyboard صارت بيضاء بدل الداكنة.
- النسخة أصبحت `1.0.28+28`.

## الملفات المعدلة
- `lib/main.dart`
- `lib/features/splash/splash_screen.dart`
- `ios/Runner/Base.lproj/Main.storyboard`
- `pubspec.yaml`

## لم يتم لمس
- عرض PDF
- عرض الفيديوهات والتسجيلات
- Google Drive
- منصة الأونلاين
- الديسكشن
- الاختبارات والكويز
- دخول الطلاب
- الداش بورد

## خطوات Apple
1. افتح المشروع على Mac.
2. نفذ:

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ipa --release
```

3. أو افتح `ios/Runner.xcworkspace` في Xcode واعمل Archive.
4. ارفع Build رقم 28 إلى App Store Connect.

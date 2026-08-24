نسخة AAB Build Ready:

هذه النسخة مخصصة لاستخراج ملف Android App Bundle بصيغة .aab.

لا يوجد داخلها:
- upload-keystore.jks
- android/key.properties
- signingConfigs مخصص

الأوامر داخل FlutLab Terminal:
flutter clean
flutter pub get
flutter build appbundle --release

الملف الناتج:
build/app/outputs/bundle/release/app-release.aab

ملاحظة مهمة:
لو الرفع في Google Play طلب توقيع، استخدم Signing الموجود في FlutLab أو Play App Signing، ولا تضف signingConfigs يدوياً داخل build.gradle.

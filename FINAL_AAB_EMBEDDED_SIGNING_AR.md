حل جذري لتوليد AAB - IDRIS Schools

هذه النسخة فيها التوقيع داخل المشروع نفسه.

مهم جداً:
- لا تضف Signing من FlutLab.
- لا ترفع keystore في Android Signing داخل FlutLab.
- لو عندك Signing محفوظ في FlutLab للمشروع القديم، احذف المشروع القديم واعمل مشروع جديد.
- ارفع هذا الملف فقط كمشروع جديد:
  IDRIS_Schools_AAB_FINAL_EMBEDDED_SIGNING.zip

الأوامر / أو زر Build:
flutter clean
flutter pub get
flutter build appbundle --release

الملف الناتج:
build/app/outputs/bundle/release/app-release.aab

بيانات التوقيع المحفوظة داخل المشروع:
Keystore:
android/app/upload-keystore.jks

key.properties:
android/key.properties

Alias:
idrisupload

Store password:
IdrisSchools2026

Key password:
IdrisSchools2026

مهم جداً جداً:
احتفظ بنسخة IDRIS_Schools_UPLOAD_KEY_BACKUP_KEEP_SAFE.zip في مكان آمن.
أي تحديث مستقبلي في Google Play سيحتاج نفس ملف التوقيع.

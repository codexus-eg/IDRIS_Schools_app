# IDRIS Schools - Build AAB with GitHub Actions

دي نسخة جاهزة للحل الجذري بعيداً عن FlutLab.

## الطريقة

1. افتح github.com.
2. اعمل Repository جديد باسم مثلاً:
   IDRIS-Schools-App

3. ارفع كل ملفات المشروع الموجودة في هذا الملف المضغوط داخل الـ Repository.

4. ادخل تبويب:
   Actions

5. اختار:
   Build IDRIS Schools AAB

6. اضغط:
   Run workflow

7. انتظر البناء يخلص.

8. من آخر الصفحة حتلقى:
   Artifacts

9. نزّل:
   IDRIS-Schools-app-release-aab

دا داخله ملف:
   app-release.aab

## مهم

هذه النسخة فيها التوقيع مدمج داخل المشروع:
- android/app/upload-keystore.jks
- android/key.properties

لا تضيف أي توقيع من FlutLab.
لا تحتاج FlutLab أصلاً للبندل.

ملف الـ AAB النهائي سيكون جاهز للرفع في Google Play Console.

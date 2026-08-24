# إصلاح Build AAB - Gradle + AGP معاً

هذا الباتش يعالج فشل GitHub Actions بسبب عدم توافق Flutter الجديد مع نسخ Gradle/AGP القديمة.

## الملفات المعدلة فقط

- `android/settings.gradle`
- `android/gradle/wrapper/gradle-wrapper.properties`

## القيم النهائية

- Android Gradle Plugin: `8.11.1`
- Gradle Wrapper: `8.14.3`

## ملاحظات

لم يتم تعديل أي منطق في التطبيق، ولا التصميم، ولا الأيقونات، ولا package/bundle، ولا PDF/video viewer، ولا Google Drive، ولا منصة الأونلاين.

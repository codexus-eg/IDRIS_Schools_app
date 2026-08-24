# إصلاح فشل GitHub Actions - Android Gradle Plugin

تم إصلاح خطأ بناء AAB الذي ظهر في GitHub Actions:

```
Dependency androidx.browser:browser:1.9.0 requires Android Gradle plugin 8.9.1 or higher.
This build currently uses Android Gradle Plugin 8.7.3.
```

## التعديل المنفذ

- تحديث Android Gradle Plugin من `8.7.3` إلى `8.9.1`.
- تحديث Gradle Wrapper من `8.9` إلى `8.11.1` للتوافق مع AGP 8.9.1.

## الملفات المعدلة

- `android/settings.gradle`
- `android/gradle/wrapper/gradle-wrapper.properties`

## طريقة الاستخدام

انسخ النسخة الكاملة المعدلة إلى GitHub Desktop، ثم اعمل Commit و Push.
بعدها افتح Actions وانتظر نجاح Build IDRIS Schools AAB.

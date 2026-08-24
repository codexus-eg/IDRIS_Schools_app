# إصلاح Android Gradle Plugin 8.11.1

تم إصلاح فشل بناء AAB في GitHub Actions بسبب أن Flutter الحالي يتطلب Android Gradle Plugin 8.11.1 أو أعلى.

## الملف المعدل فقط

- `android/settings.gradle`

## التعديل

من:

```gradle
id "com.android.application" version "8.9.1" apply false
```

إلى:

```gradle
id "com.android.application" version "8.11.1" apply false
```

## لم يتم تغيير

- منطق التطبيق
- التصميم
- Bundle ID / Package Name
- اللوقو
- عرض PDF والفيديوهات والتسجيلات
- Google Drive
- منصة الأونلاين
- الديسكشن والامتحانات

بعد الرفع إلى GitHub اعمل Commit و Push ثم شغل GitHub Actions مرة أخرى.

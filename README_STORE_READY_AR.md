# IDRIS Schools — نسخة GitHub / Google Play / Apple App Store جاهزة

هذه النسخة مبنية على آخر إصلاح معتمد V27، ورقم الإصدار:

```text
1.0.27+27
```

## ما الموجود في النسخة؟

- مشروع Flutter كامل.
- إعدادات Android جاهزة لبناء AAB عبر GitHub Actions.
- إعدادات iOS موجودة وجاهزة للفتح في Xcode.
- إضافة صلاحيات iOS اللازمة للمرفقات: الصور/الكاميرا/الميكروفون عند الحاجة.
- لم يتم تغيير منطق التطبيق أو عرض الملفات أو الفيديوهات أو التسجيلات.

## بناء Android AAB من GitHub

1. ارفع محتويات هذا المجلد إلى GitHub.
2. افتح تبويب **Actions**.
3. اختار **Build IDRIS Schools AAB**.
4. اضغط **Run workflow** أو اعمل Push على main.
5. بعد نجاح البناء، افتح الـ Run ثم **Artifacts**.
6. نزّل ملف:

```text
IDRIS-Schools-1.0.27+27-app-release-aab
```

داخله ستجد:

```text
app-release.aab
```

ارفعه في Google Play Console داخل Production أو مسار الاختبار المطلوب.

## تجهيز Apple App Store

لا يمكن إنشاء ملف App Store النهائي بدون حساب Apple Developer والتوقيع الخاص بك. المطلوب على جهاز Mac:

1. افتح المشروع في Xcode من:

```text
ios/Runner.xcworkspace
```

2. افتح Runner > Signing & Capabilities.
3. اختار Team الخاص بحساب Apple Developer.
4. تأكد من Bundle ID:

```text
com.idrisschool.app
```

5. من Xcode اختار:

```text
Product > Archive
```

6. بعد انتهاء الأرشفة اختار:

```text
Distribute App > App Store Connect > Upload
```

أو استخدم تطبيق Transporter من Apple لو خرجت ملف IPA.

## ملاحظة مهمة

ملف Android upload key مضمّن داخل المشروع لأن البناء السابق كان يعتمد عليه. احفظ نسخة احتياطية منه ولا تنشر المشروع في GitHub عام Public.

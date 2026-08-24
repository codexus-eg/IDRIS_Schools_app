# إصلاح خطأ Splash Animation

سبب الخطأ:
`Curves.easeOutBack` قد ترجع قيمة أكبر من 1 بصورة مقصودة لعمل الارتداد.
الكود السابق مرر هذه القيمة إلى Curve أخرى وOpacity، وهما يقبلان فقط 0 إلى 1.

تم الإصلاح في:
- `lib/features/splash/widgets/animated_school_logo.dart`
- `lib/features/splash/splash_screen.dart`

في مشروع FlutterLab الموجود بالفعل:
استبدل الملفين أعلاه بالنسخ المصححة، ثم نفّذ Hot Restart وليس Hot Reload فقط.

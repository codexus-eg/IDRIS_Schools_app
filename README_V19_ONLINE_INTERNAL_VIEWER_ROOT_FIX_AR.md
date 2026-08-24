# IDRIS Schools V19 — إصلاح جذري لعارض الملفات وكروت الأونلاين

رقم النسخة: `1.0.19+19`

## التشخيص

خطأ FlutLab/Web Preview كان بسبب استدعاء `WebViewController().setJavaScriptMode()` على منصة Web. إضافة `webview_flutter_web` وحدها لا تكفي لأن بعض دوال الـController غير منفذة على Web.

## الإصلاح

- في Android/iOS: يستمر استخدام `webview_flutter` لفتح الملفات داخلياً.
- في Web/FlutLab Preview: يتم استخدام `HtmlElementView` + iframe داخلي بدلاً من WebViewController.
- لا يتم فتح PDF / الصور / الفيديو / PowerPoint خارج التطبيق.
- تحسين قراءة بيانات عناصر الأونلاين حتى لا تظهر عناوين فارغة.
- تحسين رسالة الخطأ عند فشل تحميل API المنصة.

## الملفات المعدلة

- `pubspec.yaml`
- `lib/features/student/screens/internal_file_viewer_screen.dart`
- `lib/features/student/services/learning_content_service.dart`
- `lib/features/student/screens/learning_content_screen.dart`
- `lib/features/student/widgets/internal_web_html_viewer_stub.dart`
- `lib/features/student/widgets/internal_web_html_viewer_web.dart`

# IDRIS Schools V27 - إصلاح Discussion setState

هذا الإصلاح لا يلمس عرض PDF ولا الفيديوهات ولا التسجيلات ولا Google Drive ولا منصة الأونلاين.

التعديل المحدد:
- إصلاح خطأ Flutter: setState() callback argument returned a Future.
- السبب كان تحديث Future داخل setState بتعبير يرجع Future.
- تم تحويل التحديث إلى block sync داخل Discussion.
- تم إصلاح نفس النمط في Live Classes و Exams refresh حتى لا يظهر نفس الخطأ لاحقاً.

رقم النسخة: 1.0.27+27

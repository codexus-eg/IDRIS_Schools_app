import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// صفحة مؤقتة فقط لكي يعمل الانتقال بعد شاشة البداية.
/// سنستبدلها في الخطوة القادمة بصفحة تسجيل الدخول الحقيقية.
class NextPagePlaceholder extends StatelessWidget {
  const NextPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.softWhite,
      body: Center(
        child: Text(
          'تم تشغيل شاشة البداية بنجاح',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.navy900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

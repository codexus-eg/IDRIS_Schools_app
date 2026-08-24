import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key, required this.isArabic, required this.phone, required this.otpToken});
  final bool isArabic;
  final String phone;
  final String otpToken;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isArabic ? 'تم إلغاء OTP' : 'OTP disabled')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isArabic ? 'الدخول المعتمد الآن بكلمة المرور وليس OTP.' : 'The approved login flow now uses password, not OTP.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.navy950, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

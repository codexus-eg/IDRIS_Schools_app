import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ModernLoadingBar extends StatelessWidget {
  const ModernLoadingBar({super.key, required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final double progress = animation.value.clamp(0.0, 1.0).toDouble();
        final String text = _statusText(progress);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: AppColors.navy900.withOpacity(0.08)),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.electricBlue,
                                AppColors.schoolRed,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(
                text,
                key: ValueKey<String>(text),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppColors.navy700,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusText(double progress) {
    if (progress < 0.32) return 'تهيئة التطبيق';
    if (progress < 0.64) return 'تجهيز بيانات المدرسة';
    if (progress < 0.92) return 'إعداد تجربة الطالب';
    return 'جاهز للانطلاق';
  }
}

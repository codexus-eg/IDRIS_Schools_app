import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ModernSplashBackground extends StatelessWidget {
  const ModernSplashBackground({super.key, required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _ModernSplashBackgroundPainter(
              progress: animation.value.clamp(0.0, 1.0).toDouble(),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ModernSplashBackgroundPainter extends CustomPainter {
  const _ModernSplashBackgroundPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screen = Offset.zero & size;

    canvas.drawRect(
      screen,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FBFF), Color(0xFFEFF5FF), Color(0xFFFFFFFF)],
          stops: [0.0, 0.58, 1.0],
        ).createShader(screen),
    );

    _softCircle(canvas, Offset(size.width * 0.10, size.height * 0.08),
        size.width * 0.46, AppColors.electricBlue.withOpacity(0.15));
    _softCircle(canvas, Offset(size.width * 0.92, size.height * 0.30),
        size.width * 0.38, AppColors.schoolRed.withOpacity(0.10));
    _softCircle(canvas, Offset(size.width * 0.55, size.height * 0.86),
        size.width * 0.60, AppColors.primaryBlue.withOpacity(0.10));

    _drawGrid(canvas, size);
    _drawDots(canvas, size);
    _drawBottomCurve(canvas, size);
  }

  void _softCircle(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.navy900.withOpacity(0.024)
      ..strokeWidth = 1;

    const double step = 36;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDots(Canvas canvas, Size size) {
    final Paint paint = Paint();
    for (int i = 0; i < 26; i++) {
      final double seed = i * 9.73;
      final double x = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final double y = ((math.cos(seed * 1.31) * 0.5 + 0.5) * size.height +
              progress * (14 + i % 6) * 2) %
          size.height;

      paint.color = (i % 6 == 0
              ? AppColors.schoolRed
              : i % 3 == 0
                  ? AppColors.electricBlue
                  : AppColors.primaryBlue)
          .withOpacity(0.055 + (i % 4) * 0.018);

      canvas.drawCircle(Offset(x, y), 1.7 + (i % 3) * 0.55, paint);
    }
  }

  void _drawBottomCurve(Canvas canvas, Size size) {
    final Path blue = Path()
      ..moveTo(0, size.height * 0.91)
      ..cubicTo(size.width * 0.22, size.height * 0.86, size.width * 0.42,
          size.height * 0.97, size.width * 0.70, size.height * 0.91)
      ..cubicTo(size.width * 0.84, size.height * 0.88, size.width * 0.93,
          size.height * 0.91, size.width, size.height * 0.87)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(blue, Paint()..color = AppColors.primaryBlue.withOpacity(0.94));

    final Path red = Path()
      ..moveTo(0, size.height * 0.95)
      ..cubicTo(size.width * 0.25, size.height * 0.90, size.width * 0.52,
          size.height * 0.99, size.width, size.height * 0.92)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(red, Paint()..color = AppColors.schoolRed.withOpacity(0.97));
  }

  @override
  bool shouldRepaint(covariant _ModernSplashBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

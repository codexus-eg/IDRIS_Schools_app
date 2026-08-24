import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class ModernLogoCard extends StatelessWidget {
  const ModernLogoCard({
    super.key,
    required this.animation,
    required this.pulseAnimation,
  });

  final Animation<double> animation;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, pulseAnimation]),
      builder: (context, _) {
        final double value = animation.value.clamp(0.0, 1.0).toDouble();
        final double pulse = pulseAnimation.value.clamp(0.0, 1.0).toDouble();
        final double scale = 0.90 + 0.10 * Curves.easeOutCubic.transform(value);
        final double y = 28 * (1 - value);

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, y),
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 24),
                    child: Container(
                      width: 214,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.navy900.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.16),
                            blurRadius: 35,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(44),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 222,
                        height: 222,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.76),
                          borderRadius: BorderRadius.circular(44),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.95),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy900.withOpacity(0.11),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: AppColors.electricBlue
                                  .withOpacity(0.10 + pulse * 0.05),
                              blurRadius: 28,
                              offset: const Offset(-10, -8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -36,
                              top: -42,
                              child: _SoftCircle(
                                size: 126,
                                color: AppColors.electricBlue.withOpacity(0.13),
                              ),
                            ),
                            Positioned(
                              left: -36,
                              bottom: -44,
                              child: _SoftCircle(
                                size: 122,
                                color: AppColors.schoolRed.withOpacity(0.11),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Image.asset(
                                  AppAssets.splashLogo,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 12,
                    child: _MiniStatusDot(
                      color: AppColors.schoolRed,
                      opacity: 0.55 + pulse * 0.35,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: _MiniStatusDot(
                      color: AppColors.electricBlue,
                      opacity: 0.55 + (1 - pulse) * 0.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _MiniStatusDot extends StatelessWidget {
  const _MiniStatusDot({required this.color, required this.opacity});
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.24),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

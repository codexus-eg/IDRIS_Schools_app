import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppResponsive {
  AppResponsive._(this.context)
      : size = MediaQuery.sizeOf(context),
        textScaler = MediaQuery.textScalerOf(context);

  final BuildContext context;
  final Size size;
  final TextScaler textScaler;

  static AppResponsive of(BuildContext context) => AppResponsive._(context);

  double get width => size.width;
  double get height => size.height;

  /// مبني على عرض 390 كتصميم قياسي، مع حد أدنى وأعلى حتى لا يخرب الشكل.
  double get scale => (width / 390.0).clamp(0.84, 1.18).toDouble();

  double s(double value) => value * scale;

  double sp(double value) => (value * scale).clamp(value * 0.86, value * 1.16).toDouble();

  double get pagePadding => s(width < 360 ? 16 : 20);

  double radius(double value) => s(value).clamp(value * 0.86, value * 1.12).toDouble();

  int gridCount({int small = 2, int large = 3}) {
    if (width < 360) return small;
    if (width > 520) return large;
    return small;
  }

  double safeImageHeight({double min = 150, double max = 230}) {
    return math.min(max, math.max(min, width * 0.46));
  }
}

abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  /// Alias فقط لمنع أي ملف قديم من كسر البناء.
  /// المسار الحقيقي بعد الـSplash هو home.
  static const String next = home;
}

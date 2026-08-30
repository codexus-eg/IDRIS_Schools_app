import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/models/app_user_session.dart';
import '../../core/services/app_session_service.dart';
import '../student/screens/public_student_home_screen.dart';
import '../student/screens/school_student_home_screen.dart';
import 'widgets/modern_loading_bar.dart';
import 'widgets/modern_logo_card.dart';
import 'widgets/modern_splash_background.dart';

/// Splash مودرن ونظيف، مدته خمس ثوانٍ ثابتة.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextRoute = AppRoutes.home,
    this.autoNavigate = true,
  });

  final String nextRoute;
  final bool autoNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _duration = Duration(seconds: 5);

  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  Timer? _navigationTimer;
  bool _didNavigate = false;

  late final Animation<double> _logoAnimation;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _subtitleAnimation;
  late final Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _mainController = AnimationController(vsync: this, duration: _duration);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _logoAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.04, 0.38, curve: Curves.easeOutCubic),
    );

    _titleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.27, 0.50, curve: Curves.easeOutCubic),
    );

    _subtitleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.38, 0.62, curve: Curves.easeOutCubic),
    );

    _loadingAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.linear,
    );

    _mainController.addStatusListener(_onStatusChanged);
    _mainController.forward();

    // حماية إضافية للـ iOS release: لو AnimationStatus ما وصل لأي سبب،
    // أو حصل تأخير في أول frame، نكمل الانتقال بدلاً من شاشة فاضية.
    _navigationTimer = Timer(
      _duration + const Duration(milliseconds: 350),
      () => unawaited(_navigateAfterSplash()),
    );
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    unawaited(_navigateAfterSplash());
  }

  Future<void> _navigateAfterSplash() async {
    if (_didNavigate || !mounted || !widget.autoNavigate) return;
    _didNavigate = true;
    _navigationTimer?.cancel();

    AppUserSession? session;
    try {
      session =
          await AppSessionService().load().timeout(const Duration(seconds: 2));
    } on Object {
      // لو SharedPreferences أو أي plugin اتأخر في iOS، ما نوقف التطبيق.
      session = null;
    }

    if (!mounted) return;

    if (session != null && session.token.isNotEmpty) {
      final Widget screen = session.userType == AppUserType.schoolStudent
          ? SchoolStudentHomeScreen(session: session)
          : session.userType == AppUserType.onlineStudent
              ? OnlineStudentHomeScreen(session: session)
              : PublicStudentHomeScreen(session: session);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mainController
      ..removeStatusListener(_onStatusChanged)
      ..dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ModernSplashBackground(animation: _mainController),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 30),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: _LanguageChip(animation: _subtitleAnimation),
                  ),
                  const Spacer(flex: 2),
                  ModernLogoCard(
                    animation: _logoAnimation,
                    pulseAnimation: _pulseController,
                  ),
                  SizedBox(height: screen.height * 0.045),
                  _FadeSlide(
                    animation: _titleAnimation,
                    dy: 22,
                    child: const Text(
                      'مؤسسة إدريس',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.navy950,
                        fontSize: 34,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  _FadeSlide(
                    animation: _titleAnimation,
                    dy: 18,
                    child: const Text(
                      'التربوية التعليمية الخاصة',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.schoolRed,
                        fontSize: 16.5,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FadeSlide(
                    animation: _subtitleAnimation,
                    dy: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.74),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.11),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy900.withOpacity(0.055),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Text(
                        'بكم نسعى دوماً نحو النجاح',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: AppColors.navy700,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  ModernLoadingBar(animation: _loadingAnimation),
                  SizedBox(height: screen.height * 0.065),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return _FadeSlide(
      animation: animation,
      dy: -10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.navy900.withOpacity(0.08)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AR',
                style: TextStyle(
                    color: AppColors.schoolRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
            SizedBox(width: 7),
            Icon(Icons.language_rounded,
                size: 16, color: AppColors.primaryBlue),
            SizedBox(width: 7),
            Text('EN',
                style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({
    required this.animation,
    required this.child,
    required this.dy,
  });

  final Animation<double> animation;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final double value = animation.value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, dy * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

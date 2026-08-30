import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // امنع شاشة سوداء صامتة في iOS release لو حصل خطأ غير متوقع.
    // الأخطاء تظل تظهر في debug logs، لكن التطبيق يكمل عرض الواجهة.
    return true;
  };

  // مهم جداً في iOS: شغل الواجهة فوراً ولا تنتظر SystemChrome قبل runApp.
  // الانتظار قبل runApp ممكن يترك FlutterViewController على شاشة Native فاضية.
  runApp(const IdrisSchoolApp());

  unawaited(_configureSystemUi());
}

Future<void> _configureSystemUi() async {
  try {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  } on Object {
    // لا توقف تشغيل التطبيق لو iOS رفض/أخر استدعاء SystemChrome.
  }
}

class IdrisSchoolApp extends StatelessWidget {
  const IdrisSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IDRIS Schools',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.schoolRed,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(
              nextRoute: AppRoutes.home,
            ),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}

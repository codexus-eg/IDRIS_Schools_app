رجعنا لطريقة البناء المستقرة قبل إعدادات Play Store:
- لا يوجد upload-keystore.jks
- لا يوجد android/key.properties
- لا يوجد signingConfigs مخصص
- Release يستخدم debug signing فقط حتى يبني APK في FlutLab
- NDK ثابت على 27.0.12077973
- تم حذف أي dependency باسم clean إن وجدت

الأوامر:
flutter clean
flutter pub get
flutter build apk --release

الملف الناتج:
build/app/outputs/flutter-apk/app-release.apk

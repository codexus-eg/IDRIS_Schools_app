import 'package:flutter/material.dart';

class AppHomeImage {
  const AppHomeImage({
    required this.imageUrl,
    required this.captionAr,
    required this.captionEn,
  });

  final String imageUrl;
  final String captionAr;
  final String captionEn;

  factory AppHomeImage.fromJson(Map<String, dynamic> json) {
    return AppHomeImage(
      imageUrl: '${json['image_url'] ?? ''}',
      captionAr: '${json['caption_ar'] ?? ''}',
      captionEn: '${json['caption_en'] ?? ''}',
    );
  }
}

class AppHomePage {
  const AppHomePage({
    required this.key,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.heroImageUrl,
    required this.images,
  });

  final String key;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? heroImageUrl;
  final List<AppHomeImage> images;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;

  String body(bool isArabic) => isArabic ? bodyAr : bodyEn;

  IconData get icon {
    switch (key) {
      case 'branches':
        return Icons.location_city_rounded;
      case 'curricula':
        return Icons.menu_book_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'about':
      default:
        return Icons.info_outline_rounded;
    }
  }

  factory AppHomePage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawImages = json['images'] is List ? json['images'] as List<dynamic> : <dynamic>[];

    return AppHomePage(
      key: '${json['key'] ?? ''}',
      titleAr: '${json['title_ar'] ?? ''}',
      titleEn: '${json['title_en'] ?? ''}',
      bodyAr: '${json['body_ar'] ?? ''}',
      bodyEn: '${json['body_en'] ?? ''}',
      heroImageUrl: '${json['hero_image_url'] ?? ''}'.trim().isEmpty
          ? null
          : '${json['hero_image_url']}',
      images: rawImages
          .whereType<Map<String, dynamic>>()
          .map(AppHomeImage.fromJson)
          .where((image) => image.imageUrl.trim().isNotEmpty)
          .toList(),
    );
  }

  static List<AppHomePage> fallback() {
    return const [
      AppHomePage(
        key: 'about',
        titleAr: 'عنا',
        titleEn: 'About',
        bodyAr: 'بوابة تعليمية حديثة تربط الطالب وولي الأمر والمدرسة في مكان واحد، وتدعم المنهجين السوداني وكامبريدج.',
        bodyEn: 'A modern education portal connecting students, parents, and school services in one place.',
        heroImageUrl: null,
        images: [],
      ),
      AppHomePage(
        key: 'branches',
        titleAr: 'فروعنا',
        titleEn: 'Branches',
        bodyAr: 'يمكن إدارة فروع المدرسة وصورها ومحتواها من داش بورد التطبيق.',
        bodyEn: 'School branches, images, and content are managed from the app dashboard.',
        heroImageUrl: null,
        images: [],
      ),
      AppHomePage(
        key: 'curricula',
        titleAr: 'المناهج',
        titleEn: 'Curricula',
        bodyAr: 'يدعم التطبيق المنهج السوداني ومنهج كامبريدج مع محتوى حسب الصف والمنهج.',
        bodyEn: 'The app supports the Sudanese and Cambridge curricula with grade-based content.',
        heroImageUrl: null,
        images: [],
      ),
      AppHomePage(
        key: 'calendar',
        titleAr: 'التقويم',
        titleEn: 'Calendar',
        bodyAr: 'سيظهر التقويم الدراسي حسب العام الدراسي النشط في داش بورد التطبيق.',
        bodyEn: 'The academic calendar appears according to the active academic year in the dashboard.',
        heroImageUrl: null,
        images: [],
      ),
    ];
  }
}

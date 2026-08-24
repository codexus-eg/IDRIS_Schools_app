import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../models/app_home_page.dart';

class AppHomeContentResult {
  const AppHomeContentResult({
    required this.pages,
    required this.defaultTab,
  });

  final List<AppHomePage> pages;
  final String defaultTab;
}

class AppHomeContentService {
  Future<AppHomeContentResult> fetchHomeContent() async {
    final http.Response response = await http
        .get(Uri.parse(AppApiConfig.appHomeContent))
        .timeout(const Duration(seconds: 18));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('Dashboard API returned success=false');
    }

    final List<dynamic> rawTabs = data['tabs'] is List ? data['tabs'] as List<dynamic> : <dynamic>[];

    final List<AppHomePage> pages = rawTabs
        .whereType<Map<String, dynamic>>()
        .map(AppHomePage.fromJson)
        .where((page) => page.key.trim().isNotEmpty)
        .toList();

    if (pages.isEmpty) {
      throw StateError('No app pages returned from dashboard');
    }

    return AppHomeContentResult(
      pages: pages,
      defaultTab: '${data['default_tab'] ?? 'about'}',
    );
  }
}

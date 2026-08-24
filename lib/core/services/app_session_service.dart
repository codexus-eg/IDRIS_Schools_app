import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user_session.dart';

class AppSessionService {
  static const String _prefix = 'idris_app_session_';

  Future<void> save(AppUserSession session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, String> data = session.toStorage();
    for (final MapEntry<String, String> entry in data.entries) {
      await prefs.setString('$_prefix${entry.key}', entry.value);
    }
  }

  Future<AppUserSession?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('${_prefix}token') ?? '';
    if (token.isEmpty) return null;

    return AppUserSession.fromStorage({
      'user_type': prefs.getString('${_prefix}user_type') ?? '',
      'token': token,
      'name': prefs.getString('${_prefix}name') ?? '',
      'language': prefs.getString('${_prefix}language') ?? 'ar',
      'student_code': prefs.getString('${_prefix}student_code') ?? '',
      'grade': prefs.getString('${_prefix}grade') ?? '',
      'study_section': prefs.getString('${_prefix}study_section') ?? '',
      'branch_name': prefs.getString('${_prefix}branch_name') ?? '',
      'online_user_id': prefs.getString('${_prefix}online_user_id') ?? '',
      'online_grade_id': prefs.getString('${_prefix}online_grade_id') ?? '',
    });
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (final String key in prefs.getKeys().where((key) => key.startsWith(_prefix)).toList()) {
      await prefs.remove(key);
    }
  }
}

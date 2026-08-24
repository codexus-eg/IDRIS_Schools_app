import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class LocalSession {
  const LocalSession({
    required this.phone,
    required this.deviceId,
    required this.token,
    required this.savedAt,
  });

  final String phone;
  final String deviceId;
  final String token;
  final DateTime savedAt;
}

class LocalSessionService {
  static const String _phoneKey = 'mobile_session_phone';
  static const String _deviceIdKey = 'mobile_session_device_id';
  static const String _tokenKey = 'mobile_session_token';
  static const String _savedAtKey = 'mobile_session_saved_at';

  Future<String> getOrCreateDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_deviceIdKey);

    if (saved != null && saved.isNotEmpty) return saved;

    final Random random = Random.secure();
    final String generated =
        'dev_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999999)}';

    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  Future<void> saveSession({
    required String phone,
    required String token,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String deviceId = await getOrCreateDeviceId();

    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_deviceIdKey, deviceId);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_savedAtKey, DateTime.now().toIso8601String());
  }

  Future<LocalSession?> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? phone = prefs.getString(_phoneKey);
    final String? deviceId = prefs.getString(_deviceIdKey);
    final String? token = prefs.getString(_tokenKey);
    final String? savedAt = prefs.getString(_savedAtKey);

    if (phone == null || deviceId == null || token == null || savedAt == null) {
      return null;
    }

    return LocalSession(
      phone: phone,
      deviceId: deviceId,
      token: token,
      savedAt: DateTime.tryParse(savedAt) ?? DateTime.now(),
    );
  }

  Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_savedAtKey);
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/services/local_session_service.dart';

class AuthActionResult {
  const AuthActionResult({required this.success, required this.message, this.session});

  final bool success;
  final String message;
  final AppUserSession? session;
}

class AuthApiService {
  final LocalSessionService _localSessionService = LocalSessionService();

  Future<AuthActionResult> registerPublicStudent({
    required String fullName,
    required String phone,
    required String password,
    required String curriculum,
    required String grade,
  }) async {
    return _postSession(
      url: AppApiConfig.registerPublicStudent,
      userType: AppUserType.publicStudent,
      body: {
        'full_name': fullName,
        'phone': phone,
        'password': password,
        'curriculum': curriculum,
        'study_section': curriculum == 'cambridge' ? 'english' : 'arabic',
        'grade': grade,
      },
    );
  }

  Future<AuthActionResult> loginPublicStudent({
    required String phone,
    required String password,
  }) async {
    return _postSession(
      url: AppApiConfig.publicStudentLogin,
      userType: AppUserType.publicStudent,
      body: {'phone': phone, 'password': password},
    );
  }


  Future<AuthActionResult> loginOnlineStudent({
    required String username,
    required String password,
  }) async {
    return _postSession(
      url: AppApiConfig.onlineStudentLogin,
      userType: AppUserType.onlineStudent,
      body: {'username': username, 'password': password},
    );
  }

  /// طالب المدرسة يدخل فقط بالسيريال وأي رقم من أرقامه المسجلة في ERP.
  /// لا توجد كلمة مرور ولا تفعيل أول مرة.
  Future<AuthActionResult> loginSchoolStudent({
    required String studentCode,
    required String phone,
  }) async {
    return _postSession(
      url: AppApiConfig.schoolStudentLogin,
      userType: AppUserType.schoolStudent,
      body: {
        'student_code': studentCode,
        'phone': phone,
      },
    );
  }

  Future<AuthActionResult> _postSession({
    required String url,
    required AppUserType userType,
    required Map<String, dynamic> body,
  }) async {
    try {
      final String deviceId = await _localSessionService.getOrCreateDeviceId();
      final http.Response response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({...body, 'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 22));

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final bool success = data['success'] == true;
      if (!success) {
        return AuthActionResult(success: false, message: '${data['message'] ?? 'فشل الطلب'}');
      }

      return AuthActionResult(
        success: true,
        message: '${data['message'] ?? 'تم بنجاح'}',
        session: AppUserSession.fromApi(userType: userType, data: data),
      );
    } on Object {
      return const AuthActionResult(
        success: false,
        message: 'تعذر الاتصال بالسيرفر. تأكد أن API مرفوعة ومفعلة.',
      );
    }
  }
}

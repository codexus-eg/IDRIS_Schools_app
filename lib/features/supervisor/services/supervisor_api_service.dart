import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/services/local_session_service.dart';

class SupervisorInfo {
  const SupervisorInfo({required this.id, required this.name, required this.username});

  final int id;
  final String name;
  final String username;

  factory SupervisorInfo.fromJson(Map<String, dynamic> json) {
    return SupervisorInfo(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: '${json['name'] ?? ''}',
      username: '${json['username'] ?? ''}',
    );
  }
}

class SupervisorAssignment {
  const SupervisorAssignment({
    required this.branchId,
    required this.branchName,
    required this.studySection,
    required this.grade,
    required this.classSection,
    required this.targetAudience,
  });

  final int branchId;
  final String branchName;
  final String studySection;
  final String grade;
  final String? classSection;
  final String targetAudience;

  bool get isPublic => targetAudience == 'public';

  String get sectionLabel {
    switch (studySection) {
      case 'arabic':
        return 'المنهج السوداني';
      case 'english':
        return 'Cambridge';
      case 'online_english':
        return 'Cambridge Online';
      default:
        return studySection;
    }
  }

  String get displayTitle => '${isPublic ? 'الطالب العام' : branchName} • $sectionLabel • $grade';

  factory SupervisorAssignment.fromJson(Map<String, dynamic> json) {
    return SupervisorAssignment(
      branchId: int.tryParse('${json['branch_id'] ?? 0}') ?? 0,
      branchName: '${json['branch_name'] ?? json['branch'] ?? ''}'.trim().isEmpty ? 'الطالب العام' : '${json['branch_name'] ?? json['branch']}',
      studySection: '${json['study_section'] ?? ''}',
      grade: '${json['grade'] ?? ''}',
      classSection: '${json['class_section'] ?? ''}'.trim().isEmpty ? null : '${json['class_section']}',
      targetAudience: '${json['target_audience'] ?? json['audience'] ?? 'school'}',
    );
  }
}

class SupervisorLoginResult {
  const SupervisorLoginResult({required this.supervisor, required this.activeAcademicYear, required this.sessionToken, required this.assignments});

  final SupervisorInfo supervisor;
  final String activeAcademicYear;
  final String sessionToken;
  final List<SupervisorAssignment> assignments;
}

class SupervisorStudent {
  const SupervisorStudent({required this.studentId, required this.studentCode, required this.studentName});

  final int studentId;
  final String studentCode;
  final String studentName;

  factory SupervisorStudent.fromJson(Map<String, dynamic> json) {
    return SupervisorStudent(
      studentId: int.tryParse('${json['student_id'] ?? 0}') ?? 0,
      studentCode: '${json['student_code'] ?? ''}',
      studentName: '${json['student_name'] ?? json['name'] ?? ''}',
    );
  }
}

class SupervisorContentItem {
  const SupervisorContentItem({
    required this.id,
    required this.contentType,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.fileUrl,
    required this.videoUrl,
    required this.createdAt,
  });

  final int id;
  final String contentType;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String fileUrl;
  final String videoUrl;
  final String createdAt;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  factory SupervisorContentItem.fromJson(Map<String, dynamic> json) {
    return SupervisorContentItem(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      contentType: '${json['content_type'] ?? ''}',
      titleAr: '${json['title_ar'] ?? json['title'] ?? ''}',
      titleEn: '${json['title_en'] ?? json['title'] ?? json['title_ar'] ?? ''}',
      descriptionAr: '${json['description_ar'] ?? json['body_ar'] ?? ''}',
      descriptionEn: '${json['description_en'] ?? json['body_en'] ?? json['description_ar'] ?? ''}',
      fileUrl: '${json['file_url'] ?? ''}',
      videoUrl: '${json['video_url'] ?? ''}',
      createdAt: '${json['created_at'] ?? ''}',
    );
  }
}


class SupervisorAlertItem {
  const SupervisorAlertItem({
    required this.id,
    required this.studentName,
    required this.studentCode,
    required this.titleAr,
    required this.titleEn,
    required this.messageAr,
    required this.messageEn,
    required this.createdAt,
    required this.sourceType,
    required this.supervisorReplyAr,
    required this.supervisorReplyEn,
    required this.status,
    required this.repliedAt,
  });

  final int id;
  final String studentName;
  final String studentCode;
  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final String createdAt;
  final String sourceType;
  final String supervisorReplyAr;
  final String supervisorReplyEn;
  final String status;
  final String repliedAt;

  bool get isParentComment => sourceType == 'parent_comment';
  bool get isLeaveRequest => sourceType == 'parent_leave_request';

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String message(bool isArabic) => isArabic ? messageAr : messageEn;
  String reply(bool isArabic) => isArabic ? supervisorReplyAr : (supervisorReplyEn.isEmpty ? supervisorReplyAr : supervisorReplyEn);
  bool get hasReply => supervisorReplyAr.trim().isNotEmpty || supervisorReplyEn.trim().isNotEmpty;

  factory SupervisorAlertItem.fromJson(Map<String, dynamic> json) {
    return SupervisorAlertItem(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      studentName: '${json['student_name'] ?? json['name'] ?? ''}',
      studentCode: '${json['student_code'] ?? ''}',
      titleAr: '${json['title_ar'] ?? json['title'] ?? ''}',
      titleEn: '${json['title_en'] ?? json['title'] ?? json['title_ar'] ?? ''}',
      messageAr: '${json['message_ar'] ?? json['message'] ?? ''}',
      messageEn: '${json['message_en'] ?? json['message'] ?? json['message_ar'] ?? ''}',
      createdAt: '${json['created_at'] ?? ''}',
      sourceType: '${json['source_type'] ?? 'student_alert'}',
      supervisorReplyAr: '${json['supervisor_reply_ar'] ?? json['reply_ar'] ?? ''}',
      supervisorReplyEn: '${json['supervisor_reply_en'] ?? json['reply_en'] ?? json['supervisor_reply_ar'] ?? ''}',
      status: '${json['status'] ?? ''}',
      repliedAt: '${json['replied_at'] ?? ''}',
    );
  }
}

class SupervisorActionResult {
  const SupervisorActionResult({required this.success, required this.message});
  final bool success;
  final String message;
}

class SupervisorApiService {
  final LocalSessionService _sessionService = LocalSessionService();

  Future<SupervisorLoginResult> login({required String username, required String password}) async {
    final String deviceId = await _sessionService.getOrCreateDeviceId();
    final http.Response response = await http
        .post(
          Uri.parse(AppApiConfig.supervisorLogin),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password, 'device_id': deviceId}),
        )
        .timeout(const Duration(seconds: 20));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'invalid_credentials'}');

    final Map<String, dynamic> supervisorJson = data['supervisor'] is Map<String, dynamic> ? data['supervisor'] as Map<String, dynamic> : <String, dynamic>{};
    final List<dynamic> rawAssignments = data['assignments'] is List ? data['assignments'] as List<dynamic> : <dynamic>[];

    return SupervisorLoginResult(
      supervisor: SupervisorInfo.fromJson(supervisorJson),
      activeAcademicYear: '${data['active_academic_year'] ?? ''}',
      sessionToken: '${data['session_token'] ?? ''}',
      assignments: rawAssignments.whereType<Map<String, dynamic>>().map(SupervisorAssignment.fromJson).toList(),
    );
  }


  Future<SupervisorLoginResult> validateSavedSession({required String sessionToken}) async {
    final String deviceId = await _sessionService.getOrCreateDeviceId();

    final http.Response response = await http
        .post(
          Uri.parse(AppApiConfig.supervisorSessionStatus),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'session_token': sessionToken,
            'device_id': deviceId,
          }),
        )
        .timeout(const Duration(seconds: 18));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'invalid_session'}');
    }

    final Map<String, dynamic> supervisorJson =
        data['supervisor'] is Map<String, dynamic> ? data['supervisor'] as Map<String, dynamic> : <String, dynamic>{};

    final List<dynamic> rawAssignments =
        data['assignments'] is List ? data['assignments'] as List<dynamic> : <dynamic>[];

    return SupervisorLoginResult(
      supervisor: SupervisorInfo.fromJson(supervisorJson),
      activeAcademicYear: '${data['active_academic_year'] ?? ''}',
      sessionToken: '${data['session_token'] ?? sessionToken}',
      assignments: rawAssignments.whereType<Map<String, dynamic>>().map(SupervisorAssignment.fromJson).toList(),
    );
  }

  Future<SupervisorActionResult> changePassword({
    required String sessionToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final String deviceId = await _sessionService.getOrCreateDeviceId();

      final http.Response response = await http
          .post(
            Uri.parse(AppApiConfig.supervisorChangePassword),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_token': sessionToken,
              'device_id': deviceId,
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

      return SupervisorActionResult(
        success: data['success'] == true,
        message: '${data['message'] ?? ''}',
      );
    } on Object {
      return const SupervisorActionResult(success: false, message: 'تعذر الاتصال بالسيرفر');
    }
  }

  Future<List<SupervisorContentItem>> fetchContentList({
    required String sessionToken,
    required SupervisorAssignment assignment,
    required String contentType,
  }) async {
    final Uri uri = Uri.parse(AppApiConfig.supervisorContentList).replace(queryParameters: {
      'session_token': sessionToken,
      'branch_id': '${assignment.branchId}',
      'branch_name': assignment.branchName,
      'study_section': assignment.studySection,
      'grade': assignment.grade,
      'target_audience': assignment.targetAudience,
      'content_type': contentType,
    });
    final http.Response response = await http.get(uri).timeout(const Duration(seconds: 20));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(SupervisorContentItem.fromJson).toList();
  }

  Future<SupervisorActionResult> deleteContent({
    required String sessionToken,
    required SupervisorAssignment assignment,
    required String contentType,
    required int contentId,
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse(AppApiConfig.supervisorDeleteContent),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_token': sessionToken,
              'id': contentId,
              'content_type': contentType,
              'branch_id': assignment.branchId,
              'study_section': assignment.studySection,
              'grade': assignment.grade,
              'target_audience': assignment.targetAudience,
            }),
          )
          .timeout(const Duration(seconds: 20));
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return SupervisorActionResult(success: data['success'] == true, message: '${data['message'] ?? ''}');
    } on Object {
      return const SupervisorActionResult(success: false, message: 'تعذر الاتصال بالسيرفر');
    }
  }

  Future<SupervisorActionResult> saveLearningContent({
    required String sessionToken,
    required SupervisorAssignment assignment,
    required String contentType,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String videoUrl,
    int? contentId,
    File? file,
  }) {
    return _multipart(
      url: AppApiConfig.supervisorSaveLearningContent,
      sessionToken: sessionToken,
      assignment: assignment,
      fields: {
        if (contentId != null && contentId > 0) 'content_id': '$contentId',
        'content_type': contentType,
        'target_audience': assignment.targetAudience,
        'visibility': assignment.isPublic ? 'all' : 'school_only',
        'title_ar': titleAr,
        'title_en': titleEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'video_url': videoUrl,
      },
      file: file,
    );
  }

  Future<SupervisorActionResult> saveDailyReport({
    required String sessionToken,
    required SupervisorAssignment assignment,
    required String reportDate,
    required String titleAr,
    required String titleEn,
    required String bodyAr,
    required String bodyEn,
    int? reportId,
    File? file,
  }) {
    return _multipart(
      url: AppApiConfig.supervisorSaveDailyReport,
      sessionToken: sessionToken,
      assignment: assignment,
      fields: {
        if (reportId != null && reportId > 0) 'report_id': '$reportId',
        'report_date': reportDate,
        'target_audience': assignment.targetAudience,
        'title_ar': titleAr,
        'title_en': titleEn,
        'body_ar': bodyAr,
        'body_en': bodyEn,
      },
      file: file,
    );
  }

  Future<List<SupervisorStudent>> fetchStudents({required SupervisorAssignment assignment}) async {
    final Uri uri = Uri.parse(AppApiConfig.studentsForAssignment).replace(queryParameters: {
      'branch_id': '${assignment.branchId}',
      'study_section': assignment.studySection,
      'grade': assignment.grade,
    });
    final http.Response response = await http.get(uri).timeout(const Duration(seconds: 18));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    final List<dynamic> raw = data['students'] is List ? data['students'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(SupervisorStudent.fromJson).toList();
  }


  Future<List<SupervisorAlertItem>> fetchStudentAlertsList({
    required String sessionToken,
    required SupervisorAssignment assignment,
  }) async {
    final Uri uri = Uri.parse(AppApiConfig.supervisorStudentAlertsList).replace(queryParameters: {
      'session_token': sessionToken,
      'branch_id': '${assignment.branchId}',
      'study_section': assignment.studySection,
      'grade': assignment.grade,
    });

    final http.Response response = await http.get(uri).timeout(const Duration(seconds: 20));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(SupervisorAlertItem.fromJson).toList();
  }

  Future<SupervisorActionResult> replyParentRequest({
    required String sessionToken,
    required int requestId,
    required String replyAr,
    required String replyEn,
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse(AppApiConfig.supervisorReplyParentRequest),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_token': sessionToken,
              'request_id': requestId,
              'reply_ar': replyAr,
              'reply_en': replyEn,
            }),
          )
          .timeout(const Duration(seconds: 22));
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return SupervisorActionResult(success: data['success'] == true, message: '${data['message'] ?? ''}');
    } on Object {
      return const SupervisorActionResult(success: false, message: 'تعذر إرسال الرد للسيرفر');
    }
  }

  Future<SupervisorActionResult> saveStudentAlert({
    required String sessionToken,
    required List<int> studentIds,
    required String titleAr,
    required String titleEn,
    required String messageAr,
    required String messageEn,
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse(AppApiConfig.supervisorSaveStudentAlert),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'session_token': sessionToken,
              'student_ids': studentIds,
              'title_ar': titleAr,
              'title_en': titleEn,
              'message_ar': messageAr,
              'message_en': messageEn,
            }),
          )
          .timeout(const Duration(seconds: 22));
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return SupervisorActionResult(success: data['success'] == true, message: '${data['message'] ?? ''}');
    } on Object {
      return const SupervisorActionResult(success: false, message: 'تعذر الاتصال بالسيرفر');
    }
  }

  Future<SupervisorActionResult> _multipart({
    required String url,
    required String sessionToken,
    required SupervisorAssignment assignment,
    required Map<String, String> fields,
    File? file,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll({
        'session_token': sessionToken,
        'branch_id': '${assignment.branchId}',
        'branch_name': assignment.branchName,
        'study_section': assignment.studySection,
        'grade': assignment.grade,
        'target_audience': assignment.targetAudience,
        if (assignment.classSection != null) 'class_section': assignment.classSection!,
        ...fields,
      });
      if (file != null) request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final http.StreamedResponse streamed = await request.send().timeout(const Duration(seconds: 60));
      final String body = await streamed.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      return SupervisorActionResult(success: data['success'] == true, message: '${data['message'] ?? ''}');
    } on Object {
      return const SupervisorActionResult(success: false, message: 'تعذر رفع البيانات للسيرفر');
    }
  }
}

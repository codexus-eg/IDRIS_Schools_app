import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';

class ParentRequestResult {
  const ParentRequestResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class ParentRequestItem {
  const ParentRequestItem({
    required this.id,
    required this.requestType,
    required this.titleAr,
    required this.titleEn,
    required this.messageAr,
    required this.messageEn,
    required this.status,
    required this.supervisorReplyAr,
    required this.supervisorReplyEn,
    required this.createdAt,
    required this.repliedAt,
  });

  final int id;
  final String requestType;
  final String titleAr;
  final String titleEn;
  final String messageAr;
  final String messageEn;
  final String status;
  final String supervisorReplyAr;
  final String supervisorReplyEn;
  final String createdAt;
  final String repliedAt;

  bool get isLeaveRequest => requestType == 'leave_request';
  bool get hasReply => supervisorReplyAr.trim().isNotEmpty || supervisorReplyEn.trim().isNotEmpty;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String message(bool isArabic) => isArabic ? messageAr : messageEn;
  String reply(bool isArabic) => isArabic ? supervisorReplyAr : (supervisorReplyEn.isEmpty ? supervisorReplyAr : supervisorReplyEn);

  factory ParentRequestItem.fromJson(Map<String, dynamic> json) => ParentRequestItem(
        id: int.tryParse('${json['id'] ?? 0}') ?? 0,
        requestType: '${json['request_type'] ?? 'comment'}',
        titleAr: '${json['title_ar'] ?? json['title'] ?? ''}',
        titleEn: '${json['title_en'] ?? json['title'] ?? json['title_ar'] ?? ''}',
        messageAr: '${json['message_ar'] ?? json['message'] ?? ''}',
        messageEn: '${json['message_en'] ?? json['message'] ?? json['message_ar'] ?? ''}',
        status: '${json['status'] ?? ''}',
        supervisorReplyAr: '${json['supervisor_reply_ar'] ?? json['reply_ar'] ?? ''}',
        supervisorReplyEn: '${json['supervisor_reply_en'] ?? json['reply_en'] ?? json['supervisor_reply_ar'] ?? ''}',
        createdAt: '${json['created_at'] ?? ''}',
        repliedAt: '${json['replied_at'] ?? ''}',
      );
}

class ParentFeedbackService {
  Future<ParentRequestResult> submit({
    required AppUserSession session,
    required String requestType,
    required String parentName,
    required String title,
    required String message,
    String leaveFrom = '',
    String leaveTo = '',
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse(AppApiConfig.submitParentRequest),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
            body: jsonEncode({
              'request_type': requestType,
              'parent_name': parentName,
              'title': title,
              'message': message,
              'leave_from': leaveFrom,
              'leave_to': leaveTo,
            }),
          )
          .timeout(const Duration(seconds: 22));

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return ParentRequestResult(success: data['success'] == true, message: '${data['message'] ?? ''}');
    } on Object {
      return const ParentRequestResult(success: false, message: 'تعذر الاتصال بالسيرفر');
    }
  }

  Future<List<ParentRequestItem>> fetchRequests({required AppUserSession session}) async {
    final http.Response response = await http
        .get(
          Uri.parse(AppApiConfig.parentRequestsList),
          headers: {'Authorization': 'Bearer ${session.token}'},
        )
        .timeout(const Duration(seconds: 20));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(ParentRequestItem.fromJson).toList();
  }
}

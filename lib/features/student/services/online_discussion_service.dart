import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';

class OnlineDiscussionComment {
  const OnlineDiscussionComment({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.attachmentUrl,
    required this.attachmentName,
    required this.attachmentMime,
  });

  final int id;
  final String authorName;
  final String body;
  final String createdAt;
  final String attachmentUrl;
  final String attachmentName;
  final String attachmentMime;

  factory OnlineDiscussionComment.fromJson(Map<String, dynamic> json) => OnlineDiscussionComment(
        id: int.tryParse('${json['id'] ?? 0}') ?? 0,
        authorName: '${json['author_name'] ?? ''}',
        body: '${json['body'] ?? ''}',
        createdAt: '${json['created_at'] ?? ''}',
        attachmentUrl: '${json['attachment_url'] ?? ''}',
        attachmentName: '${json['attachment_name'] ?? ''}',
        attachmentMime: '${json['attachment_mime'] ?? ''}',
      );
}

class OnlineDiscussionPost {
  const OnlineDiscussionPost({
    required this.id,
    required this.subjectName,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.attachmentUrl,
    required this.attachmentName,
    required this.attachmentMime,
    required this.comments,
  });

  final int id;
  final String subjectName;
  final String authorName;
  final String body;
  final String createdAt;
  final String attachmentUrl;
  final String attachmentName;
  final String attachmentMime;
  final List<OnlineDiscussionComment> comments;

  factory OnlineDiscussionPost.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawComments = json['comments'] is List ? json['comments'] as List<dynamic> : <dynamic>[];
    return OnlineDiscussionPost(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      subjectName: '${json['subject_name'] ?? ''}',
      authorName: '${json['author_name'] ?? ''}',
      body: '${json['body'] ?? ''}',
      createdAt: '${json['created_at'] ?? ''}',
      attachmentUrl: '${json['attachment_url'] ?? ''}',
      attachmentName: '${json['attachment_name'] ?? ''}',
      attachmentMime: '${json['attachment_mime'] ?? ''}',
      comments: rawComments.whereType<Map<String, dynamic>>().map(OnlineDiscussionComment.fromJson).toList(),
    );
  }
}

class OnlineDiscussionService {
  Future<List<OnlineDiscussionPost>> fetch({required AppUserSession session}) async {
    final http.Response response = await http
        .get(Uri.parse(AppApiConfig.onlineDiscussion), headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 22));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    final List<dynamic> raw = data['posts'] is List ? data['posts'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(OnlineDiscussionPost.fromJson).toList();
  }

  Future<void> addPost({required AppUserSession session, required String body, PlatformFile? file}) async {
    await _sendMultipart(session: session, action: 'add_post', fields: {'body': body}, file: file);
  }

  Future<void> addComment({required AppUserSession session, required int postId, required String body, PlatformFile? file}) async {
    await _sendMultipart(session: session, action: 'add_comment', fields: {'post_id': '$postId', 'body': body}, file: file);
  }

  Future<void> _sendMultipart({
    required AppUserSession session,
    required String action,
    required Map<String, String> fields,
    PlatformFile? file,
  }) async {
    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(AppApiConfig.onlineDiscussion));
    request.headers['Authorization'] = 'Bearer ${session.token}';
    request.fields.addAll({'action': action, ...fields});
    if (file != null && file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes('media', file.bytes!, filename: file.name));
    }
    final http.StreamedResponse streamed = await request.send().timeout(const Duration(seconds: 45));
    final String body = await streamed.stream.bytesToString();
    final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
    if (streamed.statusCode >= 400 || data['success'] != true) {
      throw StateError('${data['message'] ?? data['error'] ?? 'server_error'}');
    }
  }
}

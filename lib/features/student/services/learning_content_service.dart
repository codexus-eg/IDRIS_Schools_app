import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';

class LearningItem {
  const LearningItem({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.fileUrl,
    required this.videoUrl,
    required this.coverUrl,
    required this.createdAt,
    this.contentType = '',
    this.mimeType = '',
    this.originalName = '',
    this.previewUrl = '',
    this.driveFileId = '',
    this.badge = '',
    this.status = '',
    this.meta = const <String, dynamic>{},
  });

  final int id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String fileUrl;
  final String videoUrl;
  final String coverUrl;
  final String createdAt;
  final String contentType;
  final String mimeType;
  final String originalName;
  final String previewUrl;
  final String driveFileId;
  final String badge;
  final String status;
  final Map<String, dynamic> meta;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  String get primaryUrl => videoUrl.trim().isNotEmpty ? videoUrl.trim() : fileUrl.trim();
  bool get hasPrimaryUrl => primaryUrl.isNotEmpty;

  String get thumbnailUrl {
    final String cover = coverUrl.trim();
    if (cover.isNotEmpty) return cover;
    if (isImage) return primaryUrl;
    return '';
  }

  String get _fileKey => primaryUrl.toLowerCase().split('?').first;
  String get _nameKey => originalName.toLowerCase();
  String get _mime => mimeType.toLowerCase();

  bool get isImage => _mime.startsWith('image/') || _hasExt(['.png', '.jpg', '.jpeg', '.webp', '.gif']);
  bool get isPdf => _mime == 'application/pdf' || _hasExt(['.pdf']);
  bool get isVideo => _mime.startsWith('video/') || _hasExt(['.mp4', '.mov', '.m4v', '.webm']) || _looksLikeVideoUrl(primaryUrl) || contentType == 'online_recordings';
  bool get isDirectVideo => _mime.startsWith('video/') || _hasExt(['.mp4', '.mov', '.m4v', '.webm']);
  bool get isOffice => _hasExt(['.ppt', '.pptx', '.doc', '.docx', '.xls', '.xlsx']) ||
      _mime.contains('powerpoint') ||
      _mime.contains('presentation') ||
      _mime.contains('wordprocessingml') ||
      _mime.contains('spreadsheetml') ||
      _mime.contains('msword') ||
      _mime.contains('ms-excel');

  bool _hasExt(List<String> extensions) => extensions.any((ext) => _fileKey.endsWith(ext) || _nameKey.endsWith(ext));

  static bool _looksLikeVideoUrl(String value) {
    final String lower = value.toLowerCase();
    return lower.contains('youtube.com/') || lower.contains('youtu.be/') || lower.contains('vimeo.com/');
  }

  IconDataName get iconName {
    if (isVideo) return IconDataName.video;
    if (isImage) return IconDataName.image;
    if (isPdf) return IconDataName.pdf;
    if (isOffice) return IconDataName.presentation;
    return IconDataName.file;
  }

  static String _pick(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final String value = '${json[key] ?? ''}'.trim();
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    }
    return '';
  }

  factory LearningItem.fromJson(Map<String, dynamic> json) => LearningItem(
        id: int.tryParse('${json['id'] ?? 0}') ?? 0,
        titleAr: _pick(json, ['title_ar', 'title', 'name', 'subject_name']),
        titleEn: _pick(json, ['title_en', 'title', 'name', 'subject_name', 'title_ar']),
        descriptionAr: _pick(json, ['description_ar', 'body_ar', 'message_ar', 'body', 'message', 'description']),
        descriptionEn: _pick(json, ['description_en', 'body_en', 'message_en', 'body', 'message', 'description', 'description_ar']),
        fileUrl: _pick(json, ['file_url', 'file_path', 'url', 'link_url', 'meet_uri']),
        videoUrl: _pick(json, ['video_url', 'recording_url']),
        coverUrl: _pick(json, ['cover_url', 'image_url', 'thumbnail_url', 'cover_path']),
        createdAt: _pick(json, ['created_at', 'updated_at', 'scheduled_at', 'submitted_at']),
        contentType: _pick(json, ['content_type', 'type']),
        mimeType: _pick(json, ['mime_type', 'file_mime', 'attachment_mime']),
        originalName: _pick(json, ['original_name', 'file_name', 'attachment_name', 'name']),
        previewUrl: _pick(json, ['preview_url', 'viewer_url']),
        driveFileId: _pick(json, ['drive_file_id', 'source_drive_file_id']),
        badge: _pick(json, ['badge']),
        status: _pick(json, ['status']),
        meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : <String, dynamic>{},
      );

  factory LearningItem.simple({
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
  }) {
    return LearningItem(
      id: 0,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      fileUrl: '',
      videoUrl: '',
      coverUrl: '',
      createdAt: '',
      meta: const <String, dynamic>{},
    );
  }
}

enum IconDataName { video, image, pdf, presentation, file }

class LearningContentService {
  Future<List<LearningItem>> fetch({
    required AppUserSession session,
    required String contentType,
    required bool schoolOnly,
  }) async {
    if (session.userType == AppUserType.onlineStudent) {
      return _fetchOnlineItems(session: session, contentType: contentType);
    }

    if (contentType == 'fees') {
      return _fetchFees(session);
    }

    if (contentType == 'daily_reports') {
      return _fetchDirectItems(url: AppApiConfig.dailyReports, session: session);
    }

    if (contentType == 'alerts') {
      return _fetchDirectItems(url: AppApiConfig.studentAlerts, session: session);
    }

    final Uri uri = Uri.parse(AppApiConfig.learningContent).replace(queryParameters: {
      'content_type': contentType,
      'user_type': schoolOnly ? 'school_student' : 'public_student',
      if (session.grade != null) 'grade': session.grade!,
      if (session.studySection != null) 'study_section': session.studySection!,
    });

    final http.Response response = await http
        .get(uri, headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 18));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(LearningItem.fromJson).toList();
  }

  Future<List<LearningItem>> _fetchOnlineItems({
    required AppUserSession session,
    required String contentType,
  }) async {
    final Uri uri = Uri.parse(AppApiConfig.onlineLearningContent).replace(queryParameters: {
      'content_type': contentType,
    });

    final http.Response response = await http
        .get(uri, headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 22));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(LearningItem.fromJson).toList();
  }

  Future<List<LearningItem>> _fetchDirectItems({
    required String url,
    required AppUserSession session,
  }) async {
    final http.Response response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 18));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> raw = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    return raw.whereType<Map<String, dynamic>>().map(LearningItem.fromJson).toList();
  }

  Future<List<LearningItem>> _fetchFees(AppUserSession session) async {
    final http.Response response = await http
        .get(Uri.parse(AppApiConfig.studentFees), headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 18));

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw StateError('${data['message'] ?? 'server_error'}');
    }

    final List<dynamic> directItems = data['items'] is List ? data['items'] as List<dynamic> : <dynamic>[];
    if (directItems.isNotEmpty) {
      return directItems.whereType<Map<String, dynamic>>().map(LearningItem.fromJson).toList();
    }

    final List<LearningItem> items = [];
    final Map<String, dynamic> summary =
        data['summary'] is Map<String, dynamic> ? data['summary'] as Map<String, dynamic> : <String, dynamic>{};

    if (summary.isNotEmpty) {
      items.add(LearningItem.simple(
        titleAr: 'ملخص الرسوم',
        titleEn: 'Fees Summary',
        descriptionAr:
            'إجمالي الرسوم: ${summary['total_due'] ?? '0'}\nالمدفوع: ${summary['total_paid'] ?? '0'}\nالمتبقي: ${summary['remaining'] ?? '0'}',
        descriptionEn:
            'Total fees: ${summary['total_due'] ?? '0'}\nPaid: ${summary['total_paid'] ?? '0'}\nRemaining: ${summary['remaining'] ?? '0'}',
      ));
    }

    final List<dynamic> installments = data['installments'] is List ? data['installments'] as List<dynamic> : <dynamic>[];
    for (final dynamic row in installments) {
      if (row is! Map<String, dynamic>) continue;
      final String seq = '${row['seq'] ?? row['installment_no'] ?? ''}';
      final String amount = '${row['amount'] ?? ''}';
      final String due = '${row['due_date'] ?? ''}';
      final String status = '${row['status'] ?? ''}';

      items.add(LearningItem.simple(
        titleAr: seq.isEmpty ? 'قسط' : 'القسط $seq',
        titleEn: seq.isEmpty ? 'Installment' : 'Installment $seq',
        descriptionAr: 'المبلغ: $amount\nتاريخ الاستحقاق: $due\nالحالة: $status',
        descriptionEn: 'Amount: $amount\nDue date: $due\nStatus: $status',
      ));
    }

    final List<dynamic> payments = data['payments'] is List ? data['payments'] as List<dynamic> : <dynamic>[];
    for (final dynamic row in payments) {
      if (row is! Map<String, dynamic>) continue;
      final String code = '${row['receipt_code'] ?? row['id'] ?? ''}';
      final String amount = '${row['amount'] ?? row['base_amount'] ?? ''}';
      final String currency = '${row['currency'] ?? row['base_currency'] ?? ''}';
      final String date = '${row['receipt_date'] ?? row['created_at'] ?? ''}';
      final String status = '${row['status'] ?? ''}';

      items.add(LearningItem.simple(
        titleAr: code.isEmpty ? 'دفعة' : 'سند دفع $code',
        titleEn: code.isEmpty ? 'Payment' : 'Payment receipt $code',
        descriptionAr: 'المبلغ: $amount $currency\nالتاريخ: $date\nالحالة: $status',
        descriptionEn: 'Amount: $amount $currency\nDate: $date\nStatus: $status',
      ));
    }

    return items;
  }
}

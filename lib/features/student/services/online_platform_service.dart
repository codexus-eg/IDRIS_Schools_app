import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';

class OnlineLiveClass {
  const OnlineLiveClass({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.grade,
    required this.dayName,
    required this.start,
    required this.end,
    required this.isLive,
    required this.meetReady,
    required this.joinUrl,
    required this.meetUri,
    required this.message,
  });

  final int id;
  final String subject;
  final String teacher;
  final String grade;
  final String dayName;
  final String start;
  final String end;
  final bool isLive;
  final bool meetReady;
  final String joinUrl;
  final String meetUri;
  final String message;

  factory OnlineLiveClass.fromJson(Map<String, dynamic> json) => OnlineLiveClass(
        id: int.tryParse('${json['schedule_id'] ?? json['id'] ?? 0}') ?? 0,
        subject: '${json['subject'] ?? ''}',
        teacher: '${json['teacher'] ?? ''}',
        grade: '${json['grade'] ?? ''}',
        dayName: '${json['day_name'] ?? ''}',
        start: '${json['start'] ?? ''}',
        end: '${json['end'] ?? ''}',
        isLive: json['is_live'] == true,
        meetReady: json['meet_ready'] == true,
        joinUrl: '${json['join_url'] ?? ''}',
        meetUri: '${json['meet_uri'] ?? ''}',
        message: '${json['message'] ?? ''}',
      );
}

class OnlineLiveStatus {
  const OnlineLiveStatus({required this.hasLive, required this.live, required this.upcoming, required this.serverTime});
  final bool hasLive;
  final List<OnlineLiveClass> live;
  final List<OnlineLiveClass> upcoming;
  final String serverTime;
}

class OnlinePlatformService {
  Future<OnlineLiveStatus> fetchLiveStatus(AppUserSession session) async {
    final response = await http
        .get(Uri.parse(AppApiConfig.onlineLiveStatus), headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 18));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    final rawLive = data['live'] is List ? data['live'] as List<dynamic> : <dynamic>[];
    final rawUpcoming = data['upcoming'] is List ? data['upcoming'] as List<dynamic> : <dynamic>[];
    return OnlineLiveStatus(
      hasLive: data['has_live'] == true,
      live: rawLive.whereType<Map<String, dynamic>>().map(OnlineLiveClass.fromJson).toList(),
      upcoming: rawUpcoming.whereType<Map<String, dynamic>>().map(OnlineLiveClass.fromJson).toList(),
      serverTime: '${data['server_time'] ?? ''}',
    );
  }

  Future<String> joinLive({required AppUserSession session, required int scheduleId}) async {
    final uri = Uri.parse(AppApiConfig.onlineJoinLive).replace(queryParameters: {'schedule_id': '$scheduleId'});
    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 24));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    return '${data['meet_uri'] ?? data['join_url'] ?? ''}'.trim();
  }
}

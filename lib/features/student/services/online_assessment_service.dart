import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_api_config.dart';
import '../../../core/models/app_user_session.dart';
import 'learning_content_service.dart';

class OnlineAssessmentOption {
  const OnlineAssessmentOption({required this.key, required this.text});
  final String key;
  final String text;
  factory OnlineAssessmentOption.fromJson(Map<String, dynamic> json) => OnlineAssessmentOption(
        key: '${json['key'] ?? json['option_key'] ?? ''}',
        text: '${json['text'] ?? json['option_text'] ?? ''}',
      );
}

class OnlineAssessmentQuestion {
  const OnlineAssessmentQuestion({
    required this.id,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.points,
    required this.answerText,
    required this.choiceKey,
    required this.savedFileName,
    required this.answerFileUrl,
    required this.studentAnswer,
    required this.correctAnswer,
    required this.score,
    required this.teacherNote,
    required this.options,
  });

  final int id;
  final String type;
  final String text;
  final String imageUrl;
  final String points;
  final String answerText;
  final String choiceKey;
  final String savedFileName;
  final String answerFileUrl;
  final String studentAnswer;
  final String correctAnswer;
  final double? score;
  final String teacherNote;
  final List<OnlineAssessmentOption> options;

  factory OnlineAssessmentQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions = json['options'] is List ? json['options'] as List<dynamic> : <dynamic>[];
    return OnlineAssessmentQuestion(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      type: '${json['question_type'] ?? ''}',
      text: '${json['question_text'] ?? ''}',
      imageUrl: '${json['image_url'] ?? ''}',
      points: '${json['points'] ?? ''}',
      answerText: '${json['answer_text'] ?? ''}',
      choiceKey: '${json['choice_key'] ?? ''}',
      savedFileName: '${json['answer_file_name'] ?? ''}',
      answerFileUrl: '${json['answer_file_url'] ?? ''}',
      studentAnswer: '${json['student_answer'] ?? ''}',
      correctAnswer: '${json['correct_answer'] ?? ''}',
      score: json['score'] == null || '${json['score']}'.isEmpty ? null : double.tryParse('${json['score']}'),
      teacherNote: '${json['teacher_note'] ?? ''}',
      options: rawOptions.whereType<Map<String, dynamic>>().map(OnlineAssessmentOption.fromJson).toList(),
    );
  }
}

class OnlineAssessmentDetail {
  const OnlineAssessmentDetail({
    required this.assessmentId,
    required this.submissionId,
    required this.title,
    required this.instructions,
    required this.category,
    required this.subjectName,
    required this.questionSource,
    required this.questionFileUrl,
    required this.questionFilePreviewUrl,
    required this.remainingSeconds,
    required this.readOnly,
    required this.canSubmit,
    required this.showResult,
    required this.resultStatus,
    required this.totalScore,
    required this.maxScore,
    required this.teacherNote,
    required this.submittedAt,
    required this.questions,
  });

  final int assessmentId;
  final int submissionId;
  final String title;
  final String instructions;
  final String category;
  final String subjectName;
  final String questionSource;
  final String questionFileUrl;
  final String questionFilePreviewUrl;
  final int? remainingSeconds;
  final bool readOnly;
  final bool canSubmit;
  final bool showResult;
  final String resultStatus;
  final String totalScore;
  final String maxScore;
  final String teacherNote;
  final String submittedAt;
  final List<OnlineAssessmentQuestion> questions;

  factory OnlineAssessmentDetail.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> a = json['assessment'] is Map<String, dynamic> ? json['assessment'] as Map<String, dynamic> : <String, dynamic>{};
    final Map<String, dynamic> s = json['submission'] is Map<String, dynamic> ? json['submission'] as Map<String, dynamic> : <String, dynamic>{};
    final List<dynamic> rawQuestions = json['questions'] is List ? json['questions'] as List<dynamic> : <dynamic>[];
    final Map<String, dynamic> result = json['result'] is Map<String, dynamic> ? json['result'] as Map<String, dynamic> : <String, dynamic>{};
    final String rem = '${json['remaining_seconds'] ?? ''}';
    return OnlineAssessmentDetail(
      assessmentId: int.tryParse('${a['id'] ?? json['assessment_id'] ?? 0}') ?? 0,
      submissionId: int.tryParse('${s['id'] ?? json['submission_id'] ?? 0}') ?? 0,
      title: '${a['title'] ?? ''}',
      instructions: '${a['instructions'] ?? ''}',
      category: '${a['category'] ?? ''}',
      subjectName: '${a['subject_name'] ?? ''}',
      questionSource: '${a['question_source'] ?? ''}',
      questionFileUrl: '${a['question_file_url'] ?? ''}',
      questionFilePreviewUrl: '${a['question_file_preview_url'] ?? ''}',
      remainingSeconds: rem.isEmpty || rem == 'null' ? null : int.tryParse(rem),
      readOnly: json['read_only'] == true,
      canSubmit: json['can_submit'] != false,
      showResult: json['show_result'] != false,
      resultStatus: '${result['status'] ?? s['status'] ?? ''}',
      totalScore: '${result['total_score'] ?? s['total_score'] ?? ''}',
      maxScore: '${result['max_score'] ?? s['max_score'] ?? ''}',
      teacherNote: '${result['teacher_note'] ?? s['teacher_note'] ?? ''}',
      submittedAt: '${result['submitted_at'] ?? s['submitted_at'] ?? ''}',
      questions: rawQuestions.whereType<Map<String, dynamic>>().map(OnlineAssessmentQuestion.fromJson).toList(),
    );
  }
}

class OnlineAssessmentService {
  final LearningContentService _contentService = LearningContentService();

  Future<List<LearningItem>> fetchAssessments(AppUserSession session) {
    return _contentService.fetch(session: session, contentType: 'online_assessments', schoolOnly: false);
  }

  Future<OnlineAssessmentDetail> openAssessment({required AppUserSession session, required int assessmentId}) async {
    final Uri uri = Uri.parse(AppApiConfig.onlineAssessmentDetail).replace(queryParameters: {'assessment_id': '$assessmentId'});
    final http.Response response = await http
        .get(uri, headers: {'Authorization': 'Bearer ${session.token}'})
        .timeout(const Duration(seconds: 24));
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) throw StateError('${data['message'] ?? 'server_error'}');
    return OnlineAssessmentDetail.fromJson(data);
  }

  Future<void> saveAnswer({
    required AppUserSession session,
    required int submissionId,
    required int questionId,
    required String answer,
    PlatformFile? file,
  }) async {
    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(AppApiConfig.onlineAssessmentSaveAnswer));
    request.headers['Authorization'] = 'Bearer ${session.token}';
    request.fields.addAll({'submission_id': '$submissionId', 'question_id': '$questionId', 'answer': answer});
    if (file != null && file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes('answer_file', file.bytes!, filename: file.name));
    }
    await _send(request);
  }

  Future<Map<String, dynamic>> submit({required AppUserSession session, required int assessmentId, required int submissionId}) async {
    final http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(AppApiConfig.onlineAssessmentSubmit));
    request.headers['Authorization'] = 'Bearer ${session.token}';
    request.fields.addAll({'assessment_id': '$assessmentId', 'submission_id': '$submissionId'});
    final Map<String, dynamic> data = await _send(request);
    return data;
  }

  Future<Map<String, dynamic>> _send(http.MultipartRequest request) async {
    final http.StreamedResponse streamed = await request.send().timeout(const Duration(seconds: 45));
    final String body = await streamed.stream.bytesToString();
    final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
    if (streamed.statusCode >= 400 || data['success'] != true) {
      throw StateError('${data['message'] ?? data['error'] ?? 'server_error'}');
    }
    return data;
  }
}

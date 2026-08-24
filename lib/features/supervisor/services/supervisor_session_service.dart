import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'supervisor_api_service.dart';

class SupervisorSessionService {
  static const String _key = 'idris_supervisor_saved_session';

  Future<void> save(SupervisorLoginResult result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      'supervisor': {
        'id': result.supervisor.id,
        'name': result.supervisor.name,
        'username': result.supervisor.username,
      },
      'active_academic_year': result.activeAcademicYear,
      'session_token': result.sessionToken,
      'assignments': result.assignments
          .map((assignment) => {
                'branch_id': assignment.branchId,
                'branch_name': assignment.branchName,
                'study_section': assignment.studySection,
                'grade': assignment.grade,
                'class_section': assignment.classSection,
                'target_audience': assignment.targetAudience,
              })
          .toList(),
    };

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<SupervisorLoginResult?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, dynamic> supervisorJson =
          data['supervisor'] is Map<String, dynamic> ? data['supervisor'] as Map<String, dynamic> : <String, dynamic>{};
      final List<dynamic> rawAssignments =
          data['assignments'] is List ? data['assignments'] as List<dynamic> : <dynamic>[];

      return SupervisorLoginResult(
        supervisor: SupervisorInfo.fromJson(supervisorJson),
        activeAcademicYear: '${data['active_academic_year'] ?? ''}',
        sessionToken: '${data['session_token'] ?? ''}',
        assignments: rawAssignments.whereType<Map<String, dynamic>>().map(SupervisorAssignment.fromJson).toList(),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

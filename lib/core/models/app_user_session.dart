enum AppUserType { publicStudent, schoolStudent, onlineStudent, supervisor }

class AppUserSession {
  const AppUserSession({
    required this.userType,
    required this.token,
    required this.name,
    required this.language,
    this.studentCode,
    this.grade,
    this.studySection,
    this.branchName,
    this.onlineUserId,
    this.onlineGradeId,
  });

  final AppUserType userType;
  final String token;
  final String name;
  final String language;
  final String? studentCode;
  final String? grade;
  final String? studySection;
  final String? branchName;
  final String? onlineUserId;
  final String? onlineGradeId;

  bool get isArabic => language.toLowerCase() != 'en';

  Map<String, String> toStorage() => {
        'user_type': userType.name,
        'token': token,
        'name': name,
        'language': language,
        'student_code': studentCode ?? '',
        'grade': grade ?? '',
        'study_section': studySection ?? '',
        'branch_name': branchName ?? '',
        'online_user_id': onlineUserId ?? '',
        'online_grade_id': onlineGradeId ?? '',
      };

  static AppUserType _typeFromString(String value) {
    for (final AppUserType type in AppUserType.values) {
      if (type.name == value) return type;
    }
    return AppUserType.publicStudent;
  }

  factory AppUserSession.fromStorage(Map<String, String> data) {
    return AppUserSession(
      userType: _typeFromString(data['user_type'] ?? 'publicStudent'),
      token: data['token'] ?? '',
      name: data['name'] ?? '',
      language: data['language'] ?? 'ar',
      studentCode: (data['student_code'] ?? '').isEmpty ? null : data['student_code'],
      grade: (data['grade'] ?? '').isEmpty ? null : data['grade'],
      studySection: (data['study_section'] ?? '').isEmpty ? null : data['study_section'],
      branchName: (data['branch_name'] ?? '').isEmpty ? null : data['branch_name'],
      onlineUserId: (data['online_user_id'] ?? '').isEmpty ? null : data['online_user_id'],
      onlineGradeId: (data['online_grade_id'] ?? '').isEmpty ? null : data['online_grade_id'],
    );
  }

  factory AppUserSession.fromApi({
    required AppUserType userType,
    required Map<String, dynamic> data,
  }) {
    final Map<String, dynamic> user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data['student'] is Map<String, dynamic>
            ? data['student'] as Map<String, dynamic>
            : <String, dynamic>{};

    final String section = '${user['study_section'] ?? user['curriculum'] ?? ''}';
    final bool english = section == 'english' || section == 'online_english' || section == 'cambridge';

    return AppUserSession(
      userType: userType,
      token: '${data['session_token'] ?? data['token'] ?? ''}',
      name: '${user['name'] ?? user['student_name'] ?? user['full_name'] ?? ''}',
      language: '${user['language'] ?? (english ? 'en' : 'ar')}',
      studentCode: '${user['student_code'] ?? ''}'.isEmpty ? null : '${user['student_code']}',
      grade: '${user['grade'] ?? ''}'.isEmpty ? null : '${user['grade']}',
      studySection: section.isEmpty ? null : section,
      branchName: '${user['branch_name'] ?? ''}'.isEmpty ? null : '${user['branch_name']}',
      onlineUserId: '${user['id'] ?? user['user_id'] ?? ''}'.isEmpty ? null : '${user['id'] ?? user['user_id']}',
      onlineGradeId: '${user['grade_id'] ?? ''}'.isEmpty ? null : '${user['grade_id']}',
    );
  }
}

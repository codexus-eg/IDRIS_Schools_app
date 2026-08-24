/// إعدادات ربط تطبيق مدرسة إدريس مع داش بورد التطبيق.
/// الرابط مثبت حسب اعتمادك ولا يتم تغييره كل مرة.
abstract final class AppApiConfig {
  static const String dashboardBaseUrl = 'https://idrisschool.com/app-dashboard';
  static const String onlinePlatformBaseUrl = 'https://idrisschool.com/ar';
  static const String baseUrl = dashboardBaseUrl;

  // Home/dashboard content
  static const String appHomeContent = '$dashboardBaseUrl/api/app_home_content.php';
  static const String activeAcademicYear = '$dashboardBaseUrl/api/active_academic_year.php';
  static const String schoolFilters = '$dashboardBaseUrl/api/school_filters.php';

  // Supervisor
  static const String supervisorLogin = '$dashboardBaseUrl/api/supervisor_login.php';
  static const String studentsForAssignment = '$dashboardBaseUrl/api/students_for_assignment.php';
  static const String supervisorSaveLearningContent = '$dashboardBaseUrl/api/supervisor_save_learning_content.php';
  static const String supervisorSaveDailyReport = '$dashboardBaseUrl/api/supervisor_save_daily_report.php';
  static const String supervisorSaveStudentAlert = '$dashboardBaseUrl/api/supervisor_save_student_alert.php';
  static const String supervisorStudentAlertsList = '$dashboardBaseUrl/api/supervisor_student_alerts_list.php';
  static const String supervisorChangePassword = '$dashboardBaseUrl/api/supervisor_change_password.php';
  static const String supervisorSessionStatus = '$dashboardBaseUrl/api/supervisor_session_status.php';
  static const String supervisorContentList = '$dashboardBaseUrl/api/supervisor_content_list.php';
  static const String supervisorDeleteContent = '$dashboardBaseUrl/api/supervisor_delete_content.php';

  // Public student account - password based, no OTP.
  static const String registerPublicStudent = '$dashboardBaseUrl/api/register_public_student.php';
  static const String publicStudentLogin = '$dashboardBaseUrl/api/public_student_login.php';

  // School student account - serial + any registered phone only, no password.
  static const String schoolStudentLogin = '$dashboardBaseUrl/api/school_student_login.php';
  static const String schoolStudentProfile = '$dashboardBaseUrl/api/school_student_profile.php';
  static const String studentFees = '$dashboardBaseUrl/api/student_fees.php';
  static const String studentAlerts = '$dashboardBaseUrl/api/student_alerts.php';
  static const String dailyReports = '$dashboardBaseUrl/api/daily_reports.php';

  // Learning content
  static const String learningContent = '$dashboardBaseUrl/api/learning_content.php';

  // Parent feedback / leave requests
  static const String submitParentRequest = '$dashboardBaseUrl/api/submit_parent_request.php';
  static const String parentRequestsList = '$dashboardBaseUrl/api/parent_requests_list.php';
  static const String supervisorReplyParentRequest = '$dashboardBaseUrl/api/supervisor_reply_parent_request.php';

  // Online learning platform integration - student username/password login.
  static const String onlineStudentLogin = '$onlinePlatformBaseUrl/mobile_api/login.php';
  static const String onlineLearningContent = '$onlinePlatformBaseUrl/mobile_api/learning_content.php';

  static const String onlineDiscussion = '$onlinePlatformBaseUrl/mobile_api/discussion.php';
  static const String onlineAssessmentDetail = '$onlinePlatformBaseUrl/mobile_api/assessment_detail.php';
  static const String onlineAssessmentSaveAnswer = '$onlinePlatformBaseUrl/mobile_api/assessment_save_answer.php';
  static const String onlineAssessmentSubmit = '$onlinePlatformBaseUrl/mobile_api/assessment_submit.php';
  static const String onlineLiveStatus = '$onlinePlatformBaseUrl/mobile_api/live_status.php';
  static const String onlineJoinLive = '$onlinePlatformBaseUrl/mobile_api/join_live.php';

  // OTP disabled in the approved flow.
  static const bool useMockOtp = false;
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/services/app_session_service.dart';
import '../../student/screens/public_student_home_screen.dart';
import '../../student/screens/school_student_home_screen.dart';
import '../services/auth_api_service.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  final AuthApiService _api = AuthApiService();
  final AppSessionService _sessionService = AppSessionService();

  final TextEditingController _publicPhone = TextEditingController();
  final TextEditingController _publicPassword = TextEditingController();

  final TextEditingController _studentCode = TextEditingController();
  final TextEditingController _studentPhone = TextEditingController();

  final TextEditingController _onlineUsername = TextEditingController();
  final TextEditingController _onlinePassword = TextEditingController();

  bool _loading = false;

  bool get _isArabic => widget.isArabic;

  @override
  void dispose() {
    _tabController.dispose();
    _publicPhone.dispose();
    _publicPassword.dispose();
    _studentCode.dispose();
    _studentPhone.dispose();
    _onlineUsername.dispose();
    _onlinePassword.dispose();
    super.dispose();
  }

  Future<void> _publicLogin() async {
    if (_publicPhone.text.trim().isEmpty || _publicPassword.text.isEmpty) {
      _show(_isArabic ? 'أدخل رقم الهاتف وكلمة المرور' : 'Enter phone and password');
      return;
    }
    await _run(() => _api.loginPublicStudent(phone: _publicPhone.text.trim(), password: _publicPassword.text));
  }

  Future<void> _schoolLogin() async {
    if (_studentCode.text.trim().isEmpty || _studentPhone.text.trim().isEmpty) {
      _show(_isArabic ? 'أدخل السيريال ورقم من الأرقام المسجلة في بيانات الطالب' : 'Enter serial and one registered phone number');
      return;
    }

    await _run(() => _api.loginSchoolStudent(
          studentCode: _studentCode.text.trim(),
          phone: _studentPhone.text.trim(),
        ));
  }

  Future<void> _onlineLogin() async {
    if (_onlineUsername.text.trim().isEmpty || _onlinePassword.text.isEmpty) {
      _show(_isArabic ? 'أدخل اسم المستخدم وكلمة المرور الخاصة بالمنصة' : 'Enter platform username and password');
      return;
    }
    await _run(() => _api.loginOnlineStudent(username: _onlineUsername.text.trim(), password: _onlinePassword.text));
  }

  Future<void> _run(Future<AuthActionResult> Function() action) async {
    setState(() => _loading = true);
    final AuthActionResult result = await action();
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success || result.session == null) {
      _show(_translateMessage(result.message));
      return;
    }

    await _sessionService.save(result.session!);
    if (!mounted) return;
    _openSession(result.session!);
  }

  String _translateMessage(String message) {
    if (!_isArabic) return message;
    switch (message) {
      case 'student_not_found_in_active_year':
        return 'الطالب غير موجود في العام الدراسي النشط.';
      case 'phone_not_registered_for_student':
        return 'الرقم غير مطابق لأي رقم مسجل في بيانات الطالب.';
      case 'missing_student_code_or_phone':
        return 'أدخل السيريال ورقم الهاتف.';
      case 'invalid_credentials':
        return 'بيانات الدخول غير صحيحة.';
      default:
        return message;
    }
  }

  void _openSession(AppUserSession session) {
    final Widget screen = session.userType == AppUserType.schoolStudent
        ? SchoolStudentHomeScreen(session: session)
        : session.userType == AppUserType.onlineStudent
            ? OnlineStudentHomeScreen(session: session)
            : PublicStudentHomeScreen(session: session);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => screen), (_) => false);
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          title: Text(_isArabic ? 'دخول' : 'Login'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.navy700,
            tabs: [
              Tab(text: _isArabic ? 'طالب عام' : 'Public student'),
              Tab(text: _isArabic ? 'طالب المدرسة' : 'School student'),
              Tab(text: _isArabic ? 'طالب أونلاين' : 'Online student'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                AuthTextField(controller: _publicPhone, label: _isArabic ? 'رقم الهاتف' : 'Phone', keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, prefixIcon: Icons.phone_iphone_rounded),
                SizedBox(height: r.s(12)),
                AuthTextField(controller: _publicPassword, label: _isArabic ? 'كلمة المرور' : 'Password', obscureText: true, prefixIcon: Icons.lock_outline_rounded),
                SizedBox(height: r.s(22)),
                _SubmitButton(text: _isArabic ? 'دخول الطالب العام' : 'Login', loading: _loading, onTap: _publicLogin),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                AuthTextField(controller: _studentCode, label: _isArabic ? 'السيريال / الرقم الهندسي' : 'Student serial', keyboardType: TextInputType.text, textDirection: TextDirection.ltr, prefixIcon: Icons.badge_outlined),
                SizedBox(height: r.s(12)),
                AuthTextField(controller: _studentPhone, label: _isArabic ? 'أي رقم مسجل في بيانات الطالب' : 'Any registered phone', keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, prefixIcon: Icons.phone_iphone_rounded),
                SizedBox(height: r.s(22)),
                _SubmitButton(text: _isArabic ? 'دخول طالب المدرسة' : 'School login', loading: _loading, onTap: _schoolLogin),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                _OnlineInfoCard(isArabic: _isArabic),
                SizedBox(height: r.s(14)),
                AuthTextField(controller: _onlineUsername, label: _isArabic ? 'اسم المستخدم في المنصة' : 'Platform username', keyboardType: TextInputType.text, textDirection: TextDirection.ltr, prefixIcon: Icons.person_outline_rounded),
                SizedBox(height: r.s(12)),
                AuthTextField(controller: _onlinePassword, label: _isArabic ? 'كلمة مرور المنصة' : 'Platform password', obscureText: true, prefixIcon: Icons.lock_outline_rounded),
                SizedBox(height: r.s(22)),
                _SubmitButton(text: _isArabic ? 'دخول طالب الأونلاين' : 'Online login', loading: _loading, onTap: _onlineLogin),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineInfoCard extends StatelessWidget {
  const _OnlineInfoCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(22)),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Container(
            width: r.s(48),
            height: r.s(48),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(.09), borderRadius: BorderRadius.circular(r.radius(17))),
            child: Icon(Icons.cast_for_education_rounded, color: AppColors.primaryBlue, size: r.s(25)),
          ),
          SizedBox(width: r.s(10)),
          Expanded(
            child: Text(
              isArabic
                  ? 'استخدم نفس اسم المستخدم وكلمة المرور الخاصة بالمنصة الأونلاين.'
                  : 'Use the same username and password from the online platform.',
              style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13), fontWeight: FontWeight.w800, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.text, required this.loading, required this.onTap});
  final String text;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return SizedBox(
      height: r.s(54),
      child: FilledButton(
        onPressed: loading ? null : onTap,
        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(18)))),
        child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w900)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';
import '../services/supervisor_session_service.dart';
import 'supervisor_assignments_screen.dart';

class SupervisorLoginScreen extends StatefulWidget {
  const SupervisorLoginScreen({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<SupervisorLoginScreen> createState() => _SupervisorLoginScreenState();
}

class _SupervisorLoginScreenState extends State<SupervisorLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupervisorApiService _api = SupervisorApiService();
  final SupervisorSessionService _sessionService = SupervisorSessionService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tryOpenSavedSupervisor();
  }

  Future<void> _tryOpenSavedSupervisor() async {
    final SupervisorLoginResult? saved = await _sessionService.load();
    if (saved == null || saved.sessionToken.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final SupervisorLoginResult valid = await _api.validateSavedSession(sessionToken: saved.sessionToken);
      await _sessionService.save(valid);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SupervisorAssignmentsScreen(
            isArabic: widget.isArabic,
            result: valid,
          ),
        ),
      );
    } catch (_) {
      await _sessionService.clear();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showMessage(widget.isArabic ? 'أدخل اسم الدخول وكلمة المرور' : 'Enter username and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final SupervisorLoginResult result = await _api.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      await _sessionService.save(result);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SupervisorAssignmentsScreen(
            isArabic: widget.isArabic,
            result: result,
          ),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      _showMessage(widget.isArabic ? 'بيانات الدخول غير صحيحة أو السيرفر غير متصل' : 'Invalid login or server connection failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final TextDirection direction = widget.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          title: Text(widget.isArabic ? 'دخول المشرفين' : 'Supervisor Login'),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              Container(
                padding: EdgeInsets.all(r.s(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.radius(28)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy900.withOpacity(0.06),
                      blurRadius: r.s(24),
                      offset: Offset(0, r.s(12)),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.supervisor_account_rounded, color: AppColors.primaryBlue, size: r.s(54)),
                    SizedBox(height: r.s(14)),
                    Text(
                      widget.isArabic ? 'أدخل بيانات المشرف' : 'Enter supervisor credentials',
                      style: TextStyle(
                        color: AppColors.navy950,
                        fontSize: r.sp(20),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: r.s(20)),
                    TextField(
                      controller: _usernameController,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? 'اسم الدخول' : 'Username',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFF),
                      ),
                    ),
                    SizedBox(height: r.s(14)),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? 'كلمة المرور' : 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFF),
                      ),
                    ),
                    SizedBox(height: r.s(22)),
                    SizedBox(
                      width: double.infinity,
                      height: r.s(54),
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                            : Text(
                                widget.isArabic ? 'دخول' : 'Login',
                                style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

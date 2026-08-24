import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';

class SupervisorChangePasswordScreen extends StatefulWidget {
  const SupervisorChangePasswordScreen({
    super.key,
    required this.isArabic,
    required this.result,
  });

  final bool isArabic;
  final SupervisorLoginResult result;

  @override
  State<SupervisorChangePasswordScreen> createState() => _SupervisorChangePasswordScreenState();
}

class _SupervisorChangePasswordScreenState extends State<SupervisorChangePasswordScreen> {
  final SupervisorApiService _api = SupervisorApiService();

  final TextEditingController _current = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_current.text.isEmpty || _new.text.isEmpty || _confirm.text.isEmpty) {
      _show(widget.isArabic ? 'أكمل كل الحقول' : 'Complete all fields');
      return;
    }

    if (_new.text.length < 4) {
      _show(widget.isArabic ? 'كلمة المرور الجديدة قصيرة' : 'New password is too short');
      return;
    }

    if (_new.text != _confirm.text) {
      _show(widget.isArabic ? 'تأكيد كلمة المرور غير مطابق' : 'Password confirmation does not match');
      return;
    }

    setState(() => _loading = true);

    final SupervisorActionResult result = await _api.changePassword(
      sessionToken: widget.result.sessionToken,
      currentPassword: _current.text,
      newPassword: _new.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      _show(_message(result.message));
      return;
    }

    _show(widget.isArabic ? 'تم تغيير كلمة المرور' : 'Password changed');
    Navigator.of(context).pop();
  }

  String _message(String message) {
    if (!widget.isArabic) return message;
    switch (message) {
      case 'wrong_current_password':
        return 'كلمة المرور الحالية غير صحيحة';
      case 'new_password_too_short':
        return 'كلمة المرور الجديدة قصيرة';
      case 'invalid_session':
        return 'الجلسة غير صالحة، ادخل من جديد';
      default:
        return message.isEmpty ? 'فشل تغيير كلمة المرور' : message;
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          title: Text(widget.isArabic ? 'تغيير كلمة المرور' : 'Change Password'),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              _Field(
                controller: _current,
                label: widget.isArabic ? 'كلمة المرور الحالية' : 'Current Password',
              ),
              SizedBox(height: r.s(14)),
              _Field(
                controller: _new,
                label: widget.isArabic ? 'كلمة المرور الجديدة' : 'New Password',
              ),
              SizedBox(height: r.s(14)),
              _Field(
                controller: _confirm,
                label: widget.isArabic ? 'تأكيد كلمة المرور الجديدة' : 'Confirm New Password',
              ),
              SizedBox(height: r.s(22)),
              SizedBox(
                height: r.s(54),
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isArabic ? 'حفظ كلمة المرور' : 'Save Password',
                          style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return TextField(
      controller: controller,
      obscureText: true,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

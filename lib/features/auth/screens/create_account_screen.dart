import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/grade_options.dart';
import '../../../core/models/country_code.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/services/app_session_service.dart';
import '../../student/screens/public_student_home_screen.dart';
import '../services/auth_api_service.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/country_code_dropdown.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthApiService _api = AuthApiService();
  final AppSessionService _sessionService = AppSessionService();

  CountryCode _country = CountryCodes.defaultCountry;
  String _curriculum = 'sudanese';
  late String _grade = GradeOptions.sudaneseArabic.first;
  bool _isLoading = false;

  bool get _isArabic => widget.isArabic;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final String fullName = _nameController.text.trim();
    final String phone = '${_country.dialCode}${_phoneController.text.trim()}';
    final String password = _passwordController.text;

    if (fullName.isEmpty || _phoneController.text.trim().isEmpty || password.isEmpty) {
      _show(_isArabic ? 'أكمل البيانات المطلوبة' : 'Complete all required fields');
      return;
    }
    if (password.length < 6) {
      _show(_isArabic ? 'كلمة المرور لا تقل عن 6 أحرف' : 'Password must be at least 6 characters');
      return;
    }
    if (password != _confirmPasswordController.text) {
      _show(_isArabic ? 'تأكيد كلمة المرور غير مطابق' : 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    final AuthActionResult result = await _api.registerPublicStudent(
      fullName: fullName,
      phone: phone,
      password: password,
      curriculum: _curriculum,
      grade: _grade,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.success || result.session == null) {
      _show(result.message);
      return;
    }

    await _sessionService.save(result.session!);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => PublicStudentHomeScreen(session: result.session!)),
      (_) => false,
    );
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final List<String> grades = GradeOptions.byCurriculum(_curriculum == 'cambridge' ? 'cambridge' : 'sudanese');
    if (!grades.contains(_grade)) _grade = grades.first;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          title: Text(_isArabic ? 'إنشاء حساب طالب عام' : 'Create public student account'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              AuthTextField(controller: _nameController, label: _isArabic ? 'اسم الطالب' : 'Student name', prefixIcon: Icons.person_outline_rounded),
              SizedBox(height: r.s(12)),
              CountryCodeDropdown(value: _country, onChanged: (v) => setState(() => _country = v), isArabic: _isArabic),
              SizedBox(height: r.s(12)),
              AuthTextField(controller: _phoneController, label: _isArabic ? 'رقم الواتساب بدون المفتاح' : 'WhatsApp number without code', keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, prefixIcon: Icons.phone_iphone_rounded),
              SizedBox(height: r.s(12)),
              DropdownButtonFormField<String>(
                value: _curriculum,
                decoration: InputDecoration(labelText: _isArabic ? 'المنهج' : 'Curriculum', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: Colors.white),
                items: [
                  DropdownMenuItem(value: 'sudanese', child: Text(_isArabic ? 'المنهج السوداني' : 'Sudanese Curriculum')),
                  const DropdownMenuItem(value: 'cambridge', child: Text('Cambridge')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _curriculum = value;
                    _grade = GradeOptions.byCurriculum(value == 'cambridge' ? 'cambridge' : 'sudanese').first;
                  });
                },
              ),
              SizedBox(height: r.s(12)),
              DropdownButtonFormField<String>(
                value: _grade,
                decoration: InputDecoration(labelText: _isArabic ? 'الصف' : 'Grade', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: Colors.white),
                items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => _grade = value ?? _grade),
              ),
              SizedBox(height: r.s(12)),
              AuthTextField(controller: _passwordController, label: _isArabic ? 'كلمة المرور' : 'Password', obscureText: true, prefixIcon: Icons.lock_outline_rounded),
              SizedBox(height: r.s(12)),
              AuthTextField(controller: _confirmPasswordController, label: _isArabic ? 'تأكيد كلمة المرور' : 'Confirm password', obscureText: true, prefixIcon: Icons.lock_reset_rounded),
              SizedBox(height: r.s(22)),
              SizedBox(
                height: r.s(54),
                child: FilledButton(
                  onPressed: _isLoading ? null : _register,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(18)))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isArabic ? 'إنشاء الحساب والدخول' : 'Create account & login', style: TextStyle(fontWeight: FontWeight.w900, fontSize: r.sp(16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


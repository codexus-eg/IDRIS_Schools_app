import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';

enum SupervisorFormMode { learningContent, dailyReport, studentAlert }

class SupervisorContentFormScreen extends StatefulWidget {
  const SupervisorContentFormScreen({
    super.key,
    required this.isArabic,
    required this.result,
    required this.assignment,
    required this.mode,
    this.contentType,
    this.title,
    this.item,
  });

  final bool isArabic;
  final SupervisorLoginResult result;
  final SupervisorAssignment assignment;
  final SupervisorFormMode mode;
  final String? contentType;
  final String? title;
  final SupervisorContentItem? item;

  @override
  State<SupervisorContentFormScreen> createState() => _SupervisorContentFormScreenState();
}

class _SupervisorContentFormScreenState extends State<SupervisorContentFormScreen> {
  final SupervisorApiService _api = SupervisorApiService();

  final TextEditingController _titleAr = TextEditingController();
  final TextEditingController _titleEn = TextEditingController();
  final TextEditingController _bodyAr = TextEditingController();
  final TextEditingController _bodyEn = TextEditingController();
  final TextEditingController _videoUrl = TextEditingController();

  File? _file;
  bool _loading = false;
  bool _loadingStudents = false;
  List<SupervisorStudent> _students = [];
  final Set<int> _selectedStudents = <int>{};

  bool get _isAlert => widget.mode == SupervisorFormMode.studentAlert;
  bool get _isDailyReport => widget.mode == SupervisorFormMode.dailyReport;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleAr.text = item.titleAr;
      _titleEn.text = item.titleEn;
      _bodyAr.text = item.descriptionAr;
      _bodyEn.text = item.descriptionEn;
      _videoUrl.text = item.videoUrl;
    }
    if (_isAlert) _loadStudents();
  }

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();
    _bodyAr.dispose();
    _bodyEn.dispose();
    _videoUrl.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    try {
      final students = await _api.fetchStudents(assignment: widget.assignment);
      if (!mounted) return;
      setState(() => _students = students);
    } catch (_) {
      if (!mounted) return;
      _show(widget.isArabic ? 'تعذر جلب الطلاب' : 'Could not load students');
    } finally {
      if (mounted) setState(() => _loadingStudents = false);
    }
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'png', 'jpg', 'jpeg', 'webp', 'txt', 'mp4'],
    );
    final String? path = result?.files.single.path;
    if (path == null) return;
    setState(() => _file = File(path));
  }

  Future<void> _save() async {
    if (_titleAr.text.trim().isEmpty && _titleEn.text.trim().isEmpty) {
      _show(widget.isArabic ? 'أدخل العنوان' : 'Enter title');
      return;
    }
    if (_isAlert && _selectedStudents.isEmpty) {
      _show(widget.isArabic ? 'حدد طالب واحد على الأقل' : 'Select at least one student');
      return;
    }

    setState(() => _loading = true);

    final SupervisorActionResult result;
    if (_isAlert) {
      result = await _api.saveStudentAlert(
        sessionToken: widget.result.sessionToken,
        studentIds: _selectedStudents.toList(),
        titleAr: _titleAr.text.trim(),
        titleEn: _titleEn.text.trim(),
        messageAr: _bodyAr.text.trim(),
        messageEn: _bodyEn.text.trim(),
      );
    } else if (_isDailyReport) {
      final String today = DateTime.now().toIso8601String().substring(0, 10);
      result = await _api.saveDailyReport(
        sessionToken: widget.result.sessionToken,
        assignment: widget.assignment,
        reportDate: today,
        titleAr: _titleAr.text.trim(),
        titleEn: _titleEn.text.trim(),
        bodyAr: _bodyAr.text.trim(),
        bodyEn: _bodyEn.text.trim(),
        reportId: widget.item?.id,
        file: _file,
      );
    } else {
      result = await _api.saveLearningContent(
        sessionToken: widget.result.sessionToken,
        assignment: widget.assignment,
        contentType: widget.contentType ?? 'books',
        titleAr: _titleAr.text.trim(),
        titleEn: _titleEn.text.trim(),
        descriptionAr: _bodyAr.text.trim(),
        descriptionEn: _bodyEn.text.trim(),
        videoUrl: _videoUrl.text.trim(),
        contentId: widget.item?.id,
        file: _file,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    _show(result.success ? (widget.isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully') : (result.message.isEmpty ? (widget.isArabic ? 'فشل الحفظ' : 'Save failed') : result.message));
    if (result.success) Navigator.of(context).pop();
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          title: Text(widget.title ?? (widget.isArabic ? 'إدخال بيانات' : 'Add data')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
        ),
        body: ListView(
          padding: EdgeInsets.all(r.pagePadding),
          children: [
            _AssignmentBanner(isArabic: widget.isArabic, assignment: widget.assignment),
            SizedBox(height: r.s(14)),
            _Field(controller: _titleAr, label: widget.isArabic ? 'العنوان بالعربي' : 'Arabic title'),
            SizedBox(height: r.s(12)),
            _Field(controller: _titleEn, label: widget.isArabic ? 'العنوان بالإنجليزي' : 'English title', textDirection: TextDirection.ltr),
            SizedBox(height: r.s(12)),
            _Field(controller: _bodyAr, label: widget.isArabic ? (_isAlert ? 'رسالة التنبيه بالعربي' : 'الوصف / المحتوى بالعربي') : 'Arabic text', maxLines: 5),
            SizedBox(height: r.s(12)),
            _Field(controller: _bodyEn, label: widget.isArabic ? (_isAlert ? 'رسالة التنبيه بالإنجليزي' : 'الوصف / المحتوى بالإنجليزي') : 'English text', textDirection: TextDirection.ltr, maxLines: 5),
            if (!_isAlert && !_isDailyReport) ...[
              SizedBox(height: r.s(12)),
              _Field(controller: _videoUrl, label: widget.isArabic ? 'رابط فيديو اختياري' : 'Optional video URL', textDirection: TextDirection.ltr),
            ],
            if (!_isAlert) ...[
              SizedBox(height: r.s(12)),
              OutlinedButton.icon(
                onPressed: _loading ? null : _pickFile,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(_file == null ? (widget.isArabic ? 'اختيار ملف اختياري' : 'Choose optional file') : _file!.path.split('/').last),
              ),
            ],
            if (_isAlert) ...[
              SizedBox(height: r.s(16)),
              Text(widget.isArabic ? 'اختيار الطلاب' : 'Select students', style: TextStyle(fontSize: r.sp(18), fontWeight: FontWeight.w900, color: AppColors.navy950)),
              SizedBox(height: r.s(10)),
              if (_loadingStudents) const Center(child: CircularProgressIndicator()),
              if (!_loadingStudents)
                ..._students.map((student) => CheckboxListTile(
                      value: _selectedStudents.contains(student.studentId),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedStudents.add(student.studentId);
                          } else {
                            _selectedStudents.remove(student.studentId);
                          }
                        });
                      },
                      title: Text(student.studentName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(student.studentCode, textDirection: TextDirection.ltr),
                    )),
            ],
            SizedBox(height: r.s(22)),
            SizedBox(
              height: r.s(54),
              child: FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(18)))),
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.isArabic ? 'حفظ' : 'Save', style: TextStyle(fontWeight: FontWeight.w900, fontSize: r.sp(16))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label, this.maxLines = 1, this.textDirection});
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextDirection? textDirection;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
    );
  }
}

class _AssignmentBanner extends StatelessWidget {
  const _AssignmentBanner({required this.isArabic, required this.assignment});
  final bool isArabic;
  final SupervisorAssignment assignment;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))),
      child: Text(assignment.displayTitle, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13.5), fontWeight: FontWeight.w900)),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/learning_content_service.dart';
import '../services/online_assessment_service.dart';
import 'internal_file_viewer_screen.dart';

class OnlineAssessmentListScreen extends StatefulWidget {
  const OnlineAssessmentListScreen({super.key, required this.isArabic, required this.session});

  final bool isArabic;
  final AppUserSession session;

  @override
  State<OnlineAssessmentListScreen> createState() => _OnlineAssessmentListScreenState();
}

class _OnlineAssessmentListScreenState extends State<OnlineAssessmentListScreen> {
  final OnlineAssessmentService _service = OnlineAssessmentService();
  late Future<List<LearningItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAssessments(widget.session);
  }

  void _refresh() {
    final Future<List<LearningItem>> nextFuture = _service.fetchAssessments(widget.session);
    if (!mounted) return;
    setState(() {
      _future = nextFuture;
    });
  }

  Future<void> _open(LearningItem item) async {
    if (item.id <= 0) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnlineAssessmentTakeScreen(isArabic: widget.isArabic, session: widget.session, assessmentId: item.id, title: item.title(widget.isArabic))));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.navy950, title: Text(widget.isArabic ? 'الاختبارات' : 'Quizzes & Exams'), actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))]),
        body: FutureBuilder<List<LearningItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return _StateMessage(message: widget.isArabic ? 'تعذر تحميل الاختبارات.' : 'Unable to load assessments.');
            final items = snapshot.data ?? [];
            if (items.isEmpty) return _StateMessage(message: widget.isArabic ? 'لا توجد اختبارات متاحة.' : 'No assessments available.');
            return ListView.separated(
              padding: EdgeInsets.all(r.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => _open(item),
                  borderRadius: BorderRadius.circular(r.radius(24)),
                  child: Container(
                    padding: EdgeInsets.all(r.s(15)),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))],),
                    child: Row(children: [
                      Container(width: r.s(54), height: r.s(54), decoration: BoxDecoration(borderRadius: BorderRadius.circular(r.radius(18)), gradient: const LinearGradient(colors: [Color(0xFFFFF3D9), Color(0xFFFFE0E6)])), child: Icon(Icons.assignment_rounded, color: AppColors.schoolRed, size: r.s(28))),
                      SizedBox(width: r.s(12)),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.title(widget.isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15.5), fontWeight: FontWeight.w900)),
                        if (item.description(widget.isArabic).trim().isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(6)), child: Text(item.description(widget.isArabic), maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12.7), height: 1.45, fontWeight: FontWeight.w600))),
                      ])),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryBlue, size: r.s(16)),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class OnlineAssessmentTakeScreen extends StatefulWidget {
  const OnlineAssessmentTakeScreen({super.key, required this.isArabic, required this.session, required this.assessmentId, required this.title});

  final bool isArabic;
  final AppUserSession session;
  final int assessmentId;
  final String title;

  @override
  State<OnlineAssessmentTakeScreen> createState() => _OnlineAssessmentTakeScreenState();
}

class _OnlineAssessmentTakeScreenState extends State<OnlineAssessmentTakeScreen> {
  final OnlineAssessmentService _service = OnlineAssessmentService();
  late Future<OnlineAssessmentDetail> _future;
  OnlineAssessmentDetail? _detail;
  int _index = 0;
  final Map<int, TextEditingController> _controllers = <int, TextEditingController>{};
  final Map<int, String> _choices = <int, String>{};
  final Map<int, PlatformFile?> _files = <int, PlatformFile?>{};
  bool _saving = false;
  String _saveMessage = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<OnlineAssessmentDetail> _load() async {
    final detail = await _service.openAssessment(session: widget.session, assessmentId: widget.assessmentId);
    _detail = detail;
    for (final q in detail.questions) {
      _controllers.putIfAbsent(q.id, () => TextEditingController(text: q.answerText));
      _choices[q.id] = q.choiceKey.isNotEmpty ? q.choiceKey : q.answerText;
    }
    return detail;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile(int qid) async {
    final result = await FilePicker.platform.pickFiles(withData: true, allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'doc', 'docx'], type: FileType.custom);
    if (result != null && result.files.isNotEmpty) setState(() => _files[qid] = result.files.first);
  }

  String _answerFor(OnlineAssessmentQuestion q) {
    if (q.type == 'mcq' || q.type == 'true_false') return (_choices[q.id] ?? '').trim();
    return (_controllers[q.id]?.text ?? '').trim();
  }

  Future<void> _saveCurrent({bool silent = false}) async {
    final detail = _detail;
    if (detail == null || detail.questions.isEmpty || detail.readOnly) return;
    final q = detail.questions[_index];
    setState(() {
      _saving = true;
      if (!silent) _saveMessage = '';
    });
    try {
      await _service.saveAnswer(session: widget.session, submissionId: detail.submissionId, questionId: q.id, answer: _answerFor(q), file: _files[q.id]);
      if (mounted) setState(() => _saveMessage = widget.isArabic ? 'تم حفظ الإجابة' : 'Answer saved');
    } catch (e) {
      if (mounted) setState(() => _saveMessage = '$e'.replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _go(int delta) async {
    await _saveCurrent(silent: true);
    final count = _detail?.questions.length ?? 0;
    final int next = (_index + delta).clamp(0, count - 1).toInt();
    setState(() => _index = next);
  }

  Future<void> _submit() async {
    final detail = _detail;
    if (detail == null) return;
    await _saveCurrent(silent: true);
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isArabic ? 'تسليم الاختبار' : 'Submit assessment'),
        content: Text(widget.isArabic ? 'هل تريد تسليم الإجابات الآن؟' : 'Submit your answers now?'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(widget.isArabic ? 'رجوع' : 'Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(widget.isArabic ? 'تسليم' : 'Submit'))],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      final data = await _service.submit(session: widget.session, assessmentId: detail.assessmentId, submissionId: detail.submissionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data['message'] ?? (widget.isArabic ? 'تم التسليم' : 'Submitted')}')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _saveMessage = '$e'.replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openQuestionFile(OnlineAssessmentDetail detail) {
    final url = detail.questionFileUrl.trim().isNotEmpty ? detail.questionFileUrl.trim() : detail.questionFilePreviewUrl.trim();
    if (url.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => InternalFileViewerScreen(item: LearningItem(id: 0, titleAr: detail.title, titleEn: detail.title, descriptionAr: detail.instructions, descriptionEn: detail.instructions, fileUrl: url, videoUrl: '', coverUrl: '', createdAt: '', contentType: 'online_assessments', mimeType: 'application/pdf', originalName: 'assessment.pdf', previewUrl: detail.questionFilePreviewUrl), isArabic: widget.isArabic)));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.navy950, title: Text(widget.title)),
        body: FutureBuilder<OnlineAssessmentDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return _StateMessage(message: '${snapshot.error}'.replaceFirst('Bad state: ', ''));
            final detail = snapshot.data!;
            if (detail.questions.isEmpty) return _StateMessage(message: widget.isArabic ? 'لا توجد أسئلة.' : 'No questions.');
            final q = detail.questions[_index];
            return Column(children: [
              Container(
                margin: EdgeInsets.fromLTRB(r.pagePadding, 0, r.pagePadding, r.s(8)),
                padding: EdgeInsets.all(r.s(12)),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(20)), border: Border.all(color: AppColors.primaryBlue.withOpacity(.06))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(detail.subjectName.isEmpty ? detail.category : '${detail.subjectName} · ${detail.category}', style: TextStyle(color: AppColors.schoolRed, fontSize: r.sp(12), fontWeight: FontWeight.w900)),
                    if (detail.instructions.trim().isNotEmpty) Text(detail.instructions, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(11.5), height: 1.4)),
                  ])),
                  if (detail.remainingSeconds != null) _Pill(text: _formatRemaining(detail.remainingSeconds!)),
                ]),
              ),
              if (detail.readOnly) Padding(padding: EdgeInsets.symmetric(horizontal: r.pagePadding), child: _ResultSummary(isArabic: widget.isArabic, detail: detail)),
              if (detail.questionFileUrl.isNotEmpty) Padding(padding: EdgeInsets.symmetric(horizontal: r.pagePadding), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _openQuestionFile(detail), icon: const Icon(Icons.picture_as_pdf_rounded), label: Text(widget.isArabic ? 'فتح ورقة الأسئلة' : 'Open question paper')))),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(r.pagePadding),
                  child: _QuestionCard(
                    isArabic: widget.isArabic,
                    question: q,
                    number: _index + 1,
                    total: detail.questions.length,
                    controller: _controllers[q.id]!,
                    selected: _choices[q.id] ?? '',
                    file: _files[q.id],
                    onSelect: (v) => setState(() => _choices[q.id] = v),
                    onPickFile: () => _pickFile(q.id),
                    onRemoveFile: () => setState(() => _files[q.id] = null),
                    readOnly: detail.readOnly,
                    showResult: detail.showResult,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(r.s(12)),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5EDF7)))),
                child: Column(children: [
                  if (_saveMessage.isNotEmpty) Padding(padding: EdgeInsets.only(bottom: r.s(8)), child: Text(_saveMessage, style: TextStyle(color: _saveMessage.contains('saved') || _saveMessage.contains('حفظ') ? AppColors.primaryBlue : AppColors.schoolRed, fontWeight: FontWeight.w800))),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: _saving || _index == 0 ? null : () => _go(-1), child: Text(widget.isArabic ? 'السابق' : 'Previous'))),
                    if (!detail.readOnly) ...[
                      SizedBox(width: r.s(8)),
                      Expanded(child: ElevatedButton(onPressed: _saving ? null : () => _saveCurrent(), child: Text(widget.isArabic ? 'حفظ' : 'Save'))),
                    ],
                    SizedBox(width: r.s(8)),
                    Expanded(child: OutlinedButton(onPressed: _saving || _index == detail.questions.length - 1 ? null : () => _go(1), child: Text(widget.isArabic ? 'التالي' : 'Next'))),
                  ]),
                  if (!detail.readOnly) ...[
                    SizedBox(height: r.s(8)),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _saving ? null : _submit, icon: const Icon(Icons.done_all_rounded), label: Text(widget.isArabic ? 'تسليم الاختبار' : 'Submit assessment'))),
                  ],
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  String _formatRemaining(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.isArabic, required this.question, required this.number, required this.total, required this.controller, required this.selected, required this.file, required this.onSelect, required this.onPickFile, required this.onRemoveFile, required this.readOnly, required this.showResult});
  final bool isArabic;
  final OnlineAssessmentQuestion question;
  final int number;
  final int total;
  final TextEditingController controller;
  final String selected;
  final PlatformFile? file;
  final ValueChanged<String> onSelect;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final bool readOnly;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text('${isArabic ? 'السؤال' : 'Question'} $number / $total', style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(13), fontWeight: FontWeight.w900))), _Pill(text: '${question.points} pts')]),
        SizedBox(height: r.s(10)),
        Text(question.text, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(17), height: 1.55, fontWeight: FontWeight.w900)),
        if (question.imageUrl.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(10)), child: ClipRRect(borderRadius: BorderRadius.circular(r.radius(18)), child: Image.network(question.imageUrl, fit: BoxFit.contain))),
        SizedBox(height: r.s(16)),
        if (question.type == 'mcq') ...question.options.map((o) => RadioListTile<String>(value: o.key, groupValue: selected, onChanged: readOnly ? null : (v) => onSelect(v ?? ''), title: Text('${o.key}. ${o.text}'), subtitle: readOnly && showResult && o.key == question.correctAnswer ? Text(isArabic ? 'الإجابة الصحيحة' : 'Correct answer', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w900)) : null, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(14))), contentPadding: EdgeInsets.zero)),
        if (question.type == 'true_false') ...[
          RadioListTile<String>(value: 'True', groupValue: selected, onChanged: readOnly ? null : (v) => onSelect(v ?? ''), title: const Text('True')),
          RadioListTile<String>(value: 'False', groupValue: selected, onChanged: readOnly ? null : (v) => onSelect(v ?? ''), title: const Text('False')),
        ],
        if (question.type == 'short_text' || question.type == 'long_text') ...[
          TextField(controller: controller, enabled: !readOnly, minLines: question.type == 'long_text' ? 6 : 2, maxLines: question.type == 'long_text' ? 12 : 5, decoration: InputDecoration(hintText: isArabic ? 'اكتب إجابتك هنا...' : 'Write your answer here...', filled: true, fillColor: const Color(0xFFF7FAFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18)), borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(.08))))),
          SizedBox(height: r.s(10)),
          if (!readOnly) Row(children: [OutlinedButton.icon(onPressed: onPickFile, icon: const Icon(Icons.upload_file_rounded), label: Text(isArabic ? 'رفع ملف/صورة' : 'Upload file/image')), if (file != null) Expanded(child: Padding(padding: EdgeInsetsDirectional.only(start: r.s(8)), child: Chip(label: Text(file!.name, overflow: TextOverflow.ellipsis), onDeleted: onRemoveFile)))]),
          if (question.savedFileName.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(7)), child: Text('${isArabic ? 'ملف محفوظ' : 'Saved file'}: ${question.savedFileName}', style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12), fontWeight: FontWeight.w700))),
          if (readOnly && question.answerFileUrl.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: r.s(8)),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InternalFileViewerScreen(item: LearningItem(id: 0, titleAr: question.savedFileName.isEmpty ? 'Answer file' : question.savedFileName, titleEn: question.savedFileName.isEmpty ? 'Answer file' : question.savedFileName, descriptionAr: '', descriptionEn: '', fileUrl: question.answerFileUrl, videoUrl: '', coverUrl: '', createdAt: '', contentType: 'online_assessments', mimeType: '', originalName: question.savedFileName), isArabic: isArabic))),
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(isArabic ? 'فتح ملف الإجابة' : 'Open answer file'),
              ),
            ),
        ],
        if (readOnly && showResult) _AnswerReviewBox(isArabic: isArabic, question: question),
      ]),
    );
  }
}


class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.isArabic, required this.detail});
  final bool isArabic;
  final OnlineAssessmentDetail detail;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final score = detail.totalScore.trim().isEmpty ? (isArabic ? 'قيد التصحيح' : 'Pending') : '${detail.totalScore} / ${detail.maxScore}';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: r.s(8)),
      padding: EdgeInsets.all(r.s(12)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(18)), border: Border.all(color: const Color(0xFFE5EDF7))),
      child: Row(children: [
        Icon(Icons.verified_rounded, color: detail.resultStatus == 'graded' ? const Color(0xFF059669) : AppColors.primaryBlue),
        SizedBox(width: r.s(8)),
        Expanded(child: Text('${isArabic ? 'الحالة' : 'Status'}: ${detail.resultStatus}\n${isArabic ? 'الدرجة' : 'Score'}: $score', style: TextStyle(color: AppColors.navy900, fontSize: r.sp(12.5), fontWeight: FontWeight.w800, height: 1.45))),
      ]),
    );
  }
}

class _AnswerReviewBox extends StatelessWidget {
  const _AnswerReviewBox({required this.isArabic, required this.question});
  final bool isArabic;
  final OnlineAssessmentQuestion question;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final correct = question.correctAnswer.trim();
    final score = question.score;
    if (correct.isEmpty && score == null && question.teacherNote.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: r.s(14)),
      padding: EdgeInsets.all(r.s(12)),
      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(r.radius(16)), border: Border.all(color: const Color(0xFFBBF7D0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isArabic ? 'مراجعة الإجابة' : 'Answer review', style: TextStyle(color: const Color(0xFF166534), fontSize: r.sp(13.5), fontWeight: FontWeight.w900)),
        if (correct.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(6)), child: Text('${isArabic ? 'الإجابة الصحيحة' : 'Correct answer'}: $correct', style: TextStyle(color: AppColors.navy900, fontSize: r.sp(12.5), fontWeight: FontWeight.w800))),
        if (score != null) Padding(padding: EdgeInsets.only(top: r.s(4)), child: Text('${isArabic ? 'درجة السؤال' : 'Question score'}: $score / ${question.points}', style: TextStyle(color: AppColors.navy900, fontSize: r.sp(12.5), fontWeight: FontWeight.w800))),
        if (question.teacherNote.trim().isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(4)), child: Text('${isArabic ? 'ملاحظة المعلم' : 'Teacher note'}: ${question.teacherNote}', style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12), fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Container(padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(6)), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(.09), borderRadius: BorderRadius.circular(999)), child: Text(text, style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(11.5), fontWeight: FontWeight.w900)));
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Center(child: Padding(padding: EdgeInsets.all(r.pagePadding), child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(14.5), fontWeight: FontWeight.w800))));
  }
}

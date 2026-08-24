import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';
import 'supervisor_content_form_screen.dart';

class SupervisorStudentAlertsListScreen extends StatefulWidget {
  const SupervisorStudentAlertsListScreen({
    super.key,
    required this.isArabic,
    required this.result,
    required this.assignment,
  });

  final bool isArabic;
  final SupervisorLoginResult result;
  final SupervisorAssignment assignment;

  @override
  State<SupervisorStudentAlertsListScreen> createState() => _SupervisorStudentAlertsListScreenState();
}

class _SupervisorStudentAlertsListScreenState extends State<SupervisorStudentAlertsListScreen> {
  final SupervisorApiService _api = SupervisorApiService();
  late Future<List<SupervisorAlertItem>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = _api.fetchStudentAlertsList(
      sessionToken: widget.result.sessionToken,
      assignment: widget.assignment,
    );
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupervisorContentFormScreen(
        isArabic: widget.isArabic,
        result: widget.result,
        assignment: widget.assignment,
        mode: SupervisorFormMode.studentAlert,
        title: widget.isArabic ? 'تنبيه جديد' : 'New Alert',
      ),
    ));

    if (!mounted) return;
    setState(_refresh);
  }

  Future<void> _replyToParentRequest(SupervisorAlertItem item) async {
    final TextEditingController replyArController = TextEditingController(text: item.supervisorReplyAr);
    final TextEditingController replyEnController = TextEditingController(text: item.supervisorReplyEn);

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReplySheet(
        isArabic: widget.isArabic,
        item: item,
        replyArController: replyArController,
        replyEnController: replyEnController,
        onSave: () async {
          final String ar = replyArController.text.trim();
          final String en = replyEnController.text.trim();
          if (ar.isEmpty && en.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isArabic ? 'اكتب الرد أولاً.' : 'Write a reply first.')));
            return;
          }
          final result = await _api.replyParentRequest(
            sessionToken: widget.result.sessionToken,
            requestId: item.id,
            replyAr: ar,
            replyEn: en,
          );
          if (!context.mounted) return;
          if (result.success) {
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message.isEmpty ? (widget.isArabic ? 'تعذر إرسال الرد.' : 'Could not send reply.') : result.message)));
          }
        },
      ),
    );

    replyArController.dispose();
    replyEnController.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isArabic ? 'تم حفظ الرد وإرساله للطالب.' : 'Reply saved and sent.')));
      setState(_refresh);
    }
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
          title: Text(widget.isArabic ? 'تنبيهات الطلاب' : 'Student Alerts'),
          actions: [
            IconButton(onPressed: () => setState(_refresh), icon: const Icon(Icons.refresh_rounded), tooltip: widget.isArabic ? 'تحديث' : 'Refresh'),
            IconButton(onPressed: _openAdd, icon: const Icon(Icons.add_circle_outline_rounded), tooltip: widget.isArabic ? 'تنبيه جديد' : 'New Alert'),
          ],
        ),
        body: FutureBuilder<List<SupervisorAlertItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _StateMessage(
                message: widget.isArabic ? 'تعذر جلب التنبيهات السابقة حالياً.' : 'Could not load previous alerts.',
                buttonText: widget.isArabic ? 'تنبيه جديد' : 'New Alert',
                onTap: _openAdd,
              );
            }

            final List<SupervisorAlertItem> items = snapshot.data ?? [];

            if (items.isEmpty) {
              return _StateMessage(
                message: widget.isArabic ? 'لا توجد تنبيهات سابقة لهذا الصف.' : 'No previous alerts for this class.',
                buttonText: widget.isArabic ? 'إضافة تنبيه جديد' : 'Add New Alert',
                onTap: _openAdd,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => setState(_refresh),
              child: ListView.separated(
                padding: EdgeInsets.all(r.pagePadding),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
                itemBuilder: (context, index) {
                  final SupervisorAlertItem item = items[index];
                  return _AlertCard(
                    item: item,
                    isArabic: widget.isArabic,
                    onReply: item.isParentComment || item.isLeaveRequest ? () => _replyToParentRequest(item) : null,
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAdd,
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.item, required this.isArabic, required this.onReply});

  final SupervisorAlertItem item;
  final bool isArabic;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool isParentMessage = item.isParentComment || item.isLeaveRequest;
    final IconData alertIcon = item.isLeaveRequest
        ? Icons.event_available_rounded
        : item.isParentComment
            ? Icons.family_restroom_rounded
            : Icons.notifications_active_rounded;
    final Color alertColor = item.isLeaveRequest
        ? const Color(0xFF059669)
        : item.isParentComment
            ? const Color(0xFFEC4899)
            : AppColors.primaryBlue;

    return Container(
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(22)),
        boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: r.s(42),
                height: r.s(42),
                decoration: BoxDecoration(color: alertColor.withOpacity(.10), borderRadius: BorderRadius.circular(r.radius(16))),
                child: Icon(alertIcon, color: alertColor, size: r.s(22)),
              ),
              SizedBox(width: r.s(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName.isEmpty ? (isArabic ? 'طالب' : 'Student') : item.studentName,
                      style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15.5), fontWeight: FontWeight.w900),
                    ),
                    if (item.studentCode.isNotEmpty)
                      Text(item.studentCode, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.72), fontSize: r.sp(11.5), fontWeight: FontWeight.w700)),
                    if (isParentMessage) ...[
                      SizedBox(height: r.s(5)),
                      Wrap(spacing: r.s(6), runSpacing: r.s(6), children: [
                        _TypeChip(
                          color: alertColor,
                          label: item.isLeaveRequest ? (isArabic ? 'طلب إجازة من ولي الأمر' : 'Parent leave request') : (isArabic ? 'تعليق ولي أمر' : 'Parent comment'),
                        ),
                        _TypeChip(color: item.hasReply ? AppColors.primaryBlue : AppColors.schoolRed, label: item.hasReply ? (isArabic ? 'تم الرد' : 'Replied') : (isArabic ? 'بانتظار الرد' : 'Pending reply')),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: r.s(12)),
          Text(item.title(isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15), fontWeight: FontWeight.w900)),
          if (item.message(isArabic).trim().isNotEmpty) ...[
            SizedBox(height: r.s(7)),
            Text(item.message(isArabic), style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13.5), height: 1.6, fontWeight: FontWeight.w600)),
          ],
          if (item.hasReply) ...[
            SizedBox(height: r.s(11)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(r.s(12)),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(.055), borderRadius: BorderRadius.circular(r.radius(18))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isArabic ? 'رد المشرف' : 'Supervisor reply', style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(12), fontWeight: FontWeight.w900)),
                SizedBox(height: r.s(5)),
                Text(item.reply(isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(13), height: 1.55, fontWeight: FontWeight.w700)),
                if (item.repliedAt.isNotEmpty) ...[
                  SizedBox(height: r.s(5)),
                  Text(item.repliedAt, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.6), fontSize: r.sp(10.8), fontWeight: FontWeight.w700)),
                ],
              ]),
            ),
          ],
          if (item.createdAt.isNotEmpty) ...[
            SizedBox(height: r.s(10)),
            Text(item.createdAt, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.55), fontSize: r.sp(11.5), fontWeight: FontWeight.w700)),
          ],
          if (onReply != null) ...[
            SizedBox(height: r.s(12)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: onReply,
                icon: Icon(item.hasReply ? Icons.edit_note_rounded : Icons.reply_rounded),
                label: Text(item.hasReply ? (isArabic ? 'تعديل الرد' : 'Edit reply') : (isArabic ? 'رد على ولي الأمر' : 'Reply')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(9), vertical: r.s(4)),
      decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(color: color, fontSize: r.sp(10.8), fontWeight: FontWeight.w900)),
    );
  }
}

class _ReplySheet extends StatelessWidget {
  const _ReplySheet({
    required this.isArabic,
    required this.item,
    required this.replyArController,
    required this.replyEnController,
    required this.onSave,
  });

  final bool isArabic;
  final SupervisorAlertItem item;
  final TextEditingController replyArController;
  final TextEditingController replyEnController;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          padding: EdgeInsets.all(r.pagePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(28))),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isArabic ? 'رد على ولي الأمر' : 'Reply to parent', style: TextStyle(color: AppColors.navy950, fontSize: r.sp(19), fontWeight: FontWeight.w900)),
                SizedBox(height: r.s(8)),
                Text(item.message(isArabic), maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13), height: 1.5, fontWeight: FontWeight.w600)),
                SizedBox(height: r.s(14)),
                TextField(
                  controller: replyArController,
                  minLines: 4,
                  maxLines: 7,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(labelText: 'الرد بالعربي', border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18)))),
                ),
                SizedBox(height: r.s(12)),
                TextField(
                  controller: replyEnController,
                  minLines: 3,
                  maxLines: 5,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: 'Reply in English - optional', border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18)))),
                ),
                SizedBox(height: r.s(16)),
                FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.send_rounded), label: Text(isArabic ? 'حفظ وإرسال الرد' : 'Save and send reply')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message, required this.buttonText, required this.onTap});

  final String message;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(15), fontWeight: FontWeight.w800, height: 1.6)),
            SizedBox(height: r.s(14)),
            FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.add), label: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

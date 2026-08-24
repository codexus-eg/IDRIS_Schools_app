import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/parent_feedback_service.dart';

class ParentFeedbackScreen extends StatefulWidget {
  const ParentFeedbackScreen({super.key, required this.isArabic, required this.session});

  final bool isArabic;
  final AppUserSession session;

  @override
  State<ParentFeedbackScreen> createState() => _ParentFeedbackScreenState();
}

class _ParentFeedbackScreenState extends State<ParentFeedbackScreen> with SingleTickerProviderStateMixin {
  final ParentFeedbackService _service = ParentFeedbackService();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _leaveReasonController = TextEditingController();
  final TextEditingController _leaveFromController = TextEditingController();
  final TextEditingController _leaveToController = TextEditingController();

  late final TabController _tabController;
  late Future<List<ParentRequestItem>> _requestsFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshRequests();
  }

  void _refreshRequests() {
    _requestsFuture = _service.fetchRequests(session: widget.session);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parentNameController.dispose();
    _commentController.dispose();
    _leaveReasonController.dispose();
    _leaveFromController.dispose();
    _leaveToController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final String message = _commentController.text.trim();
    if (message.isEmpty) {
      _showMessage(widget.isArabic ? 'اكتب تعليق ولي الأمر أولاً.' : 'Please write the parent comment first.');
      return;
    }

    await _submit(
      requestType: 'comment',
      title: widget.isArabic ? 'تعليق ولي أمر' : 'Parent comment',
      message: message,
    );
    if (mounted) _commentController.clear();
  }

  Future<void> _submitLeaveRequest() async {
    final String reason = _leaveReasonController.text.trim();
    if (reason.isEmpty) {
      _showMessage(widget.isArabic ? 'اكتب سبب طلب الإجازة أولاً.' : 'Please write the leave request reason first.');
      return;
    }

    await _submit(
      requestType: 'leave_request',
      title: widget.isArabic ? 'طلب إجازة' : 'Leave request',
      message: reason,
      leaveFrom: _leaveFromController.text.trim(),
      leaveTo: _leaveToController.text.trim(),
    );
    if (mounted) {
      _leaveReasonController.clear();
      _leaveFromController.clear();
      _leaveToController.clear();
    }
  }

  Future<void> _submit({
    required String requestType,
    required String title,
    required String message,
    String leaveFrom = '',
    String leaveTo = '',
  }) async {
    if (_saving) return;
    setState(() => _saving = true);

    final result = await _service.submit(
      session: widget.session,
      requestType: requestType,
      parentName: _parentNameController.text.trim(),
      title: title,
      message: message,
      leaveFrom: leaveFrom,
      leaveTo: leaveTo,
    );

    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.success) _refreshRequests();
    });

    _showMessage(result.success
        ? (widget.isArabic ? 'تم إرسال الطلب للمشرف بنجاح.' : 'Request sent to the supervisor successfully.')
        : (result.message.isEmpty ? (widget.isArabic ? 'تعذر إرسال الطلب.' : 'Could not submit request.') : result.message));
  }

  void _showMessage(String message) {
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
          title: Text(widget.isArabic ? 'تعليقات ولي الأمر' : 'Parent Feedback'),
          actions: [
            IconButton(
              onPressed: () => setState(_refreshRequests),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: widget.isArabic ? 'تحديث الردود' : 'Refresh replies',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => setState(_refreshRequests),
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              _HeaderCard(isArabic: widget.isArabic, session: widget.session),
              SizedBox(height: r.s(16)),
              _RequestHistoryCard(
                isArabic: widget.isArabic,
                future: _requestsFuture,
              ),
              SizedBox(height: r.s(16)),
              _InputCard(
                child: TextField(
                  controller: _parentNameController,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'اسم ولي الأمر - اختياري' : 'Parent name - optional',
                    prefixIcon: const Icon(Icons.person_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                  ),
                ),
              ),
              SizedBox(height: r.s(14)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.radius(24)),
                  boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(20), offset: Offset(0, r.s(8)))],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: AppColors.navy700.withOpacity(.65),
                      indicatorColor: AppColors.schoolRed,
                      tabs: [
                        Tab(icon: const Icon(Icons.chat_bubble_rounded), text: widget.isArabic ? 'تعليق' : 'Comment'),
                        Tab(icon: const Icon(Icons.event_available_rounded), text: widget.isArabic ? 'طلب إجازة' : 'Leave'),
                      ],
                    ),
                    SizedBox(
                      height: r.s(430),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _CommentForm(
                            isArabic: widget.isArabic,
                            controller: _commentController,
                            saving: _saving,
                            onSubmit: _submitComment,
                          ),
                          _LeaveForm(
                            isArabic: widget.isArabic,
                            reasonController: _leaveReasonController,
                            fromController: _leaveFromController,
                            toController: _leaveToController,
                            saving: _saving,
                            onSubmit: _submitLeaveRequest,
                          ),
                        ],
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

class _RequestHistoryCard extends StatelessWidget {
  const _RequestHistoryCard({required this.isArabic, required this.future});

  final bool isArabic;
  final Future<List<ParentRequestItem>> future;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(15)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(24)),
        boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))],
      ),
      child: FutureBuilder<List<ParentRequestItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(r.s(12)),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final List<ParentRequestItem> items = snapshot.data ?? [];
          if (snapshot.hasError || items.isEmpty) {
            return Text(
              isArabic ? 'لا توجد تعليقات أو ردود سابقة حالياً.' : 'No previous comments or replies yet.',
              style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13), fontWeight: FontWeight.w800, height: 1.5),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'التعليقات والردود السابقة' : 'Previous comments and replies',
                style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15.5), fontWeight: FontWeight.w900),
              ),
              SizedBox(height: r.s(10)),
              ...items.take(6).map((item) => Padding(
                    padding: EdgeInsets.only(bottom: r.s(10)),
                    child: _ParentRequestTile(item: item, isArabic: isArabic),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _ParentRequestTile extends StatelessWidget {
  const _ParentRequestTile({required this.item, required this.isArabic});

  final ParentRequestItem item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final Color color = item.isLeaveRequest ? const Color(0xFF059669) : const Color(0xFFEC4899);
    return Container(
      padding: EdgeInsets.all(r.s(12)),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(r.radius(18)),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(item.isLeaveRequest ? Icons.event_available_rounded : Icons.chat_bubble_rounded, color: color, size: r.s(18)),
            SizedBox(width: r.s(6)),
            Expanded(
              child: Text(item.title(isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(13.8), fontWeight: FontWeight.w900)),
            ),
            _StatusPill(status: item.status, isArabic: isArabic),
          ],
        ),
        SizedBox(height: r.s(7)),
        Text(item.message(isArabic), style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12.6), height: 1.5, fontWeight: FontWeight.w600)),
        if (item.hasReply) ...[
          SizedBox(height: r.s(10)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(r.s(11)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(15))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isArabic ? 'رد المشرف' : 'Supervisor reply', style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(12), fontWeight: FontWeight.w900)),
              SizedBox(height: r.s(5)),
              Text(item.reply(isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(12.8), height: 1.5, fontWeight: FontWeight.w700)),
              if (item.repliedAt.isNotEmpty) ...[
                SizedBox(height: r.s(5)),
                Text(item.repliedAt, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.6), fontSize: r.sp(10.5), fontWeight: FontWeight.w700)),
              ],
            ]),
          ),
        ],
        if (item.createdAt.isNotEmpty) ...[
          SizedBox(height: r.s(7)),
          Text(item.createdAt, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.55), fontSize: r.sp(10.5), fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.isArabic});

  final String status;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool replied = status == 'replied' || status == 'closed';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(8), vertical: r.s(4)),
      decoration: BoxDecoration(color: (replied ? AppColors.primaryBlue : AppColors.schoolRed).withOpacity(.09), borderRadius: BorderRadius.circular(99)),
      child: Text(
        replied ? (isArabic ? 'تم الرد' : 'Replied') : (isArabic ? 'بانتظار الرد' : 'Waiting'),
        style: TextStyle(color: replied ? AppColors.primaryBlue : AppColors.schoolRed, fontSize: r.sp(10), fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.isArabic, required this.session});

  final bool isArabic;
  final AppUserSession session;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(18)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.electricBlue], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(r.radius(28)),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(.18), blurRadius: r.s(24), offset: Offset(0, r.s(12)))],
      ),
      child: Row(
        children: [
          Container(
            width: r.s(58),
            height: r.s(58),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.17), borderRadius: BorderRadius.circular(r.radius(20))),
            child: Icon(Icons.family_restroom_rounded, color: Colors.white, size: r.s(32)),
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'تواصل ولي الأمر مع المدرسة' : 'Parent communication',
                  style: TextStyle(color: Colors.white, fontSize: r.sp(18), fontWeight: FontWeight.w900),
                ),
                SizedBox(height: r.s(5)),
                Text(
                  isArabic
                      ? 'التعليقات وطلبات الإجازة تظهر للمشرف، ويمكنك متابعة الرد هنا.'
                      : 'Comments and leave requests go to the supervisor, and replies appear here.',
                  style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: r.sp(12.8), fontWeight: FontWeight.w700, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(14)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))),
      child: child,
    );
  }
}

class _CommentForm extends StatelessWidget {
  const _CommentForm({required this.isArabic, required this.controller, required this.saving, required this.onSubmit});

  final bool isArabic;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Padding(
      padding: EdgeInsets.all(r.s(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 7,
            maxLines: 9,
            decoration: InputDecoration(
              labelText: isArabic ? 'تعليق ولي الأمر' : 'Parent comment',
              hintText: isArabic ? 'اكتب الملاحظة أو الرسالة هنا...' : 'Write the note or message here...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: saving ? null : onSubmit,
            icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded),
            label: Text(isArabic ? 'إرسال التعليق' : 'Send comment'),
          ),
        ],
      ),
    );
  }
}

class _LeaveForm extends StatelessWidget {
  const _LeaveForm({
    required this.isArabic,
    required this.reasonController,
    required this.fromController,
    required this.toController,
    required this.saving,
    required this.onSubmit,
  });

  final bool isArabic;
  final TextEditingController reasonController;
  final TextEditingController fromController;
  final TextEditingController toController;
  final bool saving;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Padding(
      padding: EdgeInsets.all(r.s(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fromController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'من تاريخ' : 'From',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                  ),
                ),
              ),
              SizedBox(width: r.s(10)),
              Expanded(
                child: TextField(
                  controller: toController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'إلى تاريخ' : 'To',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.s(12)),
          TextField(
            controller: reasonController,
            minLines: 5,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: isArabic ? 'سبب طلب الإجازة' : 'Leave request reason',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(r.radius(18))),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: saving ? null : onSubmit,
            icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.event_available_rounded),
            label: Text(isArabic ? 'إرسال طلب الإجازة' : 'Send leave request'),
          ),
        ],
      ),
    );
  }
}

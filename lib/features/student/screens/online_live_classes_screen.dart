import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/online_platform_service.dart';

class OnlineLiveClassesScreen extends StatefulWidget {
  const OnlineLiveClassesScreen({super.key, required this.isArabic, required this.session});

  final bool isArabic;
  final AppUserSession session;

  @override
  State<OnlineLiveClassesScreen> createState() => _OnlineLiveClassesScreenState();
}

class _OnlineLiveClassesScreenState extends State<OnlineLiveClassesScreen> {
  final OnlinePlatformService _service = OnlinePlatformService();
  late Future<OnlineLiveStatus> _future;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchLiveStatus(widget.session);
  }

  void _refresh() {
    final Future<OnlineLiveStatus> nextFuture = _service.fetchLiveStatus(widget.session);
    if (!mounted) return;
    setState(() {
      _future = nextFuture;
    });
  }

  Future<void> _join(OnlineLiveClass item) async {
    if (_joining) return;
    setState(() => _joining = true);
    try {
      final String url = await _service.joinLive(session: widget.session, scheduleId: item.id);
      final Uri? uri = Uri.tryParse(url);
      if (uri == null) throw StateError(widget.isArabic ? 'رابط الحصة غير صالح.' : 'Invalid class link.');
      final bool ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) throw StateError(widget.isArabic ? 'تعذر فتح الحصة.' : 'Unable to open live class.');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceFirst('Bad state: ', ''))));
    } finally {
      if (mounted) setState(() => _joining = false);
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
          title: Text(widget.isArabic ? 'الحصص المباشرة' : 'Live Classes'),
          actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded))],
        ),
        body: FutureBuilder<OnlineLiveStatus>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return _Message(text: '$snapshot'.replaceFirst('AsyncSnapshot<OnlineLiveStatus>(ConnectionState.done, null, ', '').replaceAll(')', ''));
            final status = snapshot.data!;
            final List<OnlineLiveClass> rows = [...status.live, ...status.upcoming];
            return ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                _LiveHeader(isArabic: widget.isArabic, status: status),
                SizedBox(height: r.s(14)),
                if (rows.isEmpty) _Message(text: widget.isArabic ? 'لا توجد حصص في الجدول حالياً.' : 'No live classes in the schedule yet.'),
                ...rows.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: r.s(12)),
                      child: _LiveClassCard(
                        isArabic: widget.isArabic,
                        item: item,
                        joining: _joining,
                        onJoin: item.isLive ? () => _join(item) : null,
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({required this.isArabic, required this.status});
  final bool isArabic;
  final OnlineLiveStatus status;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final bool live = status.hasLive;
    return Container(
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.radius(24)),
        gradient: LinearGradient(colors: live ? const [Color(0xFFEF1D2D), Color(0xFFFF7A8A)] : const [AppColors.navy950, AppColors.primaryBlue]),
        boxShadow: [BoxShadow(color: (live ? AppColors.schoolRed : AppColors.primaryBlue).withOpacity(.18), blurRadius: r.s(22), offset: Offset(0, r.s(10)))],
      ),
      child: Row(children: [
        Icon(live ? Icons.notifications_active_rounded : Icons.schedule_rounded, color: Colors.white, size: r.s(30)),
        SizedBox(width: r.s(12)),
        Expanded(child: Text(live ? (isArabic ? 'يوجد حصة مباشرة الآن' : 'A live class is running now') : (isArabic ? 'لا توجد حصة مباشرة الآن' : 'No live class right now'), style: TextStyle(color: Colors.white, fontSize: r.sp(16), fontWeight: FontWeight.w900, height: 1.35))),
      ]),
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  const _LiveClassCard({required this.isArabic, required this.item, required this.joining, required this.onJoin});
  final bool isArabic;
  final OnlineLiveClass item;
  final bool joining;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(15)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: r.s(46), height: r.s(46), decoration: BoxDecoration(color: (item.isLive ? AppColors.schoolRed : AppColors.primaryBlue).withOpacity(.10), borderRadius: BorderRadius.circular(r.radius(16))), child: Icon(item.isLive ? Icons.live_tv_rounded : Icons.calendar_month_rounded, color: item.isLive ? AppColors.schoolRed : AppColors.primaryBlue)),
          SizedBox(width: r.s(10)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.subject, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(16), fontWeight: FontWeight.w900)),
            Text('${item.dayName} · ${item.start} - ${item.end}', style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12.5), fontWeight: FontWeight.w700)),
          ])),
          _Pill(text: item.isLive ? (isArabic ? 'الآن' : 'LIVE') : item.dayName, color: item.isLive ? AppColors.schoolRed : AppColors.primaryBlue),
        ]),
        SizedBox(height: r.s(10)),
        Text('${isArabic ? 'المعلم' : 'Teacher'}: ${item.teacher}', style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13), fontWeight: FontWeight.w700)),
        if (item.message.isNotEmpty) Padding(padding: EdgeInsets.only(top: r.s(7)), child: Text(item.message, style: TextStyle(color: AppColors.schoolRed, fontSize: r.sp(12), fontWeight: FontWeight.w800))),
        SizedBox(height: r.s(12)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onJoin == null || joining ? null : onJoin,
            icon: joining && onJoin != null ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.video_call_rounded),
            label: Text(item.isLive ? (isArabic ? 'دخول الحصة الآن' : 'Join live class') : (isArabic ? 'تفتح في وقتها' : 'Opens at class time')),
          ),
        ),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Container(padding: EdgeInsets.symmetric(horizontal: r.s(9), vertical: r.s(5)), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(999)), child: Text(text, style: TextStyle(color: color, fontSize: r.sp(11), fontWeight: FontWeight.w900)));
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Container(padding: EdgeInsets.all(r.s(18)), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(14), fontWeight: FontWeight.w800)));
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/learning_content_service.dart';
import 'internal_file_viewer_screen.dart';

class LearningContentScreen extends StatefulWidget {
  const LearningContentScreen({
    super.key,
    required this.isArabic,
    required this.contentType,
    required this.title,
    required this.session,
    required this.schoolOnly,
  });

  final bool isArabic;
  final String contentType;
  final String title;
  final AppUserSession session;
  final bool schoolOnly;

  @override
  State<LearningContentScreen> createState() => _LearningContentScreenState();
}

class _LearningContentScreenState extends State<LearningContentScreen> {
  final LearningContentService _service = LearningContentService();
  late Future<List<LearningItem>> _future;

  bool get _isBooks => widget.contentType == 'books';

  @override
  void initState() {
    super.initState();
    _future = _service.fetch(session: widget.session, contentType: widget.contentType, schoolOnly: widget.schoolOnly);
  }

  Future<void> _openItem(LearningItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InternalFileViewerScreen(item: item, isArabic: widget.isArabic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.navy950, title: Text(widget.title)),
        body: FutureBuilder<List<LearningItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final bool online = widget.session.userType == AppUserType.onlineStudent;
              return _StateMessage(
                message: online
                    ? (widget.isArabic ? 'تعذر تحميل محتوى المنصة حالياً. تأكد من رفع mobile_api وتحديث الصفحة.' : 'Unable to load online platform content now. Please check the mobile_api upload and refresh.')
                    : (widget.isArabic ? 'لم يصل محتوى من الداش بورد لهذه الصفحة حالياً.' : 'No dashboard content is available for this section yet.'),
              );
            }
            final List<LearningItem> items = snapshot.data ?? [];
            if (items.isEmpty) {
              return _StateMessage(message: widget.isArabic ? 'لا يوجد محتوى مرفوع حالياً.' : 'No content uploaded yet.');
            }

            if (_isBooks) {
              return GridView.builder(
                padding: EdgeInsets.all(r.pagePadding),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: r.s(12),
                  mainAxisSpacing: r.s(12),
                  childAspectRatio: .68,
                ),
                itemBuilder: (context, index) => _BookCoverCard(
                  item: items[index],
                  isArabic: widget.isArabic,
                  onTap: () => _openItem(items[index]),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(r.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
              itemBuilder: (context, index) {
                final LearningItem item = items[index];
                return _LearningListCard(item: item, isArabic: widget.isArabic, onTap: () => _openItem(item));
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookCoverCard extends StatelessWidget {
  const _BookCoverCard({required this.item, required this.isArabic, required this.onTap});

  final LearningItem item;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool hasThumb = item.thumbnailUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radius(24)),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(24)),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.07)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy900.withOpacity(.055),
              blurRadius: r.s(20),
              offset: Offset(0, r.s(10)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEBF4FF), Color(0xFFFFF3F4)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: hasThumb
                    ? Image.network(
                        item.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _FilePlaceholder(icon: _iconFor(item), compact: false),
                      )
                    : _FilePlaceholder(icon: _iconFor(item), compact: false),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.s(11)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title(isArabic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.navy950, fontSize: r.sp(13.4), fontWeight: FontWeight.w900, height: 1.25),
                  ),
                  SizedBox(height: r.s(8)),
                  Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: AppColors.schoolRed, size: r.s(16)),
                      SizedBox(width: r.s(5)),
                      Expanded(
                        child: Text(
                          item.hasPrimaryUrl ? (isArabic ? 'يفتح داخل التطبيق' : 'Open inside app') : (isArabic ? 'عرض تفاصيل' : 'View details'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.navy700.withOpacity(.74), fontSize: r.sp(11.2), fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningListCard extends StatelessWidget {
  const _LearningListCard({required this.item, required this.isArabic, required this.onTap});

  final LearningItem item;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool hasThumb = item.thumbnailUrl.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radius(24)),
      child: Container(
        padding: EdgeInsets.all(r.s(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(24)),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(.06)),
          boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: r.s(72),
            height: r.s(82),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(18)),
              gradient: const LinearGradient(colors: [Color(0xFFEBF4FF), Color(0xFFFFF3F4)]),
            ),
            child: hasThumb
                ? Image.network(item.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _FilePlaceholder(icon: _iconFor(item), compact: true))
                : _FilePlaceholder(icon: _iconFor(item), compact: true),
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title(isArabic),
                      style: TextStyle(color: AppColors.navy950, fontSize: r.sp(15.2), fontWeight: FontWeight.w900, height: 1.35),
                    ),
                  ),
                  Icon(item.hasPrimaryUrl ? Icons.open_in_full_rounded : Icons.info_outline_rounded, color: AppColors.primaryBlue.withOpacity(.75), size: r.s(18)),
                ],
              ),
              if (item.description(isArabic).trim().isNotEmpty) ...[
                SizedBox(height: r.s(7)),
                Text(
                  item.description(isArabic),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13), height: 1.55, fontWeight: FontWeight.w600),
                ),
              ],
              if (item.contentType == 'online_attendance') _AttendanceInline(item: item, isArabic: isArabic),
              if (item.contentType == 'online_question_bank') _QuestionBankInline(item: item, isArabic: isArabic),
              SizedBox(height: r.s(10)),
              Wrap(
                spacing: r.s(8),
                runSpacing: r.s(8),
                children: [
                  _SmallPill(icon: Icons.visibility_rounded, label: isArabic ? 'عرض داخلي' : 'Internal view'),
                  if (item.badge.isNotEmpty) _SmallPill(icon: Icons.local_offer_rounded, label: item.badge),
                  if (item.createdAt.isNotEmpty) _SmallPill(icon: Icons.schedule_rounded, label: item.createdAt),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FilePlaceholder extends StatelessWidget {
  const _FilePlaceholder({required this.icon, required this.compact});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(top: -r.s(22), right: -r.s(20), child: CircleAvatar(radius: r.s(52), backgroundColor: AppColors.primaryBlue.withOpacity(.10))),
        Positioned(bottom: -r.s(30), left: -r.s(22), child: CircleAvatar(radius: r.s(58), backgroundColor: AppColors.schoolRed.withOpacity(.10))),
        Center(
          child: Container(
            width: compact ? r.s(48) : r.s(78),
            height: compact ? r.s(48) : r.s(92),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(compact ? 16 : 18)),
              gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.electricBlue]),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(.18), blurRadius: r.s(16), offset: Offset(0, r.s(8)))],
            ),
            child: Icon(icon, color: Colors.white, size: compact ? r.s(25) : r.s(42)),
          ),
        ),
      ],
    );
  }
}


class _AttendanceInline extends StatelessWidget {
  const _AttendanceInline({required this.item, required this.isArabic});
  final LearningItem item;
  final bool isArabic;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final num percentNum = item.meta['percentage'] is num ? item.meta['percentage'] as num : num.tryParse('${item.meta['percentage'] ?? 0}') ?? 0;
    final double value = (percentNum / 100).clamp(0, 1).toDouble();
    return Padding(
      padding: EdgeInsets.only(top: r.s(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: value, minHeight: r.s(8), backgroundColor: const Color(0xFFE5EDF7))),
        SizedBox(height: r.s(6)),
        Text('${isArabic ? 'نسبة الحضور' : 'Attendance'}: ${percentNum.toString()}%', style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12), fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _QuestionBankInline extends StatelessWidget {
  const _QuestionBankInline({required this.item, required this.isArabic});
  final LearningItem item;
  final bool isArabic;
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final options = item.meta['options'];
    final List<Widget> optionWidgets = [];
    if (options is Map) {
      for (final entry in options.entries) {
        optionWidgets.add(Padding(padding: EdgeInsets.only(top: r.s(3)), child: Text('${entry.key}. ${entry.value}', style: TextStyle(color: AppColors.navy900, fontSize: r.sp(12), fontWeight: FontWeight.w700))));
      }
    }
    final answer = '${item.meta['answer_key'] ?? ''}'.trim();
    if (optionWidgets.isEmpty && answer.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: r.s(10)),
      child: Container(
        padding: EdgeInsets.all(r.s(10)),
        decoration: BoxDecoration(color: const Color(0xFFF7FAFF), borderRadius: BorderRadius.circular(r.radius(16))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (optionWidgets.isNotEmpty) ...optionWidgets,
          if (answer.isNotEmpty) Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(isArabic ? 'عرض الإجابة النموذجية' : 'Show model answer', style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(12.5), fontWeight: FontWeight.w900)),
              children: [Align(alignment: AlignmentDirectional.centerStart, child: Text(answer, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(13), fontWeight: FontWeight.w800)))],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(9), vertical: r.s(5)),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(.08), borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: r.s(13)),
          SizedBox(width: r.s(4)),
          Text(label, style: TextStyle(color: AppColors.primaryBlue, fontSize: r.sp(10.5), fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

IconData _iconFor(LearningItem item) {
  switch (item.iconName) {
    case IconDataName.video:
      return Icons.play_circle_fill_rounded;
    case IconDataName.image:
      return Icons.image_rounded;
    case IconDataName.pdf:
      return Icons.picture_as_pdf_rounded;
    case IconDataName.presentation:
      return Icons.slideshow_rounded;
    case IconDataName.file:
      return Icons.insert_drive_file_rounded;
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.pagePadding),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.navy700, fontSize: r.sp(15), fontWeight: FontWeight.w800, height: 1.6),
        ),
      ),
    );
  }
}

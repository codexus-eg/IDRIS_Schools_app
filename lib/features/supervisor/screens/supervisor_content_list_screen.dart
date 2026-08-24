import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';
import 'supervisor_content_form_screen.dart';

class SupervisorContentListScreen extends StatefulWidget {
  const SupervisorContentListScreen({
    super.key,
    required this.isArabic,
    required this.result,
    required this.assignment,
    required this.contentType,
    required this.title,
  });

  final bool isArabic;
  final SupervisorLoginResult result;
  final SupervisorAssignment assignment;
  final String contentType;
  final String title;

  @override
  State<SupervisorContentListScreen> createState() => _SupervisorContentListScreenState();
}

class _SupervisorContentListScreenState extends State<SupervisorContentListScreen> {
  final SupervisorApiService _api = SupervisorApiService();
  late Future<List<SupervisorContentItem>> _future;

  bool get _isDailyReport => widget.contentType == 'daily_reports';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = _api.fetchContentList(
      sessionToken: widget.result.sessionToken,
      assignment: widget.assignment,
      contentType: widget.contentType,
    );
  }

  Future<void> _openForm([SupervisorContentItem? item]) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupervisorContentFormScreen(
        isArabic: widget.isArabic,
        result: widget.result,
        assignment: widget.assignment,
        mode: _isDailyReport ? SupervisorFormMode.dailyReport : SupervisorFormMode.learningContent,
        contentType: widget.contentType,
        title: item == null ? (widget.isArabic ? 'إضافة ${widget.title}' : 'Add ${widget.title}') : (widget.isArabic ? 'تعديل ${widget.title}' : 'Edit ${widget.title}'),
        item: item,
      ),
    ));
    if (!mounted) return;
    setState(_refresh);
  }

  Future<void> _delete(SupervisorContentItem item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isArabic ? 'حذف المحتوى؟' : 'Delete content?'),
        content: Text(item.title(widget.isArabic)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(widget.isArabic ? 'إلغاء' : 'Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(widget.isArabic ? 'حذف' : 'Delete')),
        ],
      ),
    );

    if (ok != true) return;
    final result = await _api.deleteContent(
      sessionToken: widget.result.sessionToken,
      assignment: widget.assignment,
      contentType: widget.contentType,
      contentId: item.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.success ? (widget.isArabic ? 'تم الحذف' : 'Deleted') : result.message)));
    if (result.success) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          title: Text(widget.title),
          actions: [IconButton(onPressed: () => _openForm(), icon: const Icon(Icons.add_circle_outline_rounded))],
        ),
        body: FutureBuilder<List<SupervisorContentItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(r.pagePadding),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(widget.isArabic ? 'لا يوجد محتوى مضاف حالياً.' : 'No content yet.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(15), fontWeight: FontWeight.w800)),
                    SizedBox(height: r.s(14)),
                    FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: Text(widget.isArabic ? 'إضافة' : 'Add')),
                  ]),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(r.pagePadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: EdgeInsets.all(r.s(16)),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title(widget.isArabic), style: TextStyle(color: AppColors.navy950, fontSize: r.sp(17), fontWeight: FontWeight.w900)),
                    if (item.description(widget.isArabic).trim().isNotEmpty) ...[
                      SizedBox(height: r.s(8)),
                      Text(item.description(widget.isArabic), style: TextStyle(color: AppColors.navy700, fontSize: r.sp(13.5), height: 1.6)),
                    ],
                    if (item.createdAt.isNotEmpty) ...[
                      SizedBox(height: r.s(8)),
                      Text(item.createdAt, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.navy700.withOpacity(.65), fontSize: r.sp(11.5))),
                    ],
                    SizedBox(height: r.s(12)),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => _openForm(item), icon: const Icon(Icons.edit_rounded), label: Text(widget.isArabic ? 'تعديل' : 'Edit'))),
                      SizedBox(width: r.s(10)),
                      Expanded(child: OutlinedButton.icon(onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline_rounded), label: Text(widget.isArabic ? 'حذف' : 'Delete'))),
                    ]),
                  ]),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), backgroundColor: AppColors.primaryBlue, child: const Icon(Icons.add, color: Colors.white)),
      ),
    );
  }
}

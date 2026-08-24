import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/responsive/app_responsive.dart';
import '../services/supervisor_api_service.dart';
import '../services/supervisor_session_service.dart';
import 'supervisor_change_password_screen.dart';
import 'supervisor_content_list_screen.dart';
import 'supervisor_student_alerts_list_screen.dart';

class SupervisorAssignmentsScreen extends StatefulWidget {
  const SupervisorAssignmentsScreen({super.key, required this.isArabic, required this.result});

  final bool isArabic;
  final SupervisorLoginResult result;

  @override
  State<SupervisorAssignmentsScreen> createState() => _SupervisorAssignmentsScreenState();
}

class _SupervisorAssignmentsScreenState extends State<SupervisorAssignmentsScreen> {
  SupervisorAssignment? _selected;
  final SupervisorSessionService _sessionService = SupervisorSessionService();

  @override
  void initState() {
    super.initState();
    _selected = widget.result.assignments.isNotEmpty ? widget.result.assignments.first : null;
  }

  void _openContent(String type, String title) {
    final assignment = _selected;
    if (assignment == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupervisorContentListScreen(
        isArabic: widget.isArabic,
        result: widget.result,
        assignment: assignment,
        contentType: type,
        title: title,
      ),
    ));
  }

  void _openChangePassword() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupervisorChangePasswordScreen(
        isArabic: widget.isArabic,
        result: widget.result,
      ),
    ));
  }

  Future<void> _logoutSupervisor() async {
    await _sessionService.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _openAlert() {
    final assignment = _selected;
    if (assignment == null || assignment.isPublic) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SupervisorStudentAlertsListScreen(
        isArabic: widget.isArabic,
        result: widget.result,
        assignment: assignment,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool isArabic = widget.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.navy950,
          title: Text(isArabic ? 'صفحة المشرف' : 'Supervisor Panel'),
          actions: [
            IconButton(
              onPressed: _openChangePassword,
              icon: const Icon(Icons.lock_reset_rounded),
              tooltip: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
            ),
            IconButton(
              onPressed: _logoutSupervisor,
              icon: const Icon(Icons.logout_rounded),
              tooltip: isArabic ? 'خروج' : 'Logout',
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.pagePadding),
            children: [
              _HeaderCard(isArabic: isArabic, result: widget.result),
              SizedBox(height: r.s(14)),
              if (widget.result.assignments.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(6)),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(20))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SupervisorAssignment>(
                      value: _selected,
                      isExpanded: true,
                      items: widget.result.assignments.map((assignment) {
                        return DropdownMenuItem<SupervisorAssignment>(
                          value: assignment,
                          child: Text(assignment.displayTitle, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy950, fontSize: r.sp(13.5))),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selected = value),
                    ),
                  ),
                ),
              SizedBox(height: r.s(14)),
              if (_selected == null)
                Container(
                  padding: EdgeInsets.all(r.s(18)),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(22))),
                  child: Text(isArabic ? 'لا توجد صفوف مرتبطة بهذا المشرف.' : 'No assigned classes.'),
                )
              else
                _Grid(
                  isArabic: isArabic,
                  isPublic: _selected!.isPublic,
                  onOpen: _openContent,
                  onAlert: _openAlert,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.isArabic, required this.result});
  final bool isArabic;
  final SupervisorLoginResult result;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return Container(
      padding: EdgeInsets.all(r.s(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.radius(30)),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.navy950, AppColors.primaryBlue]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isArabic ? 'مرحباً ${result.supervisor.name}' : 'Welcome ${result.supervisor.name}', style: TextStyle(color: Colors.white, fontSize: r.sp(23), fontWeight: FontWeight.w900)),
        SizedBox(height: r.s(8)),
        Text(isArabic ? 'العام الدراسي النشط: ${result.activeAcademicYear}' : 'Active academic year: ${result.activeAcademicYear}', style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: r.sp(14), fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.isArabic, required this.isPublic, required this.onOpen, required this.onAlert});
  final bool isArabic;
  final bool isPublic;
  final void Function(String type, String title) onOpen;
  final VoidCallback onAlert;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final List<_TileData> tiles = [
      _TileData('books', isArabic ? 'الكتب' : 'Books', Icons.menu_book_rounded),
      _TileData('reviews', isArabic ? 'المراجعات' : 'Reviews', Icons.rate_review_rounded),
      _TileData('exams', isArabic ? 'الامتحانات' : 'Exams', Icons.assignment_rounded),
      _TileData('homeworks', isArabic ? 'الواجبات' : 'Homework', Icons.edit_note_rounded),
      _TileData('videos', isArabic ? 'الفيديوهات' : 'Videos', Icons.play_circle_rounded),
      if (!isPublic) _TileData('daily_reports', isArabic ? 'التقرير اليومي' : 'Daily Reports', Icons.today_rounded),
      if (!isPublic) _TileData('alerts', isArabic ? 'تنبيه طالب' : 'Student Alert', Icons.notifications_active_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridCount(),
        crossAxisSpacing: r.s(12),
        mainAxisSpacing: r.s(12),
        childAspectRatio: .98,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return InkWell(
          borderRadius: BorderRadius.circular(r.radius(24)),
          onTap: () => tile.type == 'alerts' ? onAlert() : onOpen(tile.type, tile.title),
          child: Container(
            padding: EdgeInsets.all(r.s(15)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.radius(24)), boxShadow: [BoxShadow(color: AppColors.navy900.withOpacity(.05), blurRadius: r.s(18), offset: Offset(0, r.s(8)))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(tile.icon, color: AppColors.primaryBlue, size: r.s(42)),
              SizedBox(height: r.s(10)),
              Text(tile.title, textAlign: TextAlign.center, style: TextStyle(color: AppColors.navy950, fontSize: r.sp(14.5), fontWeight: FontWeight.w900)),
            ]),
          ),
        );
      },
    );
  }
}

class _TileData {
  const _TileData(this.type, this.title, this.icon);
  final String type;
  final String title;
  final IconData icon;
}

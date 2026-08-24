import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_user_session.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/services/app_session_service.dart';
import '../../home/home_screen.dart';
import 'learning_content_screen.dart';
import 'parent_feedback_screen.dart';
import 'online_discussion_screen.dart';
import 'online_assessment_list_screen.dart';
import 'online_live_classes_screen.dart';
import '../services/online_platform_service.dart';

class PublicStudentHomeScreen extends StatelessWidget {
  const PublicStudentHomeScreen({super.key, required this.session});

  final AppUserSession session;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = session.isArabic;

    return _StudentPortalScaffold(
      session: session,
      title: isArabic ? 'الطالب العام' : 'Public Student',
      subtitle: '',
      schoolOnly: false,
    );
  }
}


class OnlineStudentHomeScreen extends StatelessWidget {
  const OnlineStudentHomeScreen({super.key, required this.session});

  final AppUserSession session;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = session.isArabic;

    return _StudentPortalScaffold(
      session: session,
      title: isArabic ? 'بوابة طالب الأونلاين' : 'Online Student Portal',
      subtitle: isArabic ? 'نفس محتوى المنصة داخل التطبيق' : 'The same platform content inside the app',
      schoolOnly: false,
    );
  }
}

class SchoolStudentHomeScreen extends StatelessWidget {
  const SchoolStudentHomeScreen({super.key, required this.session});

  final AppUserSession session;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = session.isArabic;

    return _StudentPortalScaffold(
      session: session,
      title: isArabic ? 'بوابة طالب المدرسة' : 'School Student Portal',
      subtitle: '',
      schoolOnly: true,
    );
  }
}

class _StudentPortalScaffold extends StatelessWidget {
  const _StudentPortalScaffold({
    required this.session,
    required this.title,
    required this.subtitle,
    required this.schoolOnly,
  });

  final AppUserSession session;
  final String title;
  final String subtitle;
  final bool schoolOnly;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = session.isArabic;
    final AppResponsive r = AppResponsive.of(context);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(r.pagePadding, r.s(10), r.pagePadding, r.pagePadding),
            children: [
              _TopBar(title: title, isArabic: isArabic),
              SizedBox(height: r.s(14)),
              _HeroCard(session: session, subtitle: subtitle, schoolOnly: schoolOnly),
              SizedBox(height: r.s(16)),
              _QuickInfoRow(session: session, schoolOnly: schoolOnly),
              if (session.userType == AppUserType.onlineStudent) ...[
                SizedBox(height: r.s(14)),
                _OnlineLiveBanner(session: session, isArabic: isArabic),
              ],
              SizedBox(height: r.s(20)),
              Text(
                isArabic ? 'بوابتك التعليمية' : 'Your Learning Portal',
                style: TextStyle(
                  color: AppColors.navy950,
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: r.s(10)),
              _Grid(isArabic: isArabic, schoolOnly: schoolOnly, session: session),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.isArabic});

  final String title;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.navy950,
              fontSize: r.sp(22),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _LogoutButton(isArabic: isArabic),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.session,
    required this.subtitle,
    required this.schoolOnly,
  });

  final AppUserSession session;
  final String subtitle;
  final bool schoolOnly;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.radius(32)),
        gradient: const LinearGradient(
          colors: [AppColors.navy950, AppColors.primaryBlue, AppColors.electricBlue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(.22),
            blurRadius: r.s(30),
            offset: Offset(0, r.s(16)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -r.s(42),
            left: -r.s(28),
            child: _GlowCircle(size: r.s(120), opacity: .13),
          ),
          Positioned(
            bottom: -r.s(58),
            right: -r.s(38),
            child: _GlowCircle(size: r.s(150), opacity: .12),
          ),
          Padding(
            padding: EdgeInsets.all(r.s(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: r.s(58),
                      height: r.s(58),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(r.radius(22)),
                        border: Border.all(color: Colors.white.withOpacity(.18)),
                      ),
                      child: Icon(
                        schoolOnly ? Icons.school_rounded : Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: r.s(31),
                      ),
                    ),
                    SizedBox(width: r.s(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.isArabic ? 'مرحباً ${session.name}' : 'Welcome ${session.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: r.sp(22),
                              fontWeight: FontWeight.w900,
                              height: 1.22,
                            ),
                          ),
                          if (subtitle.trim().isNotEmpty) ...[
                            SizedBox(height: r.s(5)),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.84),
                                fontSize: r.sp(13.2),
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (session.grade != null || session.branchName != null || session.studentCode != null) ...[
                  SizedBox(height: r.s(16)),
                  Wrap(
                    spacing: r.s(8),
                    runSpacing: r.s(8),
                    children: [
                      if (session.grade != null) _MiniChip(icon: Icons.layers_rounded, text: session.grade!),
                      if (session.branchName != null) _MiniChip(icon: Icons.location_city_rounded, text: session.branchName!),
                      if (session.studentCode != null) _MiniChip(icon: Icons.badge_rounded, text: session.studentCode!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoRow extends StatelessWidget {
  const _QuickInfoRow({required this.session, required this.schoolOnly});

  final AppUserSession session;
  final bool schoolOnly;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final bool isArabic = session.isArabic;

    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.menu_book_rounded,
            title: isArabic ? 'المحتوى' : 'Content',
            value: isArabic ? 'متجدد' : 'Updated',
          ),
        ),
        SizedBox(width: r.s(10)),
        Expanded(
          child: _InfoCard(
            icon: session.userType == AppUserType.onlineStudent ? Icons.cast_for_education_rounded : (schoolOnly ? Icons.notifications_active_rounded : Icons.public_rounded),
            title: session.userType == AppUserType.onlineStudent ? (isArabic ? 'الأونلاين' : 'Online') : (schoolOnly ? (isArabic ? 'التنبيهات' : 'Alerts') : (isArabic ? 'عام' : 'Public')),
            value: session.userType == AppUserType.onlineStudent ? (isArabic ? 'مدمج' : 'Linked') : (schoolOnly ? (isArabic ? 'خاصة بك' : 'Personal') : (isArabic ? 'متاح' : 'Open')), 
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(r.s(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(22)),
        border: Border.all(color: AppColors.navy900.withOpacity(.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy900.withOpacity(.04),
            blurRadius: r.s(18),
            offset: Offset(0, r.s(8)),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: r.s(42),
            height: r.s(42),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(.08),
              borderRadius: BorderRadius.circular(r.radius(16)),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: r.s(22)),
          ),
          SizedBox(width: r.s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy700,
                    fontSize: r.sp(12),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: r.s(2)),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.navy950,
                    fontSize: r.sp(14.2),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _OnlineLiveBanner extends StatefulWidget {
  const _OnlineLiveBanner({required this.session, required this.isArabic});
  final AppUserSession session;
  final bool isArabic;

  @override
  State<_OnlineLiveBanner> createState() => _OnlineLiveBannerState();
}

class _OnlineLiveBannerState extends State<_OnlineLiveBanner> {
  final OnlinePlatformService _service = OnlinePlatformService();
  late Future<OnlineLiveStatus> _future;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchLiveStatus(widget.session);
  }

  Future<void> _join(OnlineLiveClass cls) async {
    if (_joining) return;
    setState(() => _joining = true);
    try {
      final String url = await _service.joinLive(session: widget.session, scheduleId: cls.id);
      // Keep live class entry controlled by the platform. Google Meet itself opens in Meet/browser.
      final Uri? uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrlFromHome(uri);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceFirst('Bad state: ', ''))));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    return FutureBuilder<OnlineLiveStatus>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final status = snapshot.data!;
        if (!status.hasLive || status.live.isEmpty) return const SizedBox.shrink();
        final cls = status.live.first;
        return InkWell(
          onTap: () => _join(cls),
          borderRadius: BorderRadius.circular(r.radius(24)),
          child: Container(
            padding: EdgeInsets.all(r.s(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r.radius(24)),
              gradient: const LinearGradient(colors: [Color(0xFFEF1D2D), Color(0xFFFF7A8A)]),
              boxShadow: [BoxShadow(color: AppColors.schoolRed.withOpacity(.18), blurRadius: r.s(22), offset: Offset(0, r.s(10)))],
            ),
            child: Row(children: [
              Icon(Icons.notifications_active_rounded, color: Colors.white, size: r.s(30)),
              SizedBox(width: r.s(10)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.isArabic ? 'حصة مباشرة الآن' : 'Live class now', style: TextStyle(color: Colors.white, fontSize: r.sp(15.5), fontWeight: FontWeight.w900)),
                Text('${cls.subject} · ${cls.start} - ${cls.end}', style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: r.sp(12.5), fontWeight: FontWeight.w700)),
              ])),
              ElevatedButton(onPressed: _joining ? null : () => _join(cls), child: Text(widget.isArabic ? 'دخول' : 'Join')),
            ]),
          ),
        );
      },
    );
  }
}

Future<void> launchUrlFromHome(Uri uri) async {
  // Isolated here to avoid touching the existing content viewer behavior.
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _Grid extends StatelessWidget {
  const _Grid({required this.isArabic, required this.schoolOnly, required this.session});

  final bool isArabic;
  final bool schoolOnly;
  final AppUserSession session;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final List<_TileData> tiles = [
      if (session.userType == AppUserType.onlineStudent) ...[
        _TileData('online_schedule', isArabic ? 'جدول الحصص' : 'Class Schedule', Icons.calendar_month_rounded, const Color(0xFF1D4ED8), const Color(0xFF60A5FA)),
        _TileData('online_live_classes', isArabic ? 'الحصص المباشرة' : 'Live Classes', Icons.live_tv_rounded, const Color(0xFFEF1D2D), const Color(0xFFFF7A8A)),
        _TileData('online_recordings', isArabic ? 'تسجيلات الحصص' : 'Recorded Classes', Icons.video_library_rounded, const Color(0xFF7C3AED), const Color(0xFFC084FC)),
        _TileData('online_contents', isArabic ? 'المحتوى التعليمي' : 'Learning Content', Icons.folder_copy_rounded, const Color(0xFF0EA5E9), const Color(0xFF67E8F9)),
        _TileData('online_question_bank', isArabic ? 'بنك الأسئلة' : 'Question Bank', Icons.psychology_rounded, const Color(0xFF8B5CF6), const Color(0xFFDDD6FE)),
        _TileData('online_assessments', isArabic ? 'الاختبارات' : 'Quizzes & Exams', Icons.assignment_rounded, const Color(0xFFFF7A1A), const Color(0xFFFFC857)),
        _TileData('online_activities', isArabic ? 'الأنشطة والواجبات' : 'Activities', Icons.edit_note_rounded, const Color(0xFF059669), const Color(0xFF34D399)),
        _TileData('online_attendance', isArabic ? 'الحضور' : 'Attendance', Icons.fact_check_rounded, const Color(0xFF10B981), const Color(0xFF86EFAC)),
        _TileData('online_discussion', isArabic ? 'المناقشات' : 'Discussion', Icons.forum_rounded, const Color(0xFFEC4899), const Color(0xFFF9A8D4)),
        _TileData('online_announcements', isArabic ? 'الإعلانات' : 'Announcements', Icons.campaign_rounded, const Color(0xFFF59E0B), const Color(0xFFFDE68A)),
        _TileData('online_notifications', isArabic ? 'الإشعارات' : 'Notifications', Icons.notifications_active_rounded, const Color(0xFF2563EB), const Color(0xFF93C5FD)),
        _TileData('online_results', isArabic ? 'نتائجي' : 'My Results', Icons.analytics_rounded, const Color(0xFF0F766E), const Color(0xFF5EEAD4)),
      ] else ...[
        _TileData('books', isArabic ? 'الكتب' : 'Books', Icons.menu_book_rounded, const Color(0xFF1D4ED8), const Color(0xFF60A5FA)),
        _TileData('reviews', isArabic ? 'المراجعات' : 'Reviews', Icons.rate_review_rounded, const Color(0xFFFF7A1A), const Color(0xFFFFC857)),
        _TileData('exams', isArabic ? 'الامتحانات' : 'Exams', Icons.assignment_rounded, const Color(0xFF7C3AED), const Color(0xFFC084FC)),
        _TileData('homeworks', isArabic ? 'الواجبات' : 'Homework', Icons.edit_note_rounded, const Color(0xFF059669), const Color(0xFF34D399)),
        _TileData('videos', isArabic ? 'الفيديوهات' : 'Videos', Icons.play_circle_rounded, const Color(0xFFEF1D2D), const Color(0xFFFF7A8A)),
      ],
      if (schoolOnly) _TileData('parent_feedback', isArabic ? 'تعليقات ولي الأمر' : 'Parent Feedback', Icons.family_restroom_rounded, const Color(0xFFEC4899), const Color(0xFFF9A8D4)),
      if (schoolOnly) _TileData('daily_reports', isArabic ? 'التقرير اليومي' : 'Daily Reports', Icons.today_rounded, const Color(0xFF0EA5E9), const Color(0xFF67E8F9)),
      if (schoolOnly) _TileData('alerts', isArabic ? 'تنبيهاتي' : 'My Alerts', Icons.notifications_active_rounded, const Color(0xFFF59E0B), const Color(0xFFFDE68A)),
      if (schoolOnly) _TileData('fees', isArabic ? 'الأقساط والرسوم' : 'Fees', Icons.payments_rounded, const Color(0xFF10B981), const Color(0xFF86EFAC)),
      if (schoolOnly) _TileData('level', isArabic ? 'مستوى الطالب' : 'Student Level', Icons.trending_up_rounded, const Color(0xFF2563EB), const Color(0xFF93C5FD)),
      if (schoolOnly) _TileData('notes', isArabic ? 'تعليقات الأساتذة' : 'Teacher Notes', Icons.comment_rounded, const Color(0xFF8B5CF6), const Color(0xFFDDD6FE)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.gridCount(),
        crossAxisSpacing: r.s(12),
        mainAxisSpacing: r.s(12),
        childAspectRatio: .93,
      ),
      itemBuilder: (context, index) {
        final _TileData tile = tiles[index];

        return _StudentTile(
          tile: tile,
          isArabic: isArabic,
          session: session,
          schoolOnly: schoolOnly,
        );
      },
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.tile,
    required this.isArabic,
    required this.session,
    required this.schoolOnly,
  });

  final _TileData tile;
  final bool isArabic;
  final AppUserSession session;
  final bool schoolOnly;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(r.radius(26)),
      onTap: () {
        if (tile.type == 'parent_feedback') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ParentFeedbackScreen(isArabic: isArabic, session: session),
            ),
          );
          return;
        }

        if (session.userType == AppUserType.onlineStudent && tile.type == 'online_live_classes') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnlineLiveClassesScreen(isArabic: isArabic, session: session),
            ),
          );
          return;
        }

        if (session.userType == AppUserType.onlineStudent && tile.type == 'online_discussion') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnlineDiscussionScreen(isArabic: isArabic, session: session),
            ),
          );
          return;
        }

        if (session.userType == AppUserType.onlineStudent && tile.type == 'online_assessments') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnlineAssessmentListScreen(isArabic: isArabic, session: session),
            ),
          );
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LearningContentScreen(
              isArabic: isArabic,
              contentType: tile.type,
              title: tile.title,
              session: session,
              schoolOnly: schoolOnly,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(r.s(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(26)),
          border: Border.all(color: AppColors.navy900.withOpacity(.04)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy900.withOpacity(.055),
              blurRadius: r.s(20),
              offset: Offset(0, r.s(10)),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -r.s(18),
              left: -r.s(14),
              child: Container(
                width: r.s(62),
                height: r.s(62),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tile.colorB.withOpacity(.13),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: r.s(58),
                  height: r.s(58),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tile.colorA, tile.colorB],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(r.radius(22)),
                    boxShadow: [
                      BoxShadow(
                        color: tile.colorA.withOpacity(.20),
                        blurRadius: r.s(16),
                        offset: Offset(0, r.s(8)),
                      ),
                    ],
                  ),
                  child: Icon(tile.icon, color: Colors.white, size: r.s(29)),
                ),
                SizedBox(height: r.s(12)),
                Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy950,
                    fontSize: r.sp(14.4),
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TileData {
  const _TileData(this.type, this.title, this.icon, this.colorA, this.colorB);

  final String type;
  final String title;
  final IconData icon;
  final Color colorA;
  final Color colorB;
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(7)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: r.s(14)),
          SizedBox(width: r.s(5)),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: r.sp(12),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: () async {
        await AppSessionService().clear();

        if (!context.mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      },
      tooltip: isArabic ? 'خروج' : 'Logout',
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/app_responsive.dart';
import '../auth/screens/create_account_screen.dart';
import '../auth/screens/login_screen.dart';
import '../supervisor/screens/supervisor_login_screen.dart';
import 'models/app_home_page.dart';
import 'services/app_home_content_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum HomeLanguage { ar, en }

class _HomeScreenState extends State<HomeScreen> {
  final AppHomeContentService _contentService = AppHomeContentService();

  HomeLanguage _language = HomeLanguage.ar;
  int _selectedTab = 0;
  bool _isLoadingContent = true;
  List<AppHomePage> _pages = AppHomePage.fallback();

  bool get _isArabic => _language == HomeLanguage.ar;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final AppHomeContentResult result = await _contentService.fetchHomeContent();

      if (!mounted) return;

      final int defaultIndex = result.pages.indexWhere((page) => page.key == result.defaultTab);

      setState(() {
        _pages = result.pages;
        _selectedTab = defaultIndex >= 0 ? defaultIndex : 0;
        _isLoadingContent = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _pages = AppHomePage.fallback();
        _selectedTab = 0;
        _isLoadingContent = false;
      });
    }
  }

  List<String> get _tabs => _pages.map((page) => page.title(_isArabic)).toList();

  void _openCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateAccountScreen(isArabic: _isArabic)),
    );
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen(isArabic: _isArabic)),
    );
  }

  void _openSupervisorLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SupervisorLoginScreen(isArabic: _isArabic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);
    final TextDirection direction = _isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                isArabic: _isArabic,
                language: _language,
                onLanguageChanged: (HomeLanguage value) {
                  setState(() => _language = value);
                },
                onCreateAccount: _openCreateAccount,
                onLogin: _openLogin,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadContent,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(r.pagePadding, r.s(8), r.pagePadding, r.s(24)),
                    children: [
                      _HeroPortal(
                        isArabic: _isArabic,
                        onCreateAccount: _openCreateAccount,
                        onHiddenSupervisorTap: _openSupervisorLogin,
                      ),
                      SizedBox(height: r.s(18)),
                      if (_isLoadingContent) ...[
                        const LinearProgressIndicator(minHeight: 3),
                        SizedBox(height: r.s(14)),
                      ],
                      _TabsSelector(
                        tabs: _tabs,
                        selectedIndex: _selectedTab,
                        onSelected: (int index) {
                          setState(() => _selectedTab = index);
                        },
                      ),
                      SizedBox(height: r.s(16)),
                      _TabContent(
                        page: _pages[_selectedTab.clamp(0, _pages.length - 1)],
                        isArabic: _isArabic,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isArabic,
    required this.language,
    required this.onLanguageChanged,
    required this.onCreateAccount,
    required this.onLogin,
  });

  final bool isArabic;
  final HomeLanguage language;
  final ValueChanged<HomeLanguage> onLanguageChanged;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(r.s(18), r.s(14), r.s(18), r.s(8)),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: r.s(8),
              runSpacing: r.s(8),
              children: [
                _HeaderButton(
                  text: isArabic ? 'إنشاء حساب' : 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  color: AppColors.primaryBlue,
                  onTap: onCreateAccount,
                ),
                _HeaderButton(
                  text: isArabic ? 'دخول' : 'Login',
                  icon: Icons.login_rounded,
                  color: AppColors.schoolRed,
                  onTap: onLogin,
                ),
              ],
            ),
          ),
          SizedBox(width: r.s(10)),
          Container(
            padding: EdgeInsets.all(r.s(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy900.withOpacity(0.06),
                  blurRadius: r.s(18),
                  offset: Offset(0, r.s(8)),
                ),
              ],
            ),
            child: Row(
              children: [
                _LanguageButton(text: 'AR', selected: language == HomeLanguage.ar, onTap: () => onLanguageChanged(HomeLanguage.ar)),
                _LanguageButton(text: 'EN', selected: language == HomeLanguage.en, onTap: () => onLanguageChanged(HomeLanguage.en)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.text, required this.icon, required this.color, required this.onTap});

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: r.s(18)),
      label: Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: r.sp(13))),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: r.s(13), vertical: r.s(11)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(16))),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(7)),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy950 : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.navy700,
            fontWeight: FontWeight.w900,
            fontSize: r.sp(12),
          ),
        ),
      ),
    );
  }
}

class _HeroPortal extends StatelessWidget {
  const _HeroPortal({
    required this.isArabic,
    required this.onCreateAccount,
    required this.onHiddenSupervisorTap,
  });

  final bool isArabic;
  final VoidCallback onCreateAccount;
  final VoidCallback onHiddenSupervisorTap;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(r.s(20), r.s(22), r.s(20), r.s(22)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.radius(34)),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.navy950, AppColors.navy900, AppColors.primaryBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.20),
            blurRadius: r.s(28),
            offset: Offset(0, r.s(16)),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(end: -r.s(26), top: -r.s(28), child: _CircleDecoration(size: r.s(150), color: Colors.white.withOpacity(0.06))),
          PositionedDirectional(start: -r.s(34), bottom: -r.s(48), child: _CircleDecoration(size: r.s(150), color: AppColors.schoolRed.withOpacity(0.13))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: onHiddenSupervisorTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: r.s(13), vertical: r.s(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Text(
                    isArabic ? 'أكثر من 30 عاماً من الإنجاز' : 'More than 30 years of achievement',
                    style: TextStyle(color: Colors.white, fontSize: r.sp(12.5), fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SizedBox(height: r.s(20)),
              Text(
                isArabic ? 'مرحباً بكم في بوابتكم التعليمية' : 'Welcome to your educational portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.sp(27),
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: r.s(9)),
              Text(
                isArabic ? 'للمنهجين: السوداني - كامبريدج' : 'For both curricula: Sudanese - Cambridge',
                style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: r.sp(15.5), height: 1.4, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: r.s(18)),
              Text(
                isArabic ? 'للتتمتع بالمزايا قم بالتسجيل' : 'Register to enjoy all features',
                style: TextStyle(color: Colors.white.withOpacity(0.68), fontSize: r.sp(12.5), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: r.s(13)),
              OutlinedButton.icon(
                onPressed: onCreateAccount,
                icon: Icon(Icons.arrow_forward_rounded, size: r.s(18)),
                label: Text(isArabic ? 'ابدأ الآن' : 'Get Started', style: const TextStyle(fontWeight: FontWeight.w900)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.40)),
                  padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(16))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleDecoration extends StatelessWidget {
  const _CircleDecoration({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

class _TabsSelector extends StatelessWidget {
  const _TabsSelector({required this.tabs, required this.selectedIndex, required this.onSelected});

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return SizedBox(
      height: r.s(48),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: r.s(10)),
        itemBuilder: (context, index) {
          final bool selected = index == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: r.s(18)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.schoolRed : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: selected ? AppColors.schoolRed : AppColors.navy900.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy900.withOpacity(selected ? 0.08 : 0.04),
                    blurRadius: r.s(16),
                    offset: Offset(0, r.s(8)),
                  ),
                ],
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.navy700,
                  fontWeight: FontWeight.w900,
                  fontSize: r.sp(13.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.page, required this.isArabic});

  final AppHomePage page;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final AppResponsive r = AppResponsive.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: Container(
        key: ValueKey<String>(page.key),
        padding: EdgeInsets.all(r.s(18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy900.withOpacity(0.055),
              blurRadius: r.s(22),
              offset: Offset(0, r.s(12)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (page.heroImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(r.radius(22)),
                child: Image.network(
                  page.heroImageUrl!,
                  height: r.safeImageHeight(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: r.s(14)),
            ],
            Icon(page.icon, color: AppColors.primaryBlue, size: r.s(32)),
            SizedBox(height: r.s(12)),
            Text(
              page.title(isArabic),
              style: TextStyle(color: AppColors.navy950, fontSize: r.sp(20), fontWeight: FontWeight.w900),
            ),
            SizedBox(height: r.s(8)),
            Text(
              page.body(isArabic),
              style: TextStyle(color: AppColors.navy700, fontSize: r.sp(14.5), height: 1.6, fontWeight: FontWeight.w600),
            ),
            if (page.images.isNotEmpty) ...[
              SizedBox(height: r.s(16)),
              ...page.images.map((image) {
                final String caption = isArabic ? image.captionAr : image.captionEn;
                return Padding(
                  padding: EdgeInsets.only(bottom: r.s(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r.radius(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          image.imageUrl,
                          height: r.safeImageHeight(min: 130, max: 210),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        if (caption.trim().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: r.s(6)),
                            child: Text(caption, style: TextStyle(color: AppColors.navy700, fontSize: r.sp(12.5), fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

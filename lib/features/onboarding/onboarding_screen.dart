import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../generated/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      titleKey: 'onboardingTitle1',
      subtitleKey: 'onboardingSubtitle1',
      color: Color(0xFFE91E8C),
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_rounded,
      titleKey: 'onboardingTitle2',
      subtitleKey: 'onboardingSubtitle2',
      color: Color(0xFFF06292),
    ),
    _OnboardingSlide(
      icon: Icons.bar_chart_rounded,
      titleKey: 'onboardingTitle3',
      subtitleKey: 'onboardingSubtitle3',
      color: Color(0xFFCE93D8),
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  String _getTitle(BuildContext ctx, String key) {
    final l10n = AppLocalizations.of(ctx);
    switch (key) {
      case 'onboardingTitle1':
        return l10n.onboardingTitle1;
      case 'onboardingTitle2':
        return l10n.onboardingTitle2;
      case 'onboardingTitle3':
        return l10n.onboardingTitle3;
      default:
        return key;
    }
  }

  String _getSubtitle(BuildContext ctx, String key) {
    final l10n = AppLocalizations.of(ctx);
    switch (key) {
      case 'onboardingSubtitle1':
        return l10n.onboardingSubtitle1;
      case 'onboardingSubtitle2':
        return l10n.onboardingSubtitle2;
      case 'onboardingSubtitle3':
        return l10n.onboardingSubtitle3;
      default:
        return key;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: AppFonts.bodyM,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _slides.length,
                  itemBuilder: (ctx, i) {
                    final slide = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingXXL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  slide.color.withOpacity(0.2),
                                  slide.color.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              slide.icon,
                              size: 90,
                              color: slide.color,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingXL),

                          // Title
                          Text(
                            _getTitle(ctx, slide.titleKey),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.headingM,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingS),

                          // Subtitle
                          Text(
                            _getSubtitle(ctx, slide.subtitleKey),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.bodyL,
                              color: AppColors.lightTextSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingXL,
                  AppSizes.paddingM,
                  AppSizes.paddingXL,
                  AppSizes.paddingXXL,
                ),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _slides.length,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightM,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusXL),
                            ),
                          ),
                          child: Text(
                            isLast ? l10n.getStarted : l10n.next,
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.titleM,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

class _OnboardingSlide {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color color;

  const _OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.color,
  });
}

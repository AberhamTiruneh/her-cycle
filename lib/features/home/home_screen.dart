import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/cycle_calculator.dart';
import '../../../core/utils/ethiopian_calendar.dart';
import '../../../core/utils/health_tips.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cycle_provider.dart';
import '../../../providers/language_provider.dart';
import '../profile/screens/profile_screen.dart';
import '../calendar/calendar_screen.dart';
import '../insights/insights_screen.dart';
import '../logging/logging_screen.dart';
import '../news/news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _HomeBody(),
      const CalendarScreen(),
      const InsightsScreen(),
      const NewsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon:
                const Icon(Icons.home_rounded, color: AppColors.primary),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded,
                color: AppColors.primary),
            label: l10n.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon:
                const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            label: l10n.insights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon:
                const Icon(Icons.newspaper_rounded, color: AppColors.primary),
            label: l10n.healthNews,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon:
                const Icon(Icons.person_rounded, color: AppColors.primary),
            label: l10n.profile,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoggingScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ─── Home Body ──────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final cycles = context.watch<CycleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    if (auth.isLoading) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(AppSizes.paddingM),
          child: LoadingShimmer(type: ShimmerType.cardShimmer, itemCount: 4),
        ),
      );
    }

    final userName = auth.currentUser?.name.split(' ').first ?? 'there';
    final hasCycles = cycles.cycles.isNotEmpty;
    final lastCycle = hasCycles ? cycles.cycles.last : null;
    final now = DateTime.now();

    // Computed data
    int daysUntilPeriod = 0;
    DateTime? nextPeriodDate;
    DateTime? ovulationDate;
    Map<String, DateTime>? fertileWindow;
    String currentPhase = '';
    int currentCycleDay = 0;

    if (lastCycle != null) {
      nextPeriodDate = CycleCalculator.calculateNextPeriod(
          lastCycle.startDate, cycles.cycleLength);
      daysUntilPeriod = nextPeriodDate.difference(now).inDays;
      ovulationDate = CycleCalculator.calculateOvulationDate(
          lastCycle.startDate, cycles.cycleLength);
      fertileWindow = CycleCalculator.calculateFertileWindow(
          lastCycle.startDate, cycles.cycleLength);
      currentCycleDay = CycleCalculator.getCurrentCycleDay(
          lastCycle.startDate, cycles.cycleLength);
      currentPhase = _getPhase(
          context, lastCycle.startDate, cycles.cycleLength, cycles.periodDays);
    }

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            floating: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E8C), Color(0xFFCE93D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(AppSizes.paddingM,
                    AppSizes.paddingXL, AppSizes.paddingM, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${l10n.hello}, $userName 👋',
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.titleL,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatDate(now),
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.bodyS,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        (auth.currentUser?.name.isNotEmpty == true)
                            ? auth.currentUser!.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: AppFonts.titleM,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasCycles)
                    _EmptyStateCard(l10n: l10n)
                  else ...[
                    // Main Cycle Card
                    _CycleCard(
                      daysUntilPeriod: daysUntilPeriod,
                      currentPhase: currentPhase,
                      currentCycleDay: currentCycleDay,
                      cycleLength: cycles.cycleLength,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSizes.spacingM),

                    // Quick Stats
                    _QuickStats(
                      cycleLength: cycles.cycleLength,
                      periodDays: cycles.periodDays,
                      currentDay: currentCycleDay,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSizes.spacingM),

                    // Upcoming Events
                    _UpcomingEvents(
                      nextPeriod: nextPeriodDate,
                      ovulation: ovulationDate,
                      fertileStart: fertileWindow?['start'],
                      fertileEnd: fertileWindow?['end'],
                      l10n: l10n,
                      isDark: isDark,
                      isAmharic: context
                              .watch<LanguageProvider>()
                              .currentLanguage ==
                          'am',
                    ),
                    const SizedBox(height: AppSizes.spacingM),

                    // Recent Symptoms
                    if (lastCycle?.symptoms.isNotEmpty == true)
                      _RecentSymptoms(
                          symptoms: lastCycle!.symptoms, l10n: l10n),
                    const SizedBox(height: AppSizes.spacingM),

                    // Health Tip
                    _HealthTipBanner(
                      symptoms: lastCycle?.symptoms ?? [],
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday]}, ${months[d.month]} ${d.day}';
  }

  String _getPhase(
      BuildContext ctx, DateTime lastPeriod, int cycleLength, int periodDays) {
    final l10n = AppLocalizations.of(ctx);
    final day = CycleCalculator.getCurrentCycleDay(lastPeriod, cycleLength);
    if (day <= periodDays) return l10n.menstrualPhase;
    if (day <= 13) return l10n.follicularPhase;
    if (day == 14) return l10n.ovulationPhase;
    return l10n.lutealPhase;
  }
}

// ─── Cycle Card ──────────────────────────────────────────────────────────────

class _CycleCard extends StatelessWidget {
  final int daysUntilPeriod;
  final String currentPhase;
  final int currentCycleDay;
  final int cycleLength;
  final AppLocalizations l10n;

  const _CycleCard({
    required this.daysUntilPeriod,
    required this.currentPhase,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (cycleLength > 0 ? currentCycleDay / cycleLength : 0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _CircleProgressPainter(
                    progress: progress.toDouble(),
                    backgroundColor: Colors.white.withOpacity(0.25),
                    foregroundColor: Colors.white,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      daysUntilPeriod.abs().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.headingL,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.days,
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  daysUntilPeriod >= 0
                      ? l10n.daysUntilPeriod
                      : 'Period may be late',
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyM,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // Phase badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                  ),
                  child: Text(
                    currentPhase,
                    style: GoogleFonts.poppins(
                      fontSize: AppFonts.captionL,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.currentPhase}: Day $currentCycleDay',
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.captionL,
                    color: Colors.white.withOpacity(0.8),
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

// ─── Circular Progress Painter ───────────────────────────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter old) =>
      old.progress != progress;
}

// ─── Quick Stats ─────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final int cycleLength;
  final int periodDays;
  final int currentDay;
  final AppLocalizations l10n;

  const _QuickStats({
    required this.cycleLength,
    required this.periodDays,
    required this.currentDay,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
            child: _StatChip(
                label: l10n.cycleLength,
                value: '$cycleLength ${l10n.days}',
                icon: Icons.loop_rounded,
                isDark: isDark)),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
            child: _StatChip(
                label: 'Period Length',
                value: '$periodDays ${l10n.days}',
                icon: Icons.water_drop_rounded,
                isDark: isDark)),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
            child: _StatChip(
                label: 'Day',
                value: 'Day $currentDay',
                icon: Icons.today_rounded,
                isDark: isDark)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: AppFonts.bodyS,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Events ─────────────────────────────────────────────────────────

class _UpcomingEvents extends StatelessWidget {
  final DateTime? nextPeriod;
  final DateTime? ovulation;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;
  final AppLocalizations l10n;
  final bool isDark;
  final bool isAmharic;

  const _UpcomingEvents({
    required this.nextPeriod,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
    required this.l10n,
    required this.isDark,
    this.isAmharic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: GoogleFonts.poppins(
            fontSize: AppFonts.titleM,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (nextPeriod != null)
          _EventTile(
            icon: Icons.water_drop_rounded,
            color: AppColors.primary,
            label: l10n.nextPeriod,
            date: nextPeriod!,
            isDark: isDark,
            isAmharic: isAmharic,
          ),
        if (ovulation != null)
          _EventTile(
            icon: Icons.star_rounded,
            color: AppColors.accent,
            label: l10n.ovulation,
            date: ovulation!,
            isDark: isDark,
            isAmharic: isAmharic,
          ),
        if (fertileStart != null && fertileEnd != null)
          _EventTile(
            icon: Icons.favorite_rounded,
            color: AppColors.secondary,
            label:
                '${l10n.fertileWindow}: ${_fmt(fertileStart!, isAmharic)} – ${_fmt(fertileEnd!, isAmharic)}',
            date: fertileStart!,
            isDark: isDark,
            isAmharic: isAmharic,
            showDate: false,
          ),
      ],
    );
  }

  String _fmt(DateTime d, [bool isAmharic = false]) =>
      isAmharic ? EthiopianCalendar.formatDateShort(d) : '${d.month}/${d.day}';
}

class _EventTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final DateTime date;
  final bool isDark;
  final bool showDate;
  final bool isAmharic;

  const _EventTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.date,
    required this.isDark,
    this.showDate = true,
    this.isAmharic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: AppFonts.bodyM,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          if (showDate)
            Text(
              isAmharic
                  ? EthiopianCalendar.formatDateShort(date)
                  : '${date.month}/${date.day}',
              style: GoogleFonts.poppins(
                fontSize: AppFonts.bodyS,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Recent Symptoms ─────────────────────────────────────────────────────────

class _RecentSymptoms extends StatelessWidget {
  final List<String> symptoms;
  final AppLocalizations l10n;

  const _RecentSymptoms({required this.symptoms, required this.l10n});

  static const Map<String, String> _amharicSymptoms = {
    'Cramps': 'የሆድ ቁርጠት',
    'Headache': 'ራስ ምታት',
    'Mood Swings': 'ስሜት ለውጥ',
    'Bloating': 'የሆድ መነፋት',
    'Fatigue': 'ድካም',
    'Nausea': 'ማቅለሽለሽ',
    'Back Pain': 'የጀርባ ሕመም',
    'Breast Tenderness': 'ጡት ሕመም',
    'Spotting': 'ትንሽ ደም መፍሰስ',
    'Acne': 'ቡግር',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic =
        context.watch<LanguageProvider>().currentLanguage == 'am';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.symptoms,
          style: GoogleFonts.poppins(
            fontSize: AppFonts.titleM,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms
              .take(6)
              .map(
                (s) => Chip(
                  label: Text(
                      isAmharic ? (_amharicSymptoms[s] ?? s) : s,
                      style: GoogleFonts.poppins(
                          fontSize: AppFonts.captionL,
                          color: AppColors.primary)),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyStateCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyStateCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingXXL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_month_rounded,
              size: 64, color: Colors.white),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            l10n.noDataYet,
            style: GoogleFonts.poppins(
              fontSize: AppFonts.titleM,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startLogging,
            style: GoogleFonts.poppins(
              fontSize: AppFonts.bodyM,
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingL),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoggingScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.logPeriod,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Health Tip Banner ───────────────────────────────────────────────────────

class _HealthTipBanner extends StatelessWidget {
  final List<String> symptoms;
  final bool isDark;

  const _HealthTipBanner({required this.symptoms, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tip = HealthTips.getTopTip(symptoms);
    if (tip == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tip.color.withOpacity(0.15),
            tip.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: tip.color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(tip.icon, size: 22, color: tip.color),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '💡 Health Tip',
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS,
                        fontWeight: FontWeight.w600,
                        color: tip.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(
                        color: tip.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        HealthTips.categoryLabel(tip.category),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: tip.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip.title,
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyM,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip.description,
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyS,
                    color: AppColors.lightTextSecondary,
                    height: 1.4,
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

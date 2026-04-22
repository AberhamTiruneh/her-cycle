import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/cycle_calculator.dart';
import '../../../core/utils/health_tips.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/cycle_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycles = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    if (cycles.cycles.isEmpty) {
      return _EmptyInsights(l10n: l10n, bg: bg, isDark: isDark);
    }

    return _InsightsBody(
      cycles: cycles,
      l10n: l10n,
      isDark: isDark,
      bg: bg,
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyInsights extends StatelessWidget {
  final AppLocalizations l10n;
  final Color bg;
  final bool isDark;
  const _EmptyInsights(
      {required this.l10n, required this.bg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          l10n.insights,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: AppFonts.titleL),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 80, color: AppColors.primary.withOpacity(0.4)),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                l10n.noDataYet,
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.titleM,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log at least one cycle to see your insights.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.bodyM,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Insights Body ────────────────────────────────────────────────────────────

class _InsightsBody extends StatelessWidget {
  final CycleProvider cycles;
  final AppLocalizations l10n;
  final bool isDark;
  final Color bg;

  const _InsightsBody({
    required this.cycles,
    required this.l10n,
    required this.isDark,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    // Summary stats
    final totalCycles = cycles.cycles.length;
    final avgCycle = cycles.cycleLength;
    final avgPeriod = cycles.periodDays;
    final isRegular = _isRegular(cycles.cycles);

    // Last cycle
    final last = cycles.cycles.last;
    final nextPeriod =
        CycleCalculator.calculateNextPeriod(last.startDate, cycles.cycleLength);
    final fertileWindow = CycleCalculator.calculateFertileWindow(
        last.startDate, cycles.cycleLength);
    final ovulation = CycleCalculator.calculateOvulationDate(
        last.startDate, cycles.cycleLength);

    // Symptom frequency
    final symptomCounts = <String, int>{};
    for (final c in cycles.cycles) {
      for (final s in c.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final topSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          l10n.insights,
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: AppFonts.titleL),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // ── Summary Cards ─────────────────────────────────────────
          Row(
            children: [
              _MiniStat(
                  label: 'Cycles Logged',
                  value: '$totalCycles',
                  icon: Icons.loop_rounded,
                  cardBg: cardBg,
                  isDark: isDark),
              const SizedBox(width: AppSizes.spacingS),
              _MiniStat(
                  label: 'Avg Cycle',
                  value: '$avgCycle d',
                  icon: Icons.calendar_month_rounded,
                  cardBg: cardBg,
                  isDark: isDark),
              const SizedBox(width: AppSizes.spacingS),
              _MiniStat(
                  label: 'Avg Period',
                  value: '$avgPeriod d',
                  icon: Icons.water_drop_rounded,
                  cardBg: cardBg,
                  isDark: isDark),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Regularity Badge ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isRegular ? AppColors.success : AppColors.warning)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRegular
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: isRegular ? AppColors.success : AppColors.warning,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRegular ? l10n.regularCycle : l10n.irregularCycle,
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.titleM,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        isRegular
                            ? 'Your cycles are consistent.'
                            : 'Your cycle lengths vary more than 7 days.',
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyS,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Cycle Length Bar Chart ─────────────────────────────────
          if (cycles.cycles.length >= 2) ...[
            _ChartCard(
              title: 'Cycle Lengths (days)',
              cardBg: cardBg,
              textPrimary: textPrimary,
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (cycles.cycles
                                .map((c) => c.duration.toDouble())
                                .reduce((a, b) => a > b ? a : b) +
                            5)
                        .toDouble(),
                    barGroups: cycles.cycles
                        .asMap()
                        .entries
                        .map(
                          (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.duration.toDouble(),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE91E8C),
                                    Color(0xFFCE93D8)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) => Text(
                            'C${(value + 1).toInt()}',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],

          // ── Symptoms Pie Chart ─────────────────────────────────────
          if (topSymptoms.isNotEmpty) ...[
            _ChartCard(
              title: 'Symptoms Distribution',
              cardBg: cardBg,
              textPrimary: textPrimary,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(topSymptoms),
                          sectionsSpace: 2,
                          centerSpaceRadius: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topSymptoms
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _piColors[e.key % _piColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  e.value.key,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10, color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],

          // ── Fertile Window Card ────────────────────────────────────
          _FertileCard(
            nextPeriod: nextPeriod,
            ovulation: ovulation,
            fertileStart: fertileWindow['start']!,
            fertileEnd: fertileWindow['end']!,
            cardBg: cardBg,
            textPrimary: textPrimary,
            l10n: l10n,
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Health Tips ───────────────────────────────────────────
          _HealthTipsCard(
            topSymptoms: topSymptoms.map((e) => e.key).toList(),
            cardBg: cardBg,
            textPrimary: textPrimary,
            isDark: isDark,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  bool _isRegular(List<CycleData> cycles) {
    if (cycles.length < 2) return true;
    final lengths = cycles.map((c) => c.duration).toList();
    final min = lengths.reduce((a, b) => a < b ? a : b);
    final max = lengths.reduce((a, b) => a > b ? a : b);
    return (max - min) <= 7;
  }

  static const _piColors = [
    Color(0xFFE91E8C),
    Color(0xFFCE93D8),
    Color(0xFFF48FB1),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
  ];

  List<PieChartSectionData> _buildPieSections(
      List<MapEntry<String, int>> data) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value).toDouble();
    return data.take(5).toList().asMap().entries.map((e) {
      final pct = e.value.value / total;
      return PieChartSectionData(
        color: _piColors[e.key % _piColors.length],
        value: e.value.value.toDouble(),
        title: '${(pct * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: GoogleFonts.poppins(
            fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color cardBg;
  final bool isDark;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: AppFonts.titleM,
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
                  fontSize: 9, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color cardBg;
  final Color textPrimary;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.cardBg,
    required this.textPrimary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: AppFonts.titleM,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          child,
        ],
      ),
    );
  }
}

class _FertileCard extends StatelessWidget {
  final DateTime nextPeriod;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final Color cardBg;
  final Color textPrimary;
  final AppLocalizations l10n;

  const _FertileCard({
    required this.nextPeriod,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
    required this.cardBg,
    required this.textPrimary,
    required this.l10n,
  });

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.3),
            AppColors.secondary.withOpacity(0.2)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.fertileWindow,
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.titleM,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          _InfoRow(
              icon: Icons.star_rounded,
              color: AppColors.accent,
              label: l10n.ovulation,
              value: _fmt(ovulation),
              textPrimary: textPrimary),
          _InfoRow(
              icon: Icons.favorite_border_rounded,
              color: AppColors.secondary,
              label: l10n.fertileWindow,
              value: '${_fmt(fertileStart)} – ${_fmt(fertileEnd)}',
              textPrimary: textPrimary),
          _InfoRow(
              icon: Icons.water_drop_rounded,
              color: AppColors.primary,
              label: l10n.nextPeriod,
              value: _fmt(nextPeriod),
              textPrimary: textPrimary),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color textPrimary;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: AppFonts.bodyS, color: textPrimary),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: AppFonts.bodyS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Health Tips Card ────────────────────────────────────────────────────────

class _HealthTipsCard extends StatefulWidget {
  final List<String> topSymptoms;
  final Color cardBg;
  final Color textPrimary;
  final bool isDark;

  const _HealthTipsCard({
    required this.topSymptoms,
    required this.cardBg,
    required this.textPrimary,
    required this.isDark,
  });

  @override
  State<_HealthTipsCard> createState() => _HealthTipsCardState();
}

class _HealthTipsCardState extends State<_HealthTipsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tips = HealthTips.getTipsForSymptoms(widget.topSymptoms);
    final visibleTips = _expanded ? tips : tips.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Tips for You',
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.titleM,
                        fontWeight: FontWeight.w700,
                        color: widget.textPrimary,
                      ),
                    ),
                    Text(
                      widget.topSymptoms.isEmpty
                          ? 'General wellness'
                          : 'Based on your symptoms',
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // Tips list
          ...visibleTips.map((tip) => _TipTile(
                tip: tip,
                isDark: widget.isDark,
                textPrimary: widget.textPrimary,
              )),

          // Show more / less toggle
          if (tips.length > 2)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.spacingS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Show ${tips.length - 2} more tips',
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final HealthTip tip;
  final bool isDark;
  final Color textPrimary;

  const _TipTile({
    required this.tip,
    required this.isDark,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip.icon, size: 18, color: tip.color),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyM,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tip.color.withOpacity(0.12),
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

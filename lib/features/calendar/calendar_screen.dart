import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/cycle_calculator.dart';
import '../../../core/utils/ethiopian_calendar.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/cycle_provider.dart';
import '../../../providers/language_provider.dart';
import '../logging/logging_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _etMonthStart;

  @override
  void initState() {
    super.initState();
    _etMonthStart = _computeEtMonthStart(DateTime.now());
  }

  DateTime _computeEtMonthStart(DateTime gregorian) {
    final et = EthiopianCalendar.toEthiopian(gregorian);
    return DateTime(gregorian.year, gregorian.month, gregorian.day)
        .subtract(Duration(days: et.day - 1));
  }

  void _prevEtMonth() {
    setState(() {
      final dayBefore = _etMonthStart.subtract(const Duration(days: 1));
      _etMonthStart = _computeEtMonthStart(dayBefore);
      _focusedDay = _etMonthStart;
    });
  }

  void _nextEtMonth() {
    setState(() {
      final et = EthiopianCalendar.toEthiopian(_etMonthStart);
      final daysInMonth = et.month < 13 ? 30 : ((et.year % 4 == 3) ? 6 : 5);
      _etMonthStart = _etMonthStart.add(Duration(days: daysInMonth));
      _focusedDay = _etMonthStart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycles = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic =
        context.watch<LanguageProvider>().currentLanguage == 'am';
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          l10n.calendar,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppFonts.titleL,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: Colors.white),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
              _etMonthStart = _computeEtMonthStart(DateTime.now());
            }),
            tooltip: 'Today',
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar Widget
          if (isAmharic)
            _EthiopianCalendarGrid(
              etMonthStart: _etMonthStart,
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day;
                  _focusedDay = day;
                });
                _showDayDetails(context, day, cycles, l10n, isAmharic);
              },
              onPrevMonth: _prevEtMonth,
              onNextMonth: _nextEtMonth,
              getDayType: (day) => _getDayType(day, cycles),
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
            )
          else
            Container(
              color: cardBg,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                  _showDayDetails(context, selected, cycles, l10n, false);
                },
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = focused),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (ctx, day, focusedDay) =>
                      _buildDayCell(ctx, day, cycles, false,
                          isAmharic: false),
                  selectedBuilder: (ctx, day, focusedDay) =>
                      _buildDayCell(ctx, day, cycles, true,
                          isAmharic: false),
                  todayBuilder: (ctx, day, focusedDay) =>
                      _buildDayCell(ctx, day, cycles, false,
                          isToday: true, isAmharic: false),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: AppFonts.titleM,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  formatButtonTextStyle: GoogleFonts.poppins(
                    fontSize: AppFonts.captionL,
                    color: AppColors.primary,
                  ),
                  leftChevronIcon:
                      const Icon(Icons.chevron_left, color: AppColors.primary),
                  rightChevronIcon:
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                      fontSize: AppFonts.captionL,
                      color: AppColors.lightTextSecondary),
                  weekendStyle: GoogleFonts.poppins(
                      fontSize: AppFonts.captionL, color: AppColors.primary),
                ),
              ),
            ),

          // Legend
          Container(
            color: cardBg,
            padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingM, 0, AppSizes.paddingM, AppSizes.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: AppColors.primary, label: l10n.period),
                _LegendItem(color: AppColors.accent, label: l10n.ovulation),
                _LegendItem(
                    color: AppColors.secondary.withOpacity(0.7),
                    label: l10n.fertileWindow),
                _LegendItem(
                    color: AppColors.primary.withOpacity(0.25),
                    label: 'Predicted'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Selected day info or placeholder
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      'Tap a date to see details',
                      style: GoogleFonts.poppins(
                          color: AppColors.lightTextSecondary),
                    ),
                  )
                : _DayDetailPanel(
                    day: _selectedDay!,
                    cycles: cycles,
                    l10n: l10n,
                    isDark: isDark,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoggingScreen()),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext ctx,
    DateTime day,
    CycleProvider cycles,
    bool isSelected, {
    bool isToday = false,
    bool isAmharic = false,
  }) {
    final type = _getDayType(day, cycles);
    Color? bgColor;
    Color textColor = Theme.of(ctx).brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    bool isDashed = false;

    switch (type) {
      case _DayType.period:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case _DayType.ovulation:
        bgColor = AppColors.accent;
        textColor = Colors.white;
        break;
      case _DayType.fertile:
        bgColor = AppColors.secondary.withOpacity(0.6);
        textColor = Colors.white;
        break;
      case _DayType.predicted:
        bgColor = AppColors.primary.withOpacity(0.2);
        isDashed = true;
        break;
      case _DayType.none:
        break;
    }

    if (isSelected && bgColor == null) {
      bgColor = AppColors.primary.withOpacity(0.15);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      decoration: isDashed
          ? BoxDecoration(
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            )
          : BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
      child: Center(
        child: isAmharic
            ? _EthiopianDayLabel(
                day: day,
                textColor:
                    isToday && bgColor == null ? AppColors.primary : textColor,
                bold: isToday || isSelected,
              )
            : Text(
                '${day.day}',
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.captionL,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                  color:
                      isToday && bgColor == null ? AppColors.primary : textColor,
                ),
              ),
      ),
    );
  }

  _DayType _getDayType(DateTime day, CycleProvider cycles) {
    if (cycles.cycles.isEmpty) return _DayType.none;

    // Check all logged cycles for period/ovulation/fertile days
    for (final cycle in cycles.cycles) {
      if (CycleCalculator.isPeriodDay(
          day, cycle.startDate, cycles.periodDays)) {
        return _DayType.period;
      }
      if (CycleCalculator.isOvulationDay(
          day, cycle.startDate, cycles.cycleLength)) {
        return _DayType.ovulation;
      }
      if (CycleCalculator.isFertileDay(
          day, cycle.startDate, cycles.cycleLength)) {
        return _DayType.fertile;
      }
    }

    // Show predicted upcoming period days (up to 3 future cycles)
    final lastCycle = cycles.cycles.last;
    DateTime predictedStart = CycleCalculator.calculateNextPeriod(
        lastCycle.startDate, cycles.cycleLength);
    for (int i = 0; i < 3; i++) {
      if (CycleCalculator.isPeriodDay(day, predictedStart, cycles.periodDays)) {
        return _DayType.predicted;
      }
      predictedStart = predictedStart.add(Duration(days: cycles.cycleLength));
    }

    return _DayType.none;
  }

  void _showDayDetails(
    BuildContext context,
    DateTime day,
    CycleProvider cycles,
    AppLocalizations l10n,
    bool isAmharic,
  ) {
    final type = _getDayType(day, cycles);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAmharic
                    ? EthiopianCalendar.formatDate(day)
                    : _formatDate(day),
                style: GoogleFonts.poppins(
                  fontSize: AppFonts.titleL,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _PhaseBadge(type: type, l10n: l10n),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoggingScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: Text('Log / Edit',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

enum _DayType { period, ovulation, fertile, predicted, none }

class _PhaseBadge extends StatelessWidget {
  final _DayType type;
  final AppLocalizations l10n;

  const _PhaseBadge({required this.type, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (type) {
      case _DayType.period:
        label = l10n.period;
        color = AppColors.primary;
        break;
      case _DayType.ovulation:
        label = l10n.ovulation;
        color = AppColors.accent;
        break;
      case _DayType.fertile:
        label = l10n.fertileWindow;
        color = AppColors.secondary;
        break;
      case _DayType.predicted:
        label = 'Predicted Period';
        color = AppColors.primary.withOpacity(0.5);
        break;
      case _DayType.none:
        label = 'Regular Day';
        color = AppColors.lightTextSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.lightTextSecondary)),
      ],
    );
  }
}

class _DayDetailPanel extends StatelessWidget {
  final DateTime day;
  final CycleProvider cycles;
  final AppLocalizations l10n;
  final bool isDark;

  const _DayDetailPanel({
    required this.day,
    required this.cycles,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Find matching logged cycle
    CycleData? matching;
    for (final c in cycles.cycles) {
      if (!day.isBefore(c.startDate) && !day.isAfter(c.endDate)) {
        matching = c;
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      children: [
        if (matching != null && matching.symptoms.isNotEmpty) ...[
          Text(l10n.symptoms,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: matching.symptoms
                .map((s) => Chip(
                      label: Text(s,
                          style:
                              GoogleFonts.poppins(fontSize: AppFonts.captionL)),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ))
                .toList(),
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('No data logged for this day.',
                  style:
                      GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
            ),
          ),
      ],
    );
  }
}

// ─── Ethiopian Calendar Grid Widget ─────────────────────────────────────────
//
// Replaces TableCalendar when Amharic is active.
// Shows exactly one ET month per page with proper Mon-Sun column layout.

class _EthiopianCalendarGrid extends StatelessWidget {
  final DateTime etMonthStart; // Gregorian date of ET day 1 in the focused month
  final DateTime? selectedDay;
  final void Function(DateTime) onDaySelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final _DayType Function(DateTime) getDayType;
  final bool isDark;
  final Color cardBg;
  final Color textPrimary;

  const _EthiopianCalendarGrid({
    required this.etMonthStart,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.getDayType,
    required this.isDark,
    required this.cardBg,
    required this.textPrimary,
  });

  // Monday-first day-of-week labels (col 0 = Mon … col 6 = Sun)
  static const _dowLabels = [
    'ሰኞ', 'ማክሰ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ', 'እሑድ',
  ];

  int _daysInEtMonth(int year, int month) {
    if (month < 13) return 30;
    // Pagume: 6 days in ET leap year (year % 4 == 3), otherwise 5
    return (year % 4 == 3) ? 6 : 5;
  }

  @override
  Widget build(BuildContext context) {
    final et = EthiopianCalendar.toEthiopian(etMonthStart);
    final daysInMonth = _daysInEtMonth(et.year, et.month);
    // Monday = weekday 1 → col 0, Sunday = weekday 7 → col 6
    final startOffset = etMonthStart.weekday - 1;

    return Container(
      color: cardBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingXS,
              vertical: AppSizes.paddingXS,
            ),
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.chevron_left, color: AppColors.primary),
                  onPressed: onPrevMonth,
                  splashRadius: 20,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${EthiopianCalendar.monthName(et.month)}  ${et.year}',
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.titleM,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                  onPressed: onNextMonth,
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // ── Day-of-week row ─────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.paddingXS),
            child: Row(
              children: List.generate(7, (i) {
                final isWeekend = i >= 5; // Saturday=5, Sunday=6
                return Expanded(
                  child: Center(
                    child: Text(
                      _dowLabels[i],
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.captionL,
                        fontWeight: FontWeight.w600,
                        color: isWeekend
                            ? AppColors.primary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),

          // ── Day grid ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingXS,
              0,
              AppSizes.paddingXS,
              AppSizes.paddingS,
            ),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                // Empty leading cells for the start offset
                ...List.generate(startOffset, (_) => const SizedBox()),
                // One cell per ET day in the month
                ...List.generate(daysInMonth, (i) {
                  final gregorianDay = etMonthStart.add(Duration(days: i));
                  final etDay = i + 1;
                  final type = getDayType(gregorianDay);
                  final isSelected = selectedDay != null &&
                      isSameDay(selectedDay!, gregorianDay);
                  final isToday = isSameDay(gregorianDay, DateTime.now());
                  return _EtDayCell(
                    etDay: etDay,
                    gregorianDay: gregorianDay.day,
                    type: type,
                    isSelected: isSelected,
                    isToday: isToday,
                    isDark: isDark,
                    onTap: () => onDaySelected(gregorianDay),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtDayCell extends StatelessWidget {
  final int etDay;
  final int gregorianDay;
  final _DayType type;
  final bool isSelected;
  final bool isToday;
  final bool isDark;
  final VoidCallback onTap;

  const _EtDayCell({
    required this.etDay,
    required this.gregorianDay,
    required this.type,
    required this.isSelected,
    required this.isToday,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    bool isDashed = false;

    switch (type) {
      case _DayType.period:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case _DayType.ovulation:
        bgColor = AppColors.accent;
        textColor = Colors.white;
        break;
      case _DayType.fertile:
        bgColor = AppColors.secondary.withOpacity(0.6);
        textColor = Colors.white;
        break;
      case _DayType.predicted:
        bgColor = AppColors.primary.withOpacity(0.2);
        isDashed = true;
        break;
      case _DayType.none:
        break;
    }

    if (isSelected && bgColor == null) {
      bgColor = AppColors.primary.withOpacity(0.15);
    }

    final effectiveColor =
        isToday && bgColor == null ? AppColors.primary : textColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: isDashed
            ? BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              )
            : BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$etDay',
              style: GoogleFonts.poppins(
                fontSize: AppFonts.captionL,
                fontWeight: isToday || isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: effectiveColor,
              ),
            ),
            Text(
              '$gregorianDay',
              style: TextStyle(
                fontSize: 8,
                color: effectiveColor.withOpacity(0.55),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

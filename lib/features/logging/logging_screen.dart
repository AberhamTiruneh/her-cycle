import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/ethiopian_calendar.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/cycle_provider.dart';
import '../../../providers/language_provider.dart';

class LoggingScreen extends StatefulWidget {
  final CycleData? existing;
  const LoggingScreen({Key? key, this.existing}) : super(key: key);

  @override
  State<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends State<LoggingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _flowIntensity = 'medium';
  final Set<String> _selectedSymptoms = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  final List<String> _symptoms = [
    'Cramps',
    'Headache',
    'Mood Swings',
    'Bloating',
    'Fatigue',
    'Nausea',
    'Back Pain',
    'Breast Tenderness',
    'Spotting',
    'Acne',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _startDate = e.startDate;
      _endDate = e.endDate;
      _flowIntensity = e.flowIntensity ?? 'medium';
      _selectedSymptoms.addAll(e.symptoms);
      _notesController.text = e.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final isAmharic =
        context.read<LanguageProvider>().currentLanguage == 'am';
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final first = isStart ? DateTime(2020) : (_startDate ?? DateTime(2020));
    final last = isStart
        ? (_endDate ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 365));

    if (isAmharic) {
      final picked = await showDialog<DateTime>(
        context: context,
        builder: (ctx) => _EthiopianDatePickerDialog(
          initialDate: initial,
          firstDate: first,
          lastDate: last,
        ),
      );
      if (picked != null && mounted) {
        setState(() {
          if (isStart) {
            _startDate = picked;
            if (_endDate != null && _endDate!.isBefore(picked)) {
              _endDate = null;
            }
          } else {
            _endDate = picked;
          }
        });
      }
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.lightTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please select a start date.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final provider = context.read<CycleProvider>();
      final end = _endDate ?? _startDate!.add(const Duration(days: 4));
      final duration = end.difference(_startDate!).inDays + 1;

      final cycleData = CycleData(
        id: widget.existing?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: _startDate!,
        endDate: end,
        duration: duration,
        symptoms: _selectedSymptoms.toList(),
        notes: _notesController.text.trim(),
        flowIntensity: _flowIntensity,
      );
      await provider.saveCycle(cycleData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic =
        context.watch<LanguageProvider>().currentLanguage == 'am';
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          l10n.logPeriod,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppFonts.titleL,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date Section ──────────────────────────────────────────
            _SectionCard(
              cardBg: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.date_range_rounded,
                      label: 'Period Dates',
                      textColor: textPrimary),
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePicker(
                          label: l10n.startDate,
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                          isDark: isDark,
                          isAmharic: isAmharic,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: _DatePicker(
                          label: l10n.endDate,
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                          isDark: isDark,
                          isAmharic: isAmharic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // ── Flow Intensity ────────────────────────────────────────
            _SectionCard(
              cardBg: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.water_drop_rounded,
                      label: l10n.flowIntensity,
                      textColor: textPrimary),
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    children: [
                      _FlowChip(
                        label: l10n.light,
                        value: 'light',
                        selected: _flowIntensity == 'light',
                        color: AppColors.secondary.withOpacity(0.7),
                        onTap: () => setState(() => _flowIntensity = 'light'),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      _FlowChip(
                        label: l10n.medium,
                        value: 'medium',
                        selected: _flowIntensity == 'medium',
                        color: AppColors.primary,
                        onTap: () => setState(() => _flowIntensity = 'medium'),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      _FlowChip(
                        label: l10n.heavy,
                        value: 'heavy',
                        selected: _flowIntensity == 'heavy',
                        color: const Color(0xFFB71C1C),
                        onTap: () => setState(() => _flowIntensity = 'heavy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // ── Symptoms ──────────────────────────────────────────────
            _SectionCard(
              cardBg: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.mood_rounded,
                      label: l10n.symptoms,
                      textColor: textPrimary),
                  const SizedBox(height: AppSizes.spacingM),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _symptoms.map((s) {
                      final selected = _selectedSymptoms.contains(s);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedSymptoms.remove(s);
                          } else {
                            _selectedSymptoms.add(s);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusCircle),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            s,
                            style: GoogleFonts.poppins(
                              fontSize: AppFonts.captionL,
                              fontWeight: FontWeight.w500,
                              color:
                                  selected ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // ── Notes ─────────────────────────────────────────────────
            _SectionCard(
              cardBg: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      icon: Icons.notes_rounded,
                      label: 'Notes',
                      textColor: textPrimary),
                  const SizedBox(height: AppSizes.spacingM),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today?',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyM, color: textSec),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      filled: true,
                      fillColor: bg,
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyM, color: textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // ── Save Button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightL,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          l10n.save,
                          style: GoogleFonts.poppins(
                            fontSize: AppFonts.titleM,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Color cardBg;
  final Widget child;
  const _SectionCard({required this.cardBg, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;
  const _SectionHeader(
      {required this.icon, required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconS, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppFonts.titleM,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isDark;
  final bool isAmharic;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.onTap,
    required this.isDark,
    this.isAmharic = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: date != null ? AppColors.primary : AppColors.divider,
            width: date != null ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: date != null ? AppColors.primary : textSec,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: date != null ? AppColors.primary : textSec,
                ),
                const SizedBox(width: 4),
                Text(
                  date != null
                      ? (isAmharic
                          ? EthiopianCalendar.formatDateShort(date!)
                          : '${date!.day}/${date!.month}/${date!.year}')
                      : 'Select',
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyS,
                    fontWeight: FontWeight.w600,
                    color: date != null ? textPrimary : textSec,
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

class _FlowChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FlowChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: selected ? color : color.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: AppFonts.bodyS,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ethiopian Date Picker Dialog ────────────────────────────────────────────
/// A full-month grid picker that shows Ethiopian calendar dates.
/// The user navigates ET months; tapping a day returns the Gregorian DateTime.
class _EthiopianDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _EthiopianDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState
    extends State<_EthiopianDatePickerDialog> {
  late DateTime _focusedGregorian; // Gregorian 1st of the focused ET month
  DateTime? _selected;

  // ET month names
  static const _months = [
    '', 'መስከረም', 'ጥቅምት', 'ህዳር', 'ታህሳስ', 'ጥር',
    'የካቲት', 'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ',
  ];
  static const _dow = ['ሰ', 'ማ', 'ረ', 'ሐ', 'ዓ', 'ቅ', 'እ'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _focusedGregorian = DateTime(
        widget.initialDate.year, widget.initialDate.month, 1);
  }

  EthiopianDate get _focusedET =>
      EthiopianCalendar.toEthiopian(_focusedGregorian);

  /// Gregorian DateTime for day [etDay] in the current focused ET month/year.
  DateTime _gregorianForEtDay(int etDay) {
    // Brute-force: walk from focused gregorian month ±2 months to find match
    final etYear = _focusedET.year;
    final etMonth = _focusedET.month;
    // Each ET month starts somewhere in a Gregorian month. Search ±35 days.
    final base = _focusedGregorian.subtract(const Duration(days: 5));
    for (int i = 0; i < 40; i++) {
      final d = base.add(Duration(days: i));
      final et = EthiopianCalendar.toEthiopian(d);
      if (et.year == etYear && et.month == etMonth && et.day == etDay) {
        return d;
      }
    }
    return _focusedGregorian; // fallback
  }

  int get _daysInFocusedMonth {
    // ET months 1–12 = 30 days; month 13 (Pagume) = 5 or 6
    if (_focusedET.month == 13) {
      // Pagume: 6 days in ET leap year (Gregorian year before ET leap year)
      return (_focusedET.year % 4 == 3) ? 6 : 5;
    }
    return 30;
  }

  void _prevMonth() {
    setState(() {
      // Go back ~30 days and land in the previous ET month
      _focusedGregorian = _focusedGregorian.subtract(const Duration(days: 30));
      // Ensure we're on the 1st of that ET month
      final et = EthiopianCalendar.toEthiopian(_focusedGregorian);
      _focusedGregorian =
          _gregorianForEtDay(1).subtract(Duration(days: et.day - 1));
      _focusedGregorian = _gregorianForEtDay(1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedGregorian = _focusedGregorian.add(const Duration(days: 35));
      _focusedGregorian = _gregorianForEtDay(1);
    });
  }

  bool _isSelected(DateTime greg) =>
      _selected != null &&
      greg.year == _selected!.year &&
      greg.month == _selected!.month &&
      greg.day == _selected!.day;

  bool _isDisabled(DateTime greg) =>
      greg.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month,
          widget.firstDate.day)) ||
      greg.isAfter(DateTime(
          widget.lastDate.year, widget.lastDate.month, widget.lastDate.day));

  @override
  Widget build(BuildContext context) {
    final et = _focusedET;
    final days = _daysInFocusedMonth;

    // weekday of ET day 1 (1=Mon … 7=Sun)
    final firstDayGreg = _gregorianForEtDay(1);
    final startWeekday = firstDayGreg.weekday; // 1=Mon, 7=Sun
    final leadingBlanks = startWeekday - 1; // blanks before day 1

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_months[et.month]}  ${et.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: AppColors.primary),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Day-of-week row
            Row(
              children: _dow
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // Day grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: leadingBlanks + days,
              itemBuilder: (_, i) {
                if (i < leadingBlanks) return const SizedBox.shrink();
                final etDay = i - leadingBlanks + 1;
                final greg = _gregorianForEtDay(etDay);
                final disabled = _isDisabled(greg);
                final selected = _isSelected(greg);
                return GestureDetector(
                  onTap: disabled
                      ? null
                      : () => setState(() => _selected = greg),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$etDay',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: disabled
                              ? Colors.grey[400]
                              : selected
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ሰርዝ',
                      style: GoogleFonts.poppins(color: AppColors.primary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.pop(context, _selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('እሺ',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/cycle_provider.dart';

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
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final first = isStart ? DateTime(2020) : (_startDate ?? DateTime(2020));
    final last = isStart
        ? (_endDate ?? DateTime.now().add(const Duration(days: 365)))
        : DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.lightTextPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
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
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: _DatePicker(
                          label: l10n.endDate,
                          date: _endDate,
                          onTap: () => _pickDate(isStart: false),
                          isDark: isDark,
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

  const _DatePicker({
    required this.label,
    required this.date,
    required this.onTap,
    required this.isDark,
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
                      ? '${date!.day}/${date!.month}/${date!.year}'
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

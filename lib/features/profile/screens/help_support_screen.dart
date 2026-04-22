import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _openFaqIndex;

  @override
  Widget build(BuildContext context) {
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
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppFonts.titleL,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // ── Contact Support ───────────────────────────────────────
          _SectionLabel(label: 'Contact Us', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _NavTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@hercycle.app',
                isDark: isDark,
                onTap: () => _showContactDialog(context, isDark: isDark),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Send Feedback',
                subtitle: 'Tell us what you love or what we can improve.',
                isDark: isDark,
                onTap: () => _showFeedbackSheet(context, isDark: isDark),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                subtitle: 'Found something broken? Let us know.',
                isDark: isDark,
                onTap: () => _showBugReportSheet(context, isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Getting Started ───────────────────────────────────────
          _SectionLabel(label: 'Getting Started', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _NavTile(
                icon: Icons.play_circle_outline_rounded,
                title: 'How to Log Your Cycle',
                subtitle: 'Learn how to track periods and symptoms.',
                isDark: isDark,
                onTap: () => _showGuideSheet(
                  context,
                  isDark: isDark,
                  title: 'How to Log Your Cycle',
                  steps: const [
                    _Step(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Tap the + button',
                      body:
                          'On the Home screen, tap the pink + button at the bottom right to open the cycle logging form.',
                    ),
                    _Step(
                      icon: Icons.calendar_today_rounded,
                      title: 'Set your dates',
                      body:
                          'Choose your period start date and end date. The app will calculate the duration automatically.',
                    ),
                    _Step(
                      icon: Icons.water_drop_rounded,
                      title: 'Select flow intensity',
                      body:
                          'Indicate whether your flow was light, medium, or heavy to improve future predictions.',
                    ),
                    _Step(
                      icon: Icons.mood_rounded,
                      title: 'Add symptoms',
                      body:
                          'Tap any symptoms you experienced — cramps, fatigue, mood swings, and more.',
                    ),
                    _Step(
                      icon: Icons.save_rounded,
                      title: 'Save your log',
                      body:
                          'Tap Save. Your data is stored and used to generate predictions and health tips.',
                    ),
                  ],
                ),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.insights_rounded,
                title: 'Understanding Your Insights',
                subtitle:
                    'Cycle charts, predictions, and health tips explained.',
                isDark: isDark,
                onTap: () => _showGuideSheet(
                  context,
                  isDark: isDark,
                  title: 'Understanding Insights',
                  steps: const [
                    _Step(
                      icon: Icons.bar_chart_rounded,
                      title: 'Cycle length chart',
                      body:
                          'The bar chart shows your cycle lengths over time. Log at least 2 cycles to see it.',
                    ),
                    _Step(
                      icon: Icons.pie_chart_rounded,
                      title: 'Symptom distribution',
                      body:
                          'The pie chart shows which symptoms you logged most frequently across all cycles.',
                    ),
                    _Step(
                      icon: Icons.favorite_rounded,
                      title: 'Fertile window',
                      body:
                          'Based on your average cycle length, we estimate your ovulation and fertile window dates.',
                    ),
                    _Step(
                      icon: Icons.health_and_safety_rounded,
                      title: 'Health tips',
                      body:
                          'Tips are personalised based on the symptoms you log most often. Tap "Show more" to see all.',
                    ),
                  ],
                ),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.notifications_outlined,
                title: 'Setting Up Reminders',
                subtitle: 'Period and medication reminders.',
                isDark: isDark,
                onTap: () => _showGuideSheet(
                  context,
                  isDark: isDark,
                  title: 'Setting Up Reminders',
                  steps: const [
                    _Step(
                      icon: Icons.person_rounded,
                      title: 'Go to Profile',
                      body: 'Tap the Profile tab in the bottom navigation bar.',
                    ),
                    _Step(
                      icon: Icons.notifications_active_rounded,
                      title: 'Enable Notifications',
                      body:
                          'Toggle on "Notifications" under the Preferences section.',
                    ),
                    _Step(
                      icon: Icons.phone_android_rounded,
                      title: 'Allow system permission',
                      body:
                          'When prompted, allow HerCycle to send notifications in your device settings.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── FAQ ────────────────────────────────────────────────────
          _SectionLabel(label: 'Frequently Asked Questions', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: _faqs.asMap().entries.map((entry) {
              final i = entry.key;
              final faq = entry.value;
              final isOpen = _openFaqIndex == i;
              return Column(
                children: [
                  InkWell(
                    onTap: () =>
                        setState(() => _openFaqIndex = isOpen ? null : i),
                    borderRadius: i == 0
                        ? const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.radiusXL))
                        : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingL,
                          vertical: AppSizes.paddingM),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: GoogleFonts.poppins(
                                fontSize: AppFonts.bodyM,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.paddingL, 0,
                          AppSizes.paddingL, AppSizes.paddingM),
                      child: Text(
                        faq.answer,
                        style: GoogleFonts.poppins(
                          fontSize: AppFonts.bodyS,
                          color: textSec,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (i < _faqs.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── App Info ──────────────────────────────────────────────
          _SectionLabel(label: 'App Info', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 20, color: AppColors.primary),
                ),
                title: Text('Version',
                    style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyM,
                        fontWeight: FontWeight.w500,
                        color: textPrimary)),
                trailing: Text('1.0.0',
                    style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyS, color: textSec)),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Sheets & Dialogs ─────────────────────────────────────────────────────

  void _showContactDialog(BuildContext context, {required bool isDark}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        title: Text('Contact Support',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For help, email us at:',
                style: GoogleFonts.poppins(fontSize: AppFonts.bodyM)),
            const SizedBox(height: 8),
            Text(
              'support@hercycle.app',
              style: GoogleFonts.poppins(
                  fontSize: AppFonts.bodyM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('We typically respond within 24–48 hours.',
                style: GoogleFonts.poppins(
                    fontSize: AppFonts.bodyS,
                    color: AppColors.lightTextSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style:
                    GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context, {required bool isDark}) {
    _showTextInputSheet(
      context,
      isDark: isDark,
      title: 'Send Feedback',
      hint: 'What do you love about HerCycle, or what could be better?',
      submitLabel: 'Send Feedback',
      onSubmit: (text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showBugReportSheet(BuildContext context, {required bool isDark}) {
    _showTextInputSheet(
      context,
      isDark: isDark,
      title: 'Report a Bug',
      hint: 'Describe what happened and the steps to reproduce the issue.',
      submitLabel: 'Submit Report',
      onSubmit: (text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bug report submitted. Thank you!',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showTextInputSheet(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String hint,
    required String submitLabel,
    required void Function(String) onSubmit,
  }) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXXL)),
          ),
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: AppFonts.titleL,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)),
              const SizedBox(height: AppSizes.spacingM),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.lightTextSecondary,
                      fontSize: AppFonts.bodyS),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
                  ),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      onSubmit(controller.text.trim());
                    }
                  },
                  child: Text(submitLabel,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: AppFonts.bodyM)),
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuideSheet(
    BuildContext context, {
    required bool isDark,
    required String title,
    required List<_Step> steps,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXXL)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: AppFonts.titleL,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  children: steps.asMap().entries.map((e) {
                    final step = e.value;
                    final num = e.key + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$num',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontSize: AppFonts.bodyM,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  step.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: AppFonts.bodyM,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  step.body,
                                  style: GoogleFonts.poppins(
                                    fontSize: AppFonts.bodyS,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

class _Step {
  final IconData icon;
  final String title;
  final String body;
  const _Step({required this.icon, required this.title, required this.body});
}

const List<_Faq> _faqs = [
  _Faq(
    'How accurate are the cycle predictions?',
    'Predictions improve as you log more cycles. After 3+ cycles the app calculates your personal average. Predictions are estimates and should not be used as contraception.',
  ),
  _Faq(
    'Can I use the app without creating an account?',
    'Yes. Tap "Continue as Guest" on the login screen. Guest data is stored locally on your device. Create an account anytime from the Profile tab to back up your data.',
  ),
  _Faq(
    'Why is my period prediction off?',
    'Cycle lengths naturally vary. Log each period as it happens to keep predictions up to date. Stress, illness, and lifestyle changes can also affect your cycle.',
  ),
  _Faq(
    'How do I edit a logged cycle?',
    'Go to the Calendar tab, tap on any logged period date, and select Edit to update the dates, symptoms, or flow intensity.',
  ),
  _Faq(
    'Is my health data private?',
    'Yes. Your data is stored securely and is never sold to third parties. See Privacy & Security in Settings for full details.',
  ),
  _Faq(
    'How do I delete my account?',
    'Go to Profile > Danger Zone > Delete Account. You will be asked to type DELETE to confirm. This permanently removes all your data.',
  ),
  _Faq(
    'The app is not sending notifications. What should I do?',
    'Make sure Notifications are enabled in Profile > Preferences, and that HerCycle has notification permission in your device Settings > Apps > HerCycle > Notifications.',
  ),
];

// ─── Shared Helper Widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSec;
  const _SectionLabel({required this.label, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSizes.paddingS, bottom: AppSizes.paddingS),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textSec,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Color cardBg;
  final List<Widget> children;
  const _Card({required this.cardBg, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w500,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyS,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          size: 20),
    );
  }
}

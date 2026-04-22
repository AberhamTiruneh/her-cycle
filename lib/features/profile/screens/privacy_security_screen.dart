import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/auth_provider.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;

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
          'Privacy & Security',
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
          // ── Data & Privacy ────────────────────────────────────────
          _SectionLabel(label: 'Data & Privacy', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _SwitchTile(
                icon: Icons.analytics_outlined,
                title: 'Usage Analytics',
                subtitle:
                    'Help improve the app by sharing anonymous usage data.',
                value: _analyticsEnabled,
                isDark: isDark,
                onChanged: (v) => setState(() => _analyticsEnabled = v),
              ),
              _Divider(),
              _SwitchTile(
                icon: Icons.bug_report_outlined,
                title: 'Crash Reports',
                subtitle:
                    'Automatically send crash reports to help fix issues.',
                value: _crashReportsEnabled,
                isDark: isDark,
                onChanged: (v) => setState(() => _crashReportsEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Account Security ───────────────────────────────────────
          _SectionLabel(label: 'Account Security', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _NavTile(
                icon: Icons.key_rounded,
                title: 'Change Password',
                subtitle: 'Update your account password.',
                isDark: isDark,
                onTap: () =>
                    Navigator.of(context).pushNamed('/forgot-password'),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.devices_rounded,
                title: 'Active Sessions',
                subtitle: 'View and manage where you are signed in.',
                isDark: isDark,
                onTap: () => _showActiveSessionsDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Your Data ─────────────────────────────────────────────
          _SectionLabel(label: 'Your Data', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _NavTile(
                icon: Icons.download_rounded,
                title: 'Export My Data',
                subtitle: 'Download a copy of all your cycle and health data.',
                isDark: isDark,
                onTap: () => _showExportDialog(context),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete All Data',
                subtitle: 'Permanently remove all your stored health data.',
                isDark: isDark,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showDeleteDataDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),

          // ── Privacy Policy ────────────────────────────────────────
          _SectionLabel(label: 'Legal', textSec: textSec),
          _Card(
            cardBg: cardBg,
            children: [
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read how we handle your data.',
                isDark: isDark,
                onTap: () => _showPolicySheet(
                  context,
                  title: 'Privacy Policy',
                  isDark: isDark,
                  content: _privacyPolicyText,
                ),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Review the terms governing your use of this app.',
                isDark: isDark,
                onTap: () => _showPolicySheet(
                  context,
                  title: 'Terms of Service',
                  isDark: isDark,
                  content: _termsText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showActiveSessionsDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        title: Text('Active Sessions',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.phone_android_rounded, color: AppColors.primary),
              title: Text('This device',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Current session',
                  style: GoogleFonts.poppins(fontSize: AppFonts.bodyS)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                      fontSize: AppFonts.bodyS,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style:
                    GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            child: Text('Sign Out All',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        title: Text('Export Data',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Your cycle and health data will be prepared as a JSON file. This feature requires a connected account.',
          style: GoogleFonts.poppins(fontSize: AppFonts.bodyM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data export coming soon.',
                      style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Export',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        title: Text('Delete All Data',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.error)),
        content: Text(
          'This will permanently delete all your cycle logs, symptoms, and health data. This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: AppFonts.bodyM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.deleteAccount();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            child: Text('Delete Everything',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPolicySheet(
    BuildContext context, {
    required String title,
    required String content,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
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
                  children: [
                    Text(
                      content,
                      style: GoogleFonts.poppins(
                        fontSize: AppFonts.bodyM,
                        height: 1.6,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
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

  static const String _privacyPolicyText = '''
Last updated: April 2026

HerCycle is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your personal health information.

1. Data We Collect
We collect information you provide directly: your name, email address, cycle dates, symptoms, flow intensity, moods, and notes you enter.

2. How We Use Your Data
Your data is used solely to provide cycle tracking, predictions, and health insights within the app. We do not sell your personal data to third parties.

3. Data Storage
Your data is stored securely using Firebase (Google Cloud). Data is encrypted in transit and at rest.

4. Anonymous Usage Analytics
With your permission, we collect anonymous usage statistics to improve the app. This data cannot be linked back to you.

5. Your Rights
You may export or delete your data at any time from Settings > Privacy & Security. Account deletion permanently removes all associated data.

6. Contact
For privacy questions, contact us at support@hercycle.app.
''';

  static const String _termsText = '''
Last updated: April 2026

By using HerCycle, you agree to these Terms of Service.

1. Intended Use
HerCycle is a personal health tracking tool. It is not a medical device and does not provide medical advice. Always consult a healthcare professional for medical concerns.

2. Account Responsibility
You are responsible for maintaining the security of your account credentials and for all activity under your account.

3. Health Data
You own your health data. We process it only to provide the services described in our Privacy Policy.

4. Accuracy
Cycle predictions are estimates based on your logged data. They are not guaranteed to be accurate and should not be used as contraception.

5. Termination
We reserve the right to suspend accounts that violate these terms.

6. Changes
We may update these terms and will notify you of significant changes through the app.

7. Contact
For questions, contact support@hercycle.app.
''';
}

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
  final Color? iconColor;
  final Color? titleColor;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child:
            Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w500,
          color: titleColor ??
              (isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary),
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

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: 4),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

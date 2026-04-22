import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/theme_provider.dart';
import 'help_support_screen.dart';
import 'language_selector_screen.dart';
import 'privacy_security_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final user = auth.currentUser;
    final initials = (user?.name.isNotEmpty == true)
        ? user!.name
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
        : '?';

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE91E8C), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppSizes.radiusXXL)),
              ),
              padding: EdgeInsets.fromLTRB(
                  AppSizes.paddingXL,
                  MediaQuery.of(context).padding.top + AppSizes.paddingXL,
                  AppSizes.paddingXL,
                  AppSizes.paddingXXL),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          initials.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: AppFonts.headingM,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: AppFonts.titleL,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: AppFonts.bodyM,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spacingS),

                  // ── Guest Banner ─────────────────────────────────
                  if (auth.isAnonymous ||
                      auth.currentUser?.uid == 'guest_local') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E8C), Color(0xFFCE93D8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Guest Mode',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFonts.bodyM,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create an account to save your cycle data and access all features.',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: AppFonts.bodyS,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await auth.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (_) => false,
                                    arguments: 1, // open Sign Up tab
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusL),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppFonts.bodyM,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                  ],

                  // ── Preferences Section ──────────────────────────
                  _SectionLabel(label: 'Preferences', textSec: textSec),
                  _SettingsCard(
                    cardBg: cardBg,
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: l10n.language,
                        trailing: Text(
                          LanguageProvider.supportedLanguages
                              .firstWhere((l) => l.code == lang.currentLanguage,
                                  orElse: () =>
                                      LanguageProvider.supportedLanguages.first)
                              .flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        isDark: isDark,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LanguageSelectorScreen()),
                        ),
                      ),
                      _Divider(),
                      _SettingsSwitchTile(
                        icon: Icons.dark_mode_rounded,
                        label: l10n.darkMode,
                        value: theme.isDarkMode,
                        onChanged: (_) => theme.toggleTheme(),
                        isDark: isDark,
                      ),
                      _Divider(),
                      _SettingsSwitchTile(
                        icon: Icons.notifications_rounded,
                        label: l10n.notifications,
                        value: user?.notificationsEnabled ?? true,
                        onChanged: (val) => auth.toggleNotifications(val),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),

                  // ── Account Section ────────────────────────────────
                  _SectionLabel(label: 'Account', textSec: textSec),
                  _SettingsCard(
                    cardBg: cardBg,
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: l10n.privacy,
                        isDark: isDark,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PrivacySecurityScreen()),
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.key_rounded,
                        label: l10n.changePassword,
                        isDark: isDark,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/forgot-password'),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.download_rounded,
                        label: 'Export Data',
                        isDark: isDark,
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: l10n.help,
                        isDark: isDark,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),

                  // ── Danger Zone ────────────────────────────────────
                  _SectionLabel(label: 'Danger Zone', textSec: textSec),
                  _SettingsCard(
                    cardBg: cardBg,
                    children: [
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        label: l10n.logout,
                        iconColor: AppColors.warning,
                        labelColor: AppColors.warning,
                        isDark: isDark,
                        onTap: () => _showLogoutDialog(context, auth, l10n),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.delete_forever_rounded,
                        label: l10n.deleteAccount,
                        iconColor: AppColors.error,
                        labelColor: AppColors.error,
                        isDark: isDark,
                        onTap: () =>
                            _showDeleteAccountDialog(context, auth, l10n),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AuthProvider auth, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style:
                    GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            ),
            child: Text(l10n.logout,
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, AuthProvider auth, AppLocalizations l10n) {
    final controller = TextEditingController();
    bool canDelete = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text('Delete Account',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: AppColors.error)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent. Type DELETE to confirm.',
                style: GoogleFonts.poppins(fontSize: AppFonts.bodyM),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                onChanged: (v) =>
                    setStateDialog(() => canDelete = v == 'DELETE'),
                decoration: InputDecoration(
                  hintText: 'Type DELETE',
                  hintStyle:
                      GoogleFonts.poppins(color: AppColors.lightTextSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                  style:
                      GoogleFonts.poppins(color: AppColors.lightTextSecondary)),
            ),
            ElevatedButton(
              onPressed: canDelete
                  ? () async {
                      Navigator.pop(ctx);
                      await auth.deleteAccount();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/login', (_) => false);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL)),
              ),
              child: Text('Delete',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

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

class _SettingsCard extends StatelessWidget {
  final Color cardBg;
  final List<Widget> children;
  const _SettingsCard({required this.cardBg, required this.children});

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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.labelColor,
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
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w500,
          color: labelColor ??
              (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 20)
              : null),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        label,
        style: GoogleFonts.poppins(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w500,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1,
        indent: AppSizes.paddingL + 44,
        endIndent: AppSizes.paddingM);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/themes/light_theme.dart';
import 'core/themes/dark_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cycle_provider.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/logging/logging_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'generated/l10n/app_localizations.dart';

class HerCycleApp extends StatelessWidget {
  const HerCycleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageProvider, AuthProvider>(
      builder: (context, themeProvider, languageProvider, authProvider, _) {
        return MaterialApp(
          title: 'HER_CYCLE',
          debugShowCheckedModeBanner: false,
          theme: _applyLanguageFont(
              getLightTheme(), languageProvider.currentLanguage),
          darkTheme: _applyLanguageFont(
              getDarkTheme(), languageProvider.currentLanguage),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Localization Setup
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('am'), // Amharic
            Locale('fr'), // French
            Locale('es'), // Spanish
            Locale('ar'), // Arabic
            Locale('pt'), // Portuguese
            Locale('sw'), // Swahili
            Locale('hi'), // Hindi
            Locale('zh'), // Chinese
          ],
          locale: languageProvider.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode)
                return supported;
            }
            return const Locale('en');
          },

          // Wrap every route in the Auth↔Cycle bridge
          builder: (context, child) =>
              _AuthCycleBridge(child: child ?? const SizedBox.shrink()),

          // Initial Route Logic
          home: const SplashScreen(),

          // Named Routes
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => AuthScreen(
                  initialTabIndex:
                      (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
                ),
            '/signup': (context) => const AuthScreen(initialTabIndex: 1),
            '/onboarding': (context) => const OnboardingScreen(),
            '/calendar': (context) => const CalendarScreen(),
            '/logging': (context) => const LoggingScreen(),
            '/insights': (context) => const InsightsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }

  ThemeData _applyLanguageFont(ThemeData base, String langCode) {
    final TextTheme textTheme;
    switch (langCode) {
      case 'am':
        textTheme = GoogleFonts.notoSansEthiopicTextTheme(base.textTheme);
        break;
      case 'ar':
        textTheme = GoogleFonts.notoSansArabicTextTheme(base.textTheme);
        break;
      case 'hi':
        textTheme = GoogleFonts.notoSansDevanagariTextTheme(base.textTheme);
        break;
      case 'zh':
        textTheme = GoogleFonts.notoSansScTextTheme(base.textTheme);
        break;
      default:
        textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);
    }
    return base.copyWith(textTheme: textTheme);
  }
}

// ─── Auth↔Cycle Bridge ──────────────────────────────────────────────────────

/// Listens to [AuthProvider] changes and loads the correct user's cycle
/// data into [CycleProvider] whenever the signed-in user changes.
class _AuthCycleBridge extends StatefulWidget {
  final Widget child;
  const _AuthCycleBridge({required this.child});

  @override
  State<_AuthCycleBridge> createState() => _AuthCycleBridgeState();
}

class _AuthCycleBridgeState extends State<_AuthCycleBridge> {
  String? _lastUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final newUid = auth.currentUser?.uid;
    if (newUid != _lastUserId) {
      _lastUserId = newUid;
      context.read<CycleProvider>().loadForUser(newUid);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

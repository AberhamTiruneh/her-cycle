import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

export 'app_localizations_en.dart';

abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
    Locale('fr'),
    Locale('es'),
    Locale('ar'),
    Locale('pt'),
    Locale('sw'),
    Locale('hi'),
    Locale('zh'),
  ];

  // ── Core UI ──────────────────────────────────────────────────────────────
  String get appName;
  String get appTagline;
  String get welcome;
  String get continueText;
  String get save;
  String get cancel;
  String get delete;
  String get settings;
  String get back;
  String get done;
  String get loading;
  String get error;
  String get success;
  String get logout;
  String get confirm;
  String get edit;
  String get add;
  String get next;
  String get retry;

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get login;
  String get signup;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get rememberMe;
  String get signInWithGoogle;
  String get deleteAccount;
  String get changePassword;

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingTitle1;
  String get onboardingSubtitle1;
  String get onboardingTitle2;
  String get onboardingSubtitle2;
  String get onboardingTitle3;
  String get onboardingSubtitle3;
  String get getStarted;
  String get trackYourCycle;
  String get getNotified;
  String get understandYourBody;

  // ── Navigation ────────────────────────────────────────────────────────────
  String get home;
  String get calendar;
  String get insights;
  String get profile;
  String get myProfile;

  // ── Period tracking ───────────────────────────────────────────────────────
  String get periodTracker;
  String get startDate;
  String get endDate;
  String get flowIntensity;
  String get light;
  String get medium;
  String get heavy;
  String get logPeriod;
  String get nextPeriod;
  String get predictedDate;
  String get cycleLength;
  String get days;
  String get currentCycle;
  String get cycleStats;
  String get period;
  String get averageCycle;
  String get regularCycle;
  String get irregularCycle;
  String get exportReport;
  String get noDataYet;
  String get startLogging;
  String get daysUntilPeriod;
  String get hello;

  // ── Phases ────────────────────────────────────────────────────────────────
  String get currentPhase;
  String get menstrualPhase;
  String get follicularPhase;
  String get ovulationPhase;
  String get lutealPhase;
  String get fertile;
  String get ovulation;
  String get fertileWindow;
  String get ovulationWindow;

  // ── Symptoms ──────────────────────────────────────────────────────────────
  String get symptoms;
  String get cramps;
  String get headache;
  String get mood;
  String get bloating;
  String get fatigue;
  String get nausea;
  String get logging;
  String get logSymptom;

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notifications;
  String get enableNotifications;
  String get periodReminder;
  String periodReminderMessage(int days);
  String get dailyReminder;

  // ── Insights / Analysis ───────────────────────────────────────────────────
  String get healthInsights;
  String get analysis;
  String get predictionsData;

  // ── News ──────────────────────────────────────────────────────────────────
  String get healthNews;
  String get topHealthStories;

  // ── Settings / Profile ────────────────────────────────────────────────────
  String get language;
  String get selectLanguage;
  String get darkMode;
  String get privacySecurity;
  String get privacy;
  String get aboutUs;
  String get help;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const [
        'en',
        'am',
        'fr',
        'es',
        'ar',
        'pt',
        'sw',
        'hi',
        'zh',
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(_lookup(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  AppLocalizations _lookup(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'am':
        return AppLocalizationsAm();
      case 'fr':
        return AppLocalizationsFr();
      case 'es':
        return AppLocalizationsEs();
      case 'ar':
        return AppLocalizationsAr();
      case 'pt':
        return AppLocalizationsPt();
      case 'sw':
        return AppLocalizationsSw();
      case 'hi':
        return AppLocalizationsHi();
      case 'zh':
        return AppLocalizationsZh();
      default:
        return AppLocalizationsEn();
    }
  }
}

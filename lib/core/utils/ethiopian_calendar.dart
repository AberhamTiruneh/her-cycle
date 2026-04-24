/// Ethiopian (Ge'ez) calendar converter and formatter.
///
/// The Ethiopian calendar has 13 months: 12 months of 30 days each and a
/// 13th month (ጳጉሜ / Pagume) of 5 days (6 in an Ethiopian leap year).
/// The Ethiopian year is currently ~7–8 years behind the Gregorian year.
class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() => '$year-$month-$day';
}

class EthiopianCalendar {
  EthiopianCalendar._();

  // ─── Month names in Amharic ──────────────────────────────────────────────
  static const List<String> _monthNames = [
    '',
    'መስከረም', //  1 Meskerem  (Sep 11/12)
    'ጥቅምት', //  2 Tikimt    (Oct 11/12)
    'ህዳር', //  3 Hidar     (Nov 10/11)
    'ታህሳስ', //  4 Tahsas    (Dec 10/11)
    'ጥር', //  5 Tir       (Jan  9/10)
    'የካቲት', //  6 Yekatit   (Feb  8/9)
    'መጋቢት', //  7 Megabit   (Mar 10/11)
    'ሚያዝያ', //  8 Miyazya   (Apr  9/10)
    'ግንቦት', //  9 Ginbot    (May  9/10)
    'ሰኔ', // 10 Sene      (Jun  8/9)
    'ሐምሌ', // 11 Hamle     (Jul  8/9)
    'ነሐሴ', // 12 Nehase    (Aug  7/8)
    'ጳጉሜ', // 13 Pagume    (Sep  6/7)
  ];

  // ─── Short day names in Amharic (weekday 1=Mon … 7=Sun) ─────────────────
  static const List<String> _dayNamesShort = [
    '',
    'ሰኞ', // 1 Monday
    'ማክሰ', // 2 Tuesday  (shortened from ማክሰኞ)
    'ረቡዕ', // 3 Wednesday
    'ሐሙስ', // 4 Thursday
    'ዓርብ', // 5 Friday
    'ቅዳሜ', // 6 Saturday
    'እሑድ', // 7 Sunday
  ];

  // ─── Converter ───────────────────────────────────────────────────────────

  /// Convert a Gregorian [DateTime] to an [EthiopianDate].
  ///
  /// Algorithm uses the Julian Day Number as an intermediate step.
  /// Verified: April 23, 2026 → 15 Miyazya 2018 ET ✓
  ///           Sep 11, 2025  → 1 Meskerem 2018 ET  ✓
  static EthiopianDate toEthiopian(DateTime gregorian) {
    final int y = gregorian.year;
    final int m = gregorian.month;
    final int d = gregorian.day;

    // Gregorian → Julian Day Number (proleptic Gregorian)
    final int a = (14 - m) ~/ 12;
    final int yy = y + 4800 - a;
    final int mm = m + 12 * a - 3;
    final int jdn = d +
        (153 * mm + 2) ~/ 5 +
        365 * yy +
        yy ~/ 4 -
        yy ~/ 100 +
        yy ~/ 400 -
        32045;

    // JDN → Ethiopian
    const int etEpoch = 1723856; // JDN of 1 Meskerem, 1 AM
    final int diff = jdn - etEpoch;
    final int r = diff % 1461;
    final int n = r % 365 + 365 * (r ~/ 1460);

    final int etYear = 4 * (diff ~/ 1461) + r ~/ 365 - r ~/ 1460;
    final int etMonth = n ~/ 30 + 1;
    final int etDay = n % 30 + 1;

    return EthiopianDate(year: etYear, month: etMonth, day: etDay);
  }

  // ─── Formatting helpers ──────────────────────────────────────────────────

  /// Amharic month name for the given Ethiopian month number (1–13).
  static String monthName(int month) {
    if (month < 1 || month > 13) return '';
    return _monthNames[month];
  }

  /// Amharic short day-of-week name (weekday 1 = Mon … 7 = Sun).
  static String dayNameShort(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return _dayNamesShort[weekday];
  }

  /// Full date string in Amharic, e.g. "ሚያዝያ 15, 2018"
  static String formatDate(DateTime date) {
    final et = toEthiopian(date);
    return '${_monthNames[et.month]} ${et.day}, ${et.year}';
  }

  /// Short date, e.g. "ሚያዝያ 15"
  static String formatDateShort(DateTime date) {
    final et = toEthiopian(date);
    return '${_monthNames[et.month]} ${et.day}';
  }

  /// Header text for the calendar widget showing the focused Gregorian month.
  ///
  /// Because a Gregorian month usually spans two Ethiopian months the header
  /// shows both when they differ: "ሚያዝያ / ግንቦት  2018"
  static String headerText(DateTime focusedDay) {
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    // Last day of focused Gregorian month
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    final etFirst = toEthiopian(firstDay);
    final etLast = toEthiopian(lastDay);

    if (etFirst.month == etLast.month && etFirst.year == etLast.year) {
      return '${_monthNames[etFirst.month]}  ${etFirst.year}';
    } else if (etFirst.year != etLast.year) {
      // September: ET year boundary
      return '${_monthNames[etFirst.month]} / ${_monthNames[etLast.month]}  ${etFirst.year}/${etLast.year}';
    } else {
      return '${_monthNames[etFirst.month]} / ${_monthNames[etLast.month]}  ${etFirst.year}';
    }
  }
}

import 'ethiopian_calendar.dart';

class DateUtils {
  /// Format date to a readable string
  static String formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date to short format (e.g., Jan 15)
  static String formatDateShort(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Get day of week name
  static String getDayName(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Get short day name (e.g., Mon)
  static String getDayNameShort(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  /// Calculate difference between two dates in days
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Get the start of the month
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the end of the month
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Format date using Ethiopian calendar (for Amharic locale).
  /// e.g. "ሚያዝያ 15, 2018"
  static String formatDateEthiopian(DateTime date) {
    return EthiopianCalendar.formatDate(date);
  }

  /// Short Ethiopian date format, e.g. "ሚያዝያ 15"
  static String formatDateShortEthiopian(DateTime date) {
    return EthiopianCalendar.formatDateShort(date);
  }

  /// Locale-aware date format: returns Ethiopian format for Amharic,
  /// Gregorian otherwise.
  static String formatDateLocalized(DateTime date,
      {String languageCode = 'en'}) {
    if (languageCode == 'am') return formatDateEthiopian(date);
    return formatDate(date);
  }
}

class CycleCalculator {
  /// Calculate next period date based on cycle length.
  /// Always returns the next upcoming period (>= today).
  static DateTime calculateNextPeriod(
      DateTime lastPeriodDate, int cycleLength) {
    DateTime next = lastPeriodDate.add(Duration(days: cycleLength));
    final today = DateTime.now();
    // Advance forward until next period is in the future
    while (next.isBefore(DateTime(today.year, today.month, today.day))) {
      next = next.add(Duration(days: cycleLength));
    }
    return next;
  }

  /// Calculate ovulation date (typically 14 days before next period)
  static DateTime calculateOvulationDate(
      DateTime lastPeriodDate, int cycleLength) {
    final nextPeriod = calculateNextPeriod(lastPeriodDate, cycleLength);
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Calculate fertile window (5 days before ovulation + ovulation day)
  static Map<String, DateTime> calculateFertileWindow(
      DateTime lastPeriodDate, int cycleLength) {
    final ovulationDate = calculateOvulationDate(lastPeriodDate, cycleLength);
    return {
      'start': ovulationDate.subtract(const Duration(days: 5)),
      'end': ovulationDate.add(const Duration(days: 1)),
    };
  }

  /// Get the effective start of the current cycle (advances past unlogged cycles).
  static DateTime getCurrentCycleStart(
      DateTime lastPeriodDate, int cycleLength) {
    DateTime start = lastPeriodDate;
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (start.add(Duration(days: cycleLength)).isBefore(today) ||
        start.add(Duration(days: cycleLength)).isAtSameMomentAs(today)) {
      start = start.add(Duration(days: cycleLength));
    }
    return start;
  }

  /// Get current cycle day (1-based, always within cycleLength).
  static int getCurrentCycleDay(DateTime lastPeriodDate,
      [int cycleLength = 28]) {
    final today = DateTime.now();
    final cycleStart = getCurrentCycleStart(lastPeriodDate, cycleLength);
    return today.difference(cycleStart).inDays + 1;
  }

  /// Check if a date is within fertile window
  static bool isFertileDay(
      DateTime date, DateTime lastPeriodDate, int cycleLength) {
    final fertileWindow = calculateFertileWindow(lastPeriodDate, cycleLength);
    return date.isAfter(fertileWindow['start']!) &&
        date.isBefore(fertileWindow['end']!);
  }

  /// Check if a date is ovulation day
  static bool isOvulationDay(
      DateTime date, DateTime lastPeriodDate, int cycleLength) {
    final ovulationDate = calculateOvulationDate(lastPeriodDate, cycleLength);
    return date.year == ovulationDate.year &&
        date.month == ovulationDate.month &&
        date.day == ovulationDate.day;
  }

  /// Check if a date is period day
  static bool isPeriodDay(
      DateTime date, DateTime lastPeriodDate, int periodDays) {
    final periodEnd = lastPeriodDate.add(Duration(days: periodDays));
    return (date.isAfter(lastPeriodDate) ||
            date.isAtSameMomentAs(lastPeriodDate)) &&
        (date.isBefore(periodEnd) || date.isAtSameMomentAs(periodEnd));
  }

  /// Get average cycle length from multiple cycle dates
  static int getAverageCycleLength(List<DateTime> cycleDates) {
    if (cycleDates.isEmpty) return 28;
    if (cycleDates.length < 2) return 28;

    int totalDays = 0;
    for (int i = 1; i < cycleDates.length; i++) {
      totalDays += cycleDates[i].difference(cycleDates[i - 1]).inDays;
    }

    return (totalDays / (cycleDates.length - 1)).round();
  }
}

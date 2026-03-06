extension DateTimeExt on DateTime {
  int get weekNumber {
    final dayOfYear = difference(DateTime(year, 1, 1)).inDays;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String get shortDate => '$day/${month.toString().padLeft(2, '0')}';
}

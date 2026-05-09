part of '../../main.dart';

const _analyticsWindowDays = 14;
const _recentCheckInLimit = 7;

List<DayEntry> _latestEntries(List<DayEntry> entries, int count) {
  if (entries.length <= count) {
    return entries;
  }
  return entries.sublist(entries.length - count);
}

List<DayEntry> _entriesWithinPreviousDays(List<DayEntry> entries, int days) {
  if (entries.isEmpty) {
    return entries;
  }

  final latest = entries.last.date;
  final latestDay = _dateOnly(latest);
  final firstIncludedDay = latestDay.subtract(Duration(days: days - 1));

  return entries.where((entry) {
    final entryDay = _dateOnly(entry.date);
    return !entryDay.isBefore(firstIncludedDay) && !entryDay.isAfter(latestDay);
  }).toList();
}

double _average(Iterable<double> values) {
  final list = values.toList();
  if (list.isEmpty) {
    return 0;
  }
  return list.fold<double>(0, (sum, value) => sum + value) / list.length;
}

String _weekday(DateTime date) {
  const names = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  return names[date.weekday % 7];
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _sundayFirstWeekdayIndex(DateTime date) => date.weekday % 7;

double _roundTenth(double value) => (value * 10).round() / 10;

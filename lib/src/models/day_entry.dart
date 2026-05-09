part of '../../main.dart';

class DayEntry {
  const DayEntry({
    required this.date,
    required this.sleep,
    required this.focus,
    required this.exercise,
    required this.screen,
    required this.social,
    required this.water,
    required this.mood,
    required this.stress,
  });

  final DateTime date;
  final double sleep;
  final double focus;
  final double exercise;
  final double screen;
  final double social;
  final double water;
  final double mood;
  final double stress;

  double get wellnessScore {
    final sleepScore = (sleep / 8).clamp(0, 1) * 25;
    final exerciseScore = (exercise / 45).clamp(0, 1) * 18;
    final waterScore = (water / 8).clamp(0, 1) * 12;
    final moodScore = (mood / 10) * 25;
    final stressScore = (1 - stress / 10) * 20;
    return sleepScore + exerciseScore + waterScore + moodScore + stressScore;
  }

  List<double> get balanceValues => [
    (sleep / 8).clamp(0, 1),
    (focus / 6).clamp(0, 1),
    (exercise / 60).clamp(0, 1),
    (social / 3).clamp(0, 1),
    (water / 8).clamp(0, 1),
  ];
}

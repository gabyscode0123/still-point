part of '../../main.dart';

class RingPainter extends CustomPainter {
  RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, stroke..color = backgroundColor);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      stroke..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}

class MoodLinePainter extends CustomPainter {
  MoodLinePainter(this.entries);

  final List<DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _centeredPlotRect(size, verticalInset: 20);
    _drawGrid(canvas, plot);
    _drawLine(
      canvas,
      plot,
      entries.map((e) => e.mood).toList(),
      SpaColors.mood,
    );
    _drawLine(
      canvas,
      plot,
      entries.map((e) => e.stress).toList(),
      SpaColors.stress,
    );
  }

  @override
  bool shouldRepaint(covariant MoodLinePainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class TimeBarPainter extends CustomPainter {
  TimeBarPainter(this.entries);

  final List<DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _centeredPlotRect(size, verticalInset: 20);
    _drawGrid(canvas, plot);
    final groupWidth = plot.width / entries.length;
    const colors = [
      SpaColors.focus,
      SpaColors.screen,
      SpaColors.exercise,
      SpaColors.social,
    ];

    for (var i = 0; i < entries.length; i++) {
      final values = [
        entries[i].focus,
        entries[i].screen,
        entries[i].exercise / 60,
        entries[i].social,
      ];
      final barWidth = math.min(9.0, groupWidth / 6);
      for (var j = 0; j < values.length; j++) {
        final height = plot.height * (values[j] / 10).clamp(0, 1);
        final x =
            plot.left +
            groupWidth * i +
            groupWidth / 2 +
            (j - 1.5) * (barWidth + 2) -
            barWidth / 2;
        final rect = Rect.fromLTWH(x, plot.bottom - height, barWidth, height);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()..color = colors[j],
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimeBarPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class RadarPainter extends CustomPainter {
  RadarPainter(this.entries);

  final List<DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero) + const Offset(0, 3);
    final radius = math.min(size.width, size.height) * .32;
    final labels = ['Sleep', 'Focus', 'Exercise', 'Social', 'Water'];
    final values = List<double>.generate(
      labels.length,
      (index) => _average(entries.map((entry) => entry.balanceValues[index])),
    );
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = SpaColors.blushStone;
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = SpaColors.porcelain;

    for (var ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (var i = 0; i < labels.length; i++) {
        final point = _radarPoint(center, radius * ring / 4, i, labels.length);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < labels.length; i++) {
      final end = _radarPoint(center, radius, i, labels.length);
      canvas.drawLine(center, end, axisPaint);
      _drawCenteredText(
        canvas,
        labels[i],
        _radarPoint(center, radius + 22, i, labels.length),
        const TextStyle(
          color: SpaColors.mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    final shape = Path();
    for (var i = 0; i < values.length; i++) {
      final point = _radarPoint(center, radius * values[i], i, values.length);
      if (i == 0) {
        shape.moveTo(point.dx, point.dy);
      } else {
        shape.lineTo(point.dx, point.dy);
      }
    }
    shape.close();
    canvas.drawPath(
      shape,
      Paint()
        ..color = SpaColors.mood.withValues(alpha: .24)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = SpaColors.mood
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class HeatMapPainter extends CustomPainter {
  HeatMapPainter(this.entries);

  final List<DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final recent = entries.length > _analyticsWindowDays
        ? entries.sublist(entries.length - _analyticsWindowDays)
        : entries;
    final firstDate = _dateOnly(recent.first.date);
    final lastDate = _dateOnly(recent.last.date);
    final firstGridDate = firstDate.subtract(
      Duration(days: _sundayFirstWeekdayIndex(firstDate)),
    );
    final gap = 7.0;
    const columns = 7;
    final rows = (lastDate.difference(firstGridDate).inDays ~/ columns) + 1;
    const headerHeight = 16.0;
    const headerGap = 8.0;
    final cell = math.min((size.width - gap * (columns - 1)) / columns, 42.0);
    final totalWidth = columns * cell + gap * (columns - 1);
    final totalHeight =
        headerHeight + headerGap + rows * cell + math.max(0, rows - 1) * gap;
    final left = (size.width - totalWidth) / 2;
    final top = (size.height - totalHeight) / 2;

    const weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var col = 0; col < columns; col++) {
      final x = left + col * (cell + gap);
      _drawCenteredText(
        canvas,
        weekdayLabels[col],
        Offset(x + cell / 2, top + headerHeight / 2),
        _axisTextStyle,
      );
    }

    for (final entry in recent) {
      final entryDate = _dateOnly(entry.date);
      final offsetDays = entryDate.difference(firstGridDate).inDays;
      final row = offsetDays ~/ columns;
      final col = offsetDays % columns;
      final x = left + col * (cell + gap);
      final y = top + headerHeight + headerGap + row * (cell + gap);
      final intensity = (entry.wellnessScore / 100).clamp(0, 1).toDouble();
      final color = Color.lerp(SpaColors.porcelain, SpaColors.mood, intensity)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cell, cell),
          const Radius.circular(8),
        ),
        Paint()..color = color,
      );
      _drawCenteredText(
        canvas,
        entry.wellnessScore.round().toString(),
        Offset(x + cell / 2, y + cell / 2),
        TextStyle(
          color: intensity > .62 ? Colors.white : SpaColors.deepSage,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeatMapPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

class ScatterPainter extends CustomPainter {
  ScatterPainter(this.entries);

  final List<DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = _labeledPlotRect(size);
    _drawGrid(canvas, plot);
    final paint = Paint()..color = SpaColors.mood;
    final trend = Paint()
      ..color = SpaColors.stress
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final entry in entries) {
      final x = plot.left + plot.width * ((entry.sleep - 3) / 7).clamp(0, 1);
      final y = plot.bottom - plot.height * (entry.mood / 10).clamp(0, 1);
      canvas.drawCircle(Offset(x, y), 5.5, paint);
    }

    final sorted = [...entries]..sort((a, b) => a.sleep.compareTo(b.sleep));
    final start = Offset(
      plot.left + plot.width * ((sorted.first.sleep - 3) / 7).clamp(0, 1),
      plot.bottom - plot.height * (sorted.first.mood / 10).clamp(0, 1),
    );
    final end = Offset(
      plot.left + plot.width * ((sorted.last.sleep - 3) / 7).clamp(0, 1),
      plot.bottom - plot.height * (sorted.last.mood / 10).clamp(0, 1),
    );
    canvas.drawLine(start, end, trend);
    _drawCenteredText(
      canvas,
      'Sleep',
      Offset(plot.center.dx, plot.bottom + 18),
      _axisTextStyle,
    );
    canvas.save();
    canvas.translate(plot.left - 18, plot.center.dy);
    canvas.rotate(-math.pi / 2);
    _drawCenteredText(canvas, 'Mood', Offset.zero, _axisTextStyle);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScatterPainter oldDelegate) =>
      oldDelegate.entries != entries;
}

Rect _centeredPlotRect(Size size, {double verticalInset = 18}) => Rect.fromLTRB(
  16,
  verticalInset,
  size.width - 16,
  size.height - verticalInset,
);

Rect _labeledPlotRect(Size size) =>
    Rect.fromLTRB(42, 18, size.width - 18, size.height - 42);

const _axisTextStyle = TextStyle(
  color: SpaColors.mutedText,
  fontSize: 11,
  fontWeight: FontWeight.w800,
);

void _drawGrid(Canvas canvas, Rect plot) {
  final paint = Paint()
    ..color = SpaColors.porcelain
    ..strokeWidth = 1;
  for (var i = 0; i <= 4; i++) {
    final y = plot.top + plot.height * i / 4;
    canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), paint);
  }
}

void _drawLine(Canvas canvas, Rect plot, List<double> values, Color color) {
  final path = Path();
  for (var i = 0; i < values.length; i++) {
    final x = plot.left + plot.width * (i / math.max(1, values.length - 1));
    final y = plot.bottom - plot.height * (values[i] / 10).clamp(0, 1);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  canvas.drawPath(
    path,
    Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  for (var i = 0; i < values.length; i++) {
    final x = plot.left + plot.width * (i / math.max(1, values.length - 1));
    final y = plot.bottom - plot.height * (values[i] / 10).clamp(0, 1);
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
  }
}

void _drawCenteredText(
  Canvas canvas,
  String text,
  Offset center,
  TextStyle style,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
}

Offset _radarPoint(Offset center, double radius, int index, int count) {
  final angle = -math.pi / 2 + (math.pi * 2 * index / count);
  return Offset(
    center.dx + math.cos(angle) * radius,
    center.dy + math.sin(angle) * radius,
  );
}

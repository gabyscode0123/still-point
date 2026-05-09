part of '../../main.dart';

class StillpointHome extends StatefulWidget {
  const StillpointHome({super.key});

  @override
  State<StillpointHome> createState() => _StillpointHomeState();
}

class _StillpointHomeState extends State<StillpointHome> {
  ChartMode _mode = ChartMode.mood;
  late final List<DayEntry> _entries = _seedEntries();

  List<DayEntry> get _sortedEntries =>
      [..._entries]..sort((a, b) => a.date.compareTo(b.date));

  @override
  Widget build(BuildContext context) {
    final entries = _sortedEntries;
    final scoreEntries = _latestEntries(entries, _analyticsWindowDays);
    final analyticsEntries = _entriesWithinPreviousDays(
      entries,
      _analyticsWindowDays,
    );
    final score = _average(
      scoreEntries.map((entry) => entry.wellnessScore),
    ).round();
    final avgSleep = _average(scoreEntries.map((entry) => entry.sleep));
    final avgMood = _average(scoreEntries.map((entry) => entry.mood));
    final avgStress = _average(scoreEntries.map((entry) => entry.stress));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: _Header(score: score, onAdd: _showEntrySheet),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _MetricSummary(
                  avgSleep: avgSleep,
                  avgMood: avgMood,
                  avgStress: avgStress,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _ChartSwitcher(
                  selected: _mode,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: _ChartPanel(mode: _mode, entries: analyticsEntries),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _InsightPanel(entries: analyticsEntries),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: _RecentEntries(entries: entries.reversed.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntrySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntrySheet(
        onSave: (entry) {
          setState(() => _upsertEntry(entry));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _upsertEntry(DayEntry entry) {
    final entryDay = _dateOnly(entry.date);
    _entries.removeWhere((current) => _dateOnly(current.date) == entryDay);
    _entries.add(entry);
  }
}

class _MetricSummary extends StatelessWidget {
  const _MetricSummary({
    required this.avgSleep,
    required this.avgMood,
    required this.avgStress,
  });

  final double avgSleep;
  final double avgMood;
  final double avgStress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: const Icon(
              CupertinoIcons.moon_stars_fill,
              color: SpaColors.blueGray,
            ),
            label: 'Sleep',
            value: '${avgSleep.toStringAsFixed(1)}h',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: const Icon(
              CupertinoIcons.smiley_fill,
              color: SpaColors.exercise,
            ),
            label: 'Mood',
            value: avgMood.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: const Icon(CupertinoIcons.bolt_fill, color: SpaColors.stress),
            label: 'Stress',
            value: avgStress.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.score, required this.onAdd});

  final int score;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpaColors.deepSage,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ScoreDial(score: score),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your wellness score reflects patterns from your last 14 check-ins.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .88),
                    fontSize: 14,
                    height: 1.32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Tooltip(
            message: 'Add daily entry',
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: SpaColors.oat,
                  foregroundColor: SpaColors.forest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log Today',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDial extends StatelessWidget {
  const _ScoreDial({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(70),
            painter: RingPainter(
              progress: score / 100,
              color: SpaColors.porcelain,
              backgroundColor: Colors.white.withValues(alpha: .18),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'score',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpaColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpaColors.taupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconTheme.merge(data: const IconThemeData(size: 22), child: icon),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: SpaColors.text,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: SpaColors.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartSwitcher extends StatelessWidget {
  const _ChartSwitcher({required this.selected, required this.onChanged});

  final ChartMode selected;
  final ValueChanged<ChartMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (ChartMode.mood, CupertinoIcons.waveform_path_ecg, 'Mood'),
      (ChartMode.time, CupertinoIcons.chart_bar_fill, 'Time'),
      (ChartMode.balance, CupertinoIcons.scope, 'Balance'),
      (ChartMode.heatmap, CupertinoIcons.square_grid_3x2_fill, 'Days'),
      (ChartMode.correlation, CupertinoIcons.graph_square_fill, 'Link'),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.$1 == selected;
          return Tooltip(
            message: item.$3,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(item.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 78,
                decoration: BoxDecoration(
                  color: isSelected ? SpaColors.deepSage : SpaColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? SpaColors.deepSage : SpaColors.taupe,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$2,
                      size: 17,
                      color: isSelected ? Colors.white : SpaColors.deepSage,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.$3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : SpaColors.deepSage,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.mode, required this.entries});

  final ChartMode mode;
  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      ChartMode.mood => 'Mood & Stress Pattern',
      ChartMode.time => 'Where Your Time Goes',
      ChartMode.balance => 'Average Balance Profile',
      ChartMode.heatmap => 'Daily Wellness Map',
      ChartMode.correlation => 'Sleep & Mood Link',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpaColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpaColors.taupe),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          const Text(
            'Last $_analyticsWindowDays days',
            style: TextStyle(
              color: SpaColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 265,
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: entries.isEmpty
                  ? const _EmptyAnalyticsState()
                  : SizedBox.expand(
                      key: ValueKey(mode),
                      child: CustomPaint(
                        painter: switch (mode) {
                          ChartMode.mood => MoodLinePainter(entries),
                          ChartMode.time => TimeBarPainter(entries),
                          ChartMode.balance => RadarPainter(entries),
                          ChartMode.heatmap => HeatMapPainter(entries),
                          ChartMode.correlation => ScatterPainter(entries),
                        },
                      ),
                    ),
            ),
          ),
          if (mode != ChartMode.balance) ...[
            const SizedBox(height: 14),
            _Legend(mode: mode),
          ],
        ],
      ),
    );
  }
}

class _EmptyAnalyticsState extends StatelessWidget {
  const _EmptyAnalyticsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Log today's check-in to generate insights.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: SpaColors.mutedText,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.mode});

  final ChartMode mode;

  @override
  Widget build(BuildContext context) {
    final items = switch (mode) {
      ChartMode.mood => [
        ('Mood', SpaColors.mood),
        ('Stress', SpaColors.stress),
      ],
      ChartMode.time => [
        ('Focus', SpaColors.focus),
        ('Screen', SpaColors.screen),
        ('Exercise', SpaColors.exercise),
        ('Social', SpaColors.social),
      ],
      ChartMode.balance => <(String, Color)>[],
      ChartMode.heatmap => [
        ('Lower', SpaColors.porcelain),
        ('Higher', SpaColors.mood),
      ],
      ChartMode.correlation => [
        ('Daily', SpaColors.mood),
        ('Trend', SpaColors.stress),
      ],
    };

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final item in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: SpaColors.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.entries});

  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _InsightSection(
        children: [
          _InsightTile(
            icon: CupertinoIcons.leaf_arrow_circlepath,
            title: 'No check-ins yet',
            body: "Log today's check-in to generate insights.",
            color: SpaColors.deepSage,
          ),
        ],
      );
    }

    final best = entries.reduce(
      (a, b) => a.wellnessScore > b.wellnessScore ? a : b,
    );
    final highScreenDays = entries.where((entry) => entry.screen >= 5).length;

    return _InsightSection(
      children: [
        _InsightTile(
          icon: CupertinoIcons.star_fill,
          title: 'Most restored day',
          body:
              '${_weekday(best.date)} felt strongest with a ${best.wellnessScore.round()} score after ${best.sleep.toStringAsFixed(1)}h sleep and ${best.exercise.round()} min of exercise.',
          color: SpaColors.forest,
        ),
        _InsightTile(
          icon: CupertinoIcons.link,
          title: 'Rest & Mood',
          body: 'Notice the relationship between rest and mood.',
          color: SpaColors.deepSage,
        ),
        _InsightTile(
          icon: CupertinoIcons.device_phone_portrait,
          title: 'Screen time',
          body:
              '$highScreenDays of ${entries.length} days crossed five hours, which may be worth noticing.',
          color: SpaColors.stress,
        ),
      ],
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reflections', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        for (final child in children) ...[child, const SizedBox(height: 10)],
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SpaColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpaColors.taupe),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: SpaColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(color: SpaColors.mutedText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries({required this.entries});

  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = entries.take(_recentCheckInLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Check-ins',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: SpaColors.mutedText,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        for (final entry in visibleEntries) _CheckInRow(entry: entry),
        if (entries.length > visibleEntries.length)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _showAllCheckIns(context),
              style: TextButton.styleFrom(
                foregroundColor: SpaColors.deepSage,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: const Text('See More'),
            ),
          ),
      ],
    );
  }

  void _showAllCheckIns(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 20),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
        decoration: const BoxDecoration(
          color: SpaColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'All Check-ins',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                  icon: const Icon(CupertinoIcons.xmark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return _CheckInRow(entry: entries[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  const _CheckInRow({required this.entry});

  final DayEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SpaColors.surface.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpaColors.blushStone.withValues(alpha: .62)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              _weekday(entry.date).substring(0, 3),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: SpaColors.deepSage,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _MiniStat(
                  icon: const Icon(
                    CupertinoIcons.moon_fill,
                    size: 13,
                    color: SpaColors.mutedText,
                  ),
                  text: '${entry.sleep}h',
                ),
                _MiniStat(
                  icon: const Icon(
                    CupertinoIcons.smiley_fill,
                    size: 13,
                    color: SpaColors.mutedText,
                  ),
                  text: '${entry.mood}/10',
                ),
                _MiniStat(
                  icon: const Icon(
                    CupertinoIcons.bolt_fill,
                    size: 13,
                    color: SpaColors.mutedText,
                  ),
                  text: '${entry.stress}/10',
                ),
              ],
            ),
          ),
          Text(
            entry.wellnessScore.round().toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: SpaColors.deepSage,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.text});

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: SpaColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EntrySheet extends StatefulWidget {
  const _EntrySheet({required this.onSave});

  final ValueChanged<DayEntry> onSave;

  @override
  State<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends State<_EntrySheet> {
  double sleep = 7.5;
  double focus = 4;
  double exercise = 30;
  double screen = 4;
  double social = 1.5;
  double water = 6;
  double mood = 7;
  double stress = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      decoration: const BoxDecoration(
        color: SpaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's Check-in",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                    icon: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
              _EntrySlider(
                label: 'Sleep',
                value: sleep,
                min: 3,
                max: 10,
                unit: 'h',
                onChanged: (value) => setState(() => sleep = value),
              ),
              _EntrySlider(
                label: 'Focus',
                value: focus,
                min: 0,
                max: 10,
                unit: 'h',
                onChanged: (value) => setState(() => focus = value),
              ),
              _EntrySlider(
                label: 'Exercise',
                value: exercise,
                min: 0,
                max: 90,
                unit: 'm',
                onChanged: (value) => setState(() => exercise = value),
              ),
              _EntrySlider(
                label: 'Screen time',
                value: screen,
                min: 0,
                max: 10,
                unit: 'h',
                onChanged: (value) => setState(() => screen = value),
              ),
              _EntrySlider(
                label: 'Social time',
                value: social,
                min: 0,
                max: 6,
                unit: 'h',
                onChanged: (value) => setState(() => social = value),
              ),
              _EntrySlider(
                label: 'Water',
                value: water,
                min: 0,
                max: 10,
                unit: '',
                onChanged: (value) => setState(() => water = value),
              ),
              _EntrySlider(
                label: 'Mood',
                value: mood,
                min: 1,
                max: 10,
                unit: '',
                onChanged: (value) => setState(() => mood = value),
              ),
              _EntrySlider(
                label: 'Stress',
                value: stress,
                min: 1,
                max: 10,
                unit: '',
                onChanged: (value) => setState(() => stress = value),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    widget.onSave(
                      DayEntry(
                        date: DateTime.now(),
                        sleep: _roundTenth(sleep),
                        focus: _roundTenth(focus),
                        exercise: _roundTenth(exercise),
                        screen: _roundTenth(screen),
                        social: _roundTenth(social),
                        water: _roundTenth(water),
                        mood: _roundTenth(mood),
                        stress: _roundTenth(stress),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: SpaColors.deepSage,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntrySlider extends StatelessWidget {
  const _EntrySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final display = unit.isEmpty
        ? value.toStringAsFixed(1)
        : '${value.toStringAsFixed(1)}$unit';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                display,
                style: const TextStyle(
                  color: SpaColors.mutedText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).round(),
            activeColor: SpaColors.deepSage,
            inactiveColor: SpaColors.porcelain,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

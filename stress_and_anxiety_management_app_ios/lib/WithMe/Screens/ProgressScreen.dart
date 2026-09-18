import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeCharts.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'DashboardScreen.dart';
import 'ExerciseChooseScreen.dart';
import 'HomeScreen.dart';
import 'MenuScreen.dart';

/// `image37.png` — "Your Progress".
///
/// The only screen in the design with the bottom nav bar. Week / Month / Year
/// tabs over a stress sparkline and a mood column, two stat tiles, and today's
/// intention.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  static const String route = '/progress';

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _db = DatabaseHelper();

  int _range = 0;
  List<double> _stress = const [];
  List<double> _mood = const [];
  int _checkIns = 0;

  static const List<int> _spans = [7, 30, 365];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final days = _spans[_range];
    final today = DateTime.now();
    final stress = <double>[];
    final mood = <double>[];
    var checkIns = 0;

    // Year view would be 365 points; sample it down to keep the sparkline
    // readable at 342 pt wide.
    final step = days > 60 ? days ~/ 30 : 1;

    for (var back = days - 1; back >= 0; back -= step) {
      final date = today.subtract(Duration(days: back));
      final gauge = await _db.getControlGauge(date);
      final m = await _db.getMood(date);
      if (gauge != null) stress.add((6 - gauge).toDouble());
      if (m != null) {
        mood.add(_moodScore(m));
        checkIns++;
      }
    }

    if (!mounted) return;
    setState(() {
      _stress = stress;
      _mood = mood.length <= 4 ? mood : mood.sublist(mood.length - 4);
      _checkIns = checkIns;
    });
  }

  static double _moodScore(String mood) => switch (mood.toLowerCase()) {
        'rough' => 1,
        'low' => 2,
        'okay' => 3,
        'pretty good' => 4,
        'good' => 5,
        _ => 3,
      };

  void _navigate(int index) {
    if (index == 2) return;
    final target = switch (index) {
      0 => const WithMeHomeScreen(),
      1 => const ExerciseChooseScreen(),
      _ => const MenuScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (_range) {
      0 => 'this week',
      1 => 'this month',
      _ => 'this year',
    };

    return WithMeScaffold(
      lockup: false,
      title: 'Your Progress',
      bottomNav: WithMeBottomNav(index: 2, onChanged: _navigate),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs(
            labels: const ['Week', 'Month', 'Year'],
            index: _range,
            onChanged: (i) {
              setState(() => _range = i);
              _load();
            },
          ),
          const SizedBox(height: WithMeSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniCard(
                  title: 'Stress level',
                  child: _stress.length < 2
                      ? const _NotEnough()
                      : Sparkline(values: _stress),
                ),
              ),
              const SizedBox(width: WithMeSpace.md),
              Expanded(
                child: _MiniCard(
                  title: 'Mood',
                  child: _mood.isEmpty
                      ? const _NotEnough()
                      : BarChart(values: _mood),
                ),
              ),
            ],
          ),
          const SizedBox(height: WithMeSpace.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '$_checkIns',
                  caption: 'check-ins\n$label',
                ),
              ),
              const SizedBox(width: WithMeSpace.md),
              Expanded(
                child: StatTile(
                  tinted: true,
                  value: _checkIns >= 3 ? 'Positive trend' : 'Getting started',
                  caption: 'Keep going!',
                ),
              ),
            ],
          ),
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            radius: WithMeSpace.radiusMd,
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.md,
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
              behavior: HitTestBehavior.opaque,
              child: Text(
                _checkIns == 0
                    ? 'No intention set today yet.'
                    : "Today's intention: feel calmer · 1 exercise done",
                style: WithMeText.body.copyWith(color: WithMeColors.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => WithMeCard(
        radius: 18,
        height: 96,
        padding: const EdgeInsets.all(WithMeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: WithMeText.caption.copyWith(color: WithMeColors.ink),
            ),
            const SizedBox(height: WithMeSpace.sm),
            Expanded(child: child),
          ],
        ),
      );
}

class _NotEnough extends StatelessWidget {
  const _NotEnough();

  @override
  Widget build(BuildContext context) => Center(
        child: Text('Not enough data', style: WithMeText.caption),
      );
}

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
///
/// The mockup highlights Home in the nav bar while showing Progress. Treated
/// as a slip in the mockup — highlighting the screen you are on is what the
/// control is for. Noted in the spec's known problems.
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
    final from = today.subtract(Duration(days: days - 1));
    final stress = <double>[];
    final mood = <double>[];
    var checkIns = 0;

    // Two queries for the span, not two per day — the year view would
    // otherwise be 730 round trips to open one screen.
    Map<String, int> gauges;
    Map<String, String> moods;
    try {
      gauges = await _db.getControlGaugesBetween(from, today);
      moods = await _db.getMoodsBetween(from, today);
    } catch (_) {
      // A device that cannot open its database should still show the empty
      // state rather than throw. sqflite has no web implementation, so this
      // is also what the browser preview takes.
      gauges = const {};
      moods = const {};
    }

    // Year view would be 365 points; sample it down to keep the sparkline
    // readable at 342 pt wide.
    final step = days > 60 ? days ~/ 30 : 1;

    for (var back = days - 1; back >= 0; back -= step) {
      final key =
          DatabaseHelper.dateKey(today.subtract(Duration(days: back)));
      final gauge = gauges[key];
      final m = moods[key];
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
                  // Measured at 109 on image37, where the caption wraps.
                  minHeight: 109,
                  caption: 'check-ins\n$label',
                ),
              ),
              const SizedBox(width: WithMeSpace.md),
              Expanded(
                child: StatTile(
                  tinted: true,
                  minHeight: 109,
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
              child: _checkIns == 0
                  ? Text(
                      'No intention set today yet.',
                      style: WithMeText.body.copyWith(color: WithMeColors.ink),
                    )
                  // The mockup sets the intention itself in bold teal.
                  : RichText(
                      text: TextSpan(
                        style: WithMeText.body
                            .copyWith(color: WithMeColors.ink),
                        children: [
                          const TextSpan(text: "Today's intention: "),
                          TextSpan(
                            text: 'feel calmer',
                            style: WithMeText.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: WithMeColors.teal,
                            ),
                          ),
                          const TextSpan(text: ' · 1 exercise done'),
                        ],
                      ),
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
        // The pair of chart cards measures 136 tall on image37.
        height: 136,
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

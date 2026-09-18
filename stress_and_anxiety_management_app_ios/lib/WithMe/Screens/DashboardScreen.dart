import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeCharts.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'TriggersSignsScreen.dart';

/// `image32.png` — "Your Insights".
///
/// A 30-day donut with a value legend beside it, then the progress note.
/// Counts come from the stressor rows the check-in writes; the design's
/// 40/20/20/10/10 split is sample data, not a spec.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String route = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper();

  int _tab = 0;
  List<Slice> _slices = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final counts = <String, int>{};
    final today = DateTime.now();

    for (var back = 0; back < 30; back++) {
      final date = today.subtract(Duration(days: back));
      final row = await _db.getStressor(date);
      final category = row?['category'] as String?;
      if (category != null && category.isNotEmpty) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    const order = ['Work', 'Home', 'School', 'Social'];
    final slices = <Slice>[
      for (var i = 0; i < order.length; i++)
        if ((counts[order[i]] ?? 0) > 0)
          Slice(
            order[i],
            counts[order[i]]!.toDouble(),
            WithMeColors.series[i % WithMeColors.series.length],
          ),
    ];
    final other = counts.entries
        .where((e) => !order.contains(e.key))
        .fold<int>(0, (sum, e) => sum + e.value);
    if (other > 0) {
      slices.add(Slice('Other', other.toDouble(), WithMeColors.slate));
    }

    if (mounted) setState(() => _slices = slices);
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      lockup: false,
      title: 'Your Insights',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Share with someone I trust',
        filled: false,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing is not wired up in this UI pass.'),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs(
            labels: const ['Triggers', 'Feelings', 'Stress'],
            index: _tab,
            onChanged: (i) {
              setState(() => _tab = i);
              if (i != 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TriggersSignsScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeCard(
            child: _slices.isEmpty
                ? Text(
                    'No check-ins in the last 30 days yet.',
                    textAlign: TextAlign.center,
                    style: WithMeText.body,
                  )
                : Row(
                    children: [
                      DonutChart(slices: _slices, centreLabel: '30d'),
                      const SizedBox(width: WithMeSpace.lg),
                      Expanded(child: ValueLegend(slices: _slices)),
                    ],
                  ),
          ),
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            radius: WithMeSpace.radiusMd,
            color: WithMeColors.mint.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're making progress!",
                  style: WithMeText.option.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: WithMeColors.teal,
                  ),
                ),
                const SizedBox(height: WithMeSpace.sm),
                Text(
                  'Awareness is the first step to positive change. '
                  '${_leader()} came up most.',
                  style: WithMeText.body.copyWith(color: WithMeColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(
              size: 140,
              expression: MascotExpression.encouraging,
            ),
          ),
        ],
      ),
    );
  }

  String _leader() {
    if (_slices.isEmpty) return 'Nothing';
    return _slices
        .reduce((a, b) => a.value >= b.value ? a : b)
        .label;
  }
}

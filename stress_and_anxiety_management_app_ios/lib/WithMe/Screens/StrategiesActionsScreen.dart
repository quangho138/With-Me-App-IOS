import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeCharts.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Theme/WithMeTheme.dart';
import 'DayDetailScreen.dart';
import 'TriggersSignsScreen.dart';

/// `image34.png` — "Strategies & Actions".
///
/// A pie for the strategies and a legend-only card for the actions, with the
/// highest-rated action called out underneath.
///
/// Strategy ratings have no table of their own — `LocalDatabase` covers
/// reflections, moods, the control gauge and stressors — so this reads the
/// strategy vocabulary from `kStrategies` and shows an even split until a
/// ratings table exists. That gap is worth closing before the screen means
/// anything.
class StrategiesActionsScreen extends StatelessWidget {
  const StrategiesActionsScreen({super.key});

  static const String route = '/strategies-and-actions';

  @override
  Widget build(BuildContext context) {
    final strategies = <Slice>[
      for (var i = 0; i < kStrategies.length; i++)
        Slice(
          kStrategies[i],
          1,
          WithMeColors.series[i % WithMeColors.series.length],
        ),
    ];

    final actions = <Slice>[
      for (var i = 0; i < kStrategies.length; i++)
        Slice(
          kActionsByStrategy[kStrategies[i]]!.first,
          1,
          WithMeColors.series[i % WithMeColors.series.length],
        ),
    ];

    return WithMeScaffold(
      title: 'Strategies & Actions',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'View entry details',
        filled: false,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DayDetailScreen(date: DateTime.now()),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DateRangeCard(label: 'Last 7 days'),
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Heading('Strategies'),
                const SizedBox(height: WithMeSpace.md),
                Center(child: PieChart(slices: strategies)),
                const SizedBox(height: WithMeSpace.md),
                ChartLegend(slices: strategies),
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Heading('Actions'),
                const SizedBox(height: WithMeSpace.md),
                ChartLegend(slices: actions, showPercent: false),
                const SizedBox(height: WithMeSpace.md),
                Text(
                  'Ratings are not stored yet, so this shows the actions on '
                  'offer rather than how they have gone.',
                  style: WithMeText.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: WithMeText.option.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: WithMeColors.teal,
        ),
      );
}

import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeCharts.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'StrategiesActionsScreen.dart';

/// `image33.png` — "Triggers & Signs".
///
/// Two pie cards under a date-range header, each with a two-column legend
/// showing one decimal place.
class TriggersSignsScreen extends StatefulWidget {
  const TriggersSignsScreen({super.key});

  static const String route = '/triggers-and-signs';

  @override
  State<TriggersSignsScreen> createState() => _TriggersSignsScreenState();
}

class _TriggersSignsScreenState extends State<TriggersSignsScreen> {
  final _db = DatabaseHelper();

  List<Slice> _triggers = const [];
  List<Slice> _signs = const [];

  static const int _days = 14;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final triggers = <String, int>{};
    final signs = <String, int>{};
    final today = DateTime.now();

    for (var back = 0; back < _days; back++) {
      final date = today.subtract(Duration(days: back));
      final row = await _db.getStressor(date);

      final category = row?['category'] as String?;
      if (category != null && category.isNotEmpty) {
        triggers[category] = (triggers[category] ?? 0) + 1;
      }

      // The check-in stores the chosen signs in the stressor detail column.
      final detail = row?['detail'] as String?;
      if (detail != null && detail.isNotEmpty) {
        for (final sign in detail.split(',')) {
          final key = sign.trim();
          if (key.isEmpty) continue;
          signs[key] = (signs[key] ?? 0) + 1;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _triggers = _toSlices(triggers);
      _signs = _toSlices(signs);
    });
  }

  static List<Slice> _toSlices(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < entries.length; i++)
        Slice(
          entries[i].key,
          entries[i].value.toDouble(),
          WithMeColors.series[i % WithMeColors.series.length],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Triggers & Signs',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Continue',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StrategiesActionsScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DateRangeCard(label: 'Last $_days days'),
          const SizedBox(height: WithMeSpace.md),
          _PieCard(title: 'Triggers', slices: _triggers),
          const SizedBox(height: WithMeSpace.md),
          _PieCard(title: 'Signs', slices: _signs),
        ],
      ),
    );
  }
}

/// The "DATE RANGE" strip both breakdown screens open with.
class DateRangeCard extends StatelessWidget {
  const DateRangeCard({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      radius: WithMeSpace.radiusMd,
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.lg,
        vertical: WithMeSpace.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SectionLabel('Date range'),
          Text(
            label,
            style: WithMeText.option.copyWith(
              fontWeight: FontWeight.w700,
              color: WithMeColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieCard extends StatelessWidget {
  const _PieCard({required this.title, required this.slices});

  final String title;
  final List<Slice> slices;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WithMeText.option.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: WithMeColors.teal,
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          if (slices.isEmpty)
            Center(
              child: Text('Nothing logged yet.', style: WithMeText.body),
            )
          else ...[
            Center(child: PieChart(slices: slices)),
            const SizedBox(height: WithMeSpace.md),
            ChartLegend(slices: slices),
          ],
        ],
      ),
    );
  }
}

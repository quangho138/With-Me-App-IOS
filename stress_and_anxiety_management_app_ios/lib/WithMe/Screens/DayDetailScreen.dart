import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeCharts.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';

/// `image35.png` — one day's entry.
///
/// Mood and stress on one line, the day's note, the chips for what was
/// tagged, then two small charts side by side and the edit-window notice.
class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final _db = DatabaseHelper();

  String? _mood;
  int? _gauge;
  Map<String, dynamic>? _stressor;
  List<Map<String, dynamic>> _reflections = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mood = await _db.getMood(widget.date);
    final gauge = await _db.getControlGauge(widget.date);
    final stressor = await _db.getStressor(widget.date);
    final reflections = await _db.getReflectionsByDate(widget.date);

    if (!mounted) return;
    setState(() {
      _mood = mood;
      _gauge = gauge;
      _stressor = stressor;
      _reflections = reflections;
      _loaded = true;
    });
  }

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// The design shows "Locked — entries can be edited for 24 hours."
  bool get _locked =>
      DateTime.now().difference(widget.date) > const Duration(hours: 24);

  @override
  Widget build(BuildContext context) {
    final d = widget.date;
    final title = '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

    return WithMeScaffold(
      title: title,
      onBack: () => Navigator.of(context).pop(),
      child: !_loaded
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WithMeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: WithMeColors.peach,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: WithMeSpace.sm),
                          Text(
                            _summary(),
                            style: WithMeText.option.copyWith(
                              fontWeight: FontWeight.w700,
                              color: WithMeColors.teal,
                            ),
                          ),
                        ],
                      ),
                      if (_note() != null) ...[
                        const SizedBox(height: WithMeSpace.sm),
                        Text(
                          '"${_note()}"',
                          style: WithMeText.body.copyWith(
                            color: WithMeColors.ink,
                          ),
                        ),
                      ],
                      if (_chips().isNotEmpty) ...[
                        const SizedBox(height: WithMeSpace.md),
                        Wrap(
                          spacing: WithMeSpace.sm,
                          runSpacing: WithMeSpace.sm,
                          children: [for (final c in _chips()) _Chip(c)],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: WithMeSpace.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WithMeCard(
                        radius: 18,
                        padding: const EdgeInsets.all(WithMeSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Signs', style: WithMeText.caption),
                            const SizedBox(height: WithMeSpace.sm),
                            BarChart(
                              values: _signBars(),
                              highlightLast: false,
                              height: 44,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: WithMeSpace.md),
                    Expanded(
                      child: WithMeCard(
                        radius: 18,
                        padding: const EdgeInsets.all(WithMeSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Strategy', style: WithMeText.caption),
                            const SizedBox(height: WithMeSpace.sm),
                            const Center(
                              child: PieChart(
                                size: 60,
                                slices: [
                                  Slice('Used', 1, WithMeColors.peach),
                                  Slice('Rest', 1.4, WithMeColors.mint),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WithMeSpace.md),
                ReassuranceCard(
                  text: _locked
                      ? 'Locked — entries can be edited for 24 hours.'
                      : 'You can still edit this entry today.',
                ),
              ],
            ),
    );
  }

  String _summary() {
    final mood = _mood == null ? '-' : _moodScore(_mood!);
    final stress = _gauge == null ? '-' : '${6 - _gauge!}';
    return 'Mood $mood/5 · stress $stress/5';
  }

  static String _moodScore(String mood) => switch (mood.toLowerCase()) {
        'rough' => '1',
        'low' => '2',
        'okay' => '3',
        'pretty good' => '4',
        'good' => '5',
        _ => '3',
      };

  String? _note() {
    if (_reflections.isEmpty) return null;
    final row = _reflections.first;
    for (final key in ['what', 'why_question', 'who']) {
      final value = row[key] as String?;
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  List<String> _chips() {
    final chips = <String>[];
    final category = _stressor?['category'] as String?;
    if (category != null && category.isNotEmpty) chips.add(category);
    final detail = _stressor?['detail'] as String?;
    if (detail != null && detail.isNotEmpty) {
      chips.addAll(detail.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    return chips.take(4).toList();
  }

  List<double> _signBars() {
    final count = _chips().length;
    if (count == 0) return const [1, 1, 1, 1];
    return [for (var i = 0; i < 4; i++) (count - i).clamp(1, count).toDouble()];
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WithMeSpace.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: WithMeColors.peach.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
        ),
        child: Text(
          label,
          style: WithMeText.caption.copyWith(
            color: WithMeColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

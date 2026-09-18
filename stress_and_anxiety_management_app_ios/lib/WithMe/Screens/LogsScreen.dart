import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'DayDetailScreen.dart';

/// `image45.png` — "Your logs".
///
/// Reverse-chronological reflection entries under All / Notes / Exercises
/// tabs, closing on "Every step counts".
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  static const String route = '/logs';

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _db = DatabaseHelper();

  int _tab = 0;
  List<Map<String, dynamic>> _rows = const [];
  bool _loaded = false;

  static const List<Color> _dots = [
    WithMeColors.mint,
    WithMeColors.peach,
    WithMeColors.pink,
    WithMeColors.coral,
  ];

  @override
  void initState() {
    super.initState();
    _db.getReflections().then((rows) {
      if (mounted) setState(() {
        _rows = rows;
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Your logs',
      onBack: () => Navigator.of(context).pop(),
      footnote: const AccentLine('Every step counts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs(
            labels: const ['All', 'Notes', 'Exercises'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: WithMeSpace.lg),
          if (!_loaded)
            const SizedBox.shrink()
          else if (_rows.isEmpty)
            WithMeCard(
              child: Text(
                'Nothing logged yet. Your check-ins will show up here.',
                textAlign: TextAlign.center,
                style: WithMeText.body,
              ),
            )
          else
            for (var i = 0; i < _rows.length; i++) ...[
              if (i > 0) const SizedBox(height: WithMeSpace.md),
              _LogCard(row: _rows[i], dot: _dots[i % _dots.length]),
            ],
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.row, required this.dot});

  final Map<String, dynamic> row;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(row['date'] as String? ?? '');
    final body = [
      for (final key in ['who', 'what', 'where_question', 'when_question', 'why_question'])
        row[key] as String?,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');

    return GestureDetector(
      onTap: date == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)),
              ),
      behavior: HitTestBehavior.opaque,
      child: WithMeCard(
        radius: WithMeSpace.radiusMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: WithMeSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _when(date),
                    style: WithMeText.option.copyWith(
                      fontWeight: FontWeight.w700,
                      color: WithMeColors.teal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body.isEmpty ? 'Logged, no note.' : body,
                    style: WithMeText.body.copyWith(color: WithMeColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _when(DateTime? date) {
    if (date == null) return 'Earlier';
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    final time =
        '${date.hour % 12 == 0 ? 12 : date.hour % 12}:'
        '${date.minute.toString().padLeft(2, '0')} '
        '${date.hour < 12 ? 'AM' : 'PM'}';
    return switch (days) {
      0 => 'Today · $time',
      1 => 'Yesterday · $time',
      _ => '${_months[date.month - 1]} ${date.day} · $time',
    };
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
  ];
}

import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCalendar.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'DayDetailScreen.dart';

/// `image6.png` — Monthly Calendar.
///
/// Measured: the month panel is 346 x 281 at y 146 with a 20 pt radius, and
/// the legend card 346 x 146 at y 441. "Every step counts" closes the screen
/// in the accent script.
///
/// The marks come from what is actually in the database — a reflection, a mood
/// or a control-gauge entry for that day — rather than from sample data.
class MonthlyCalendarScreen extends StatefulWidget {
  const MonthlyCalendarScreen({super.key});

  static const String route = '/calendar';

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  final _db = DatabaseHelper();

  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selected;
  Map<int, DayMark> _marks = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month, days);
    final marks = <int, DayMark>{};

    // Three queries for the month rather than three per day.
    final moods = await _db.getMoodsBetween(first, last);
    final gauges = await _db.getControlGaugesBetween(first, last);
    final stressors = await _db.getStressorsBetween(first, last);

    for (var day = 1; day <= days; day++) {
      final key = DatabaseHelper.dateKey(
        DateTime(_month.year, _month.month, day),
      );
      final mood = moods[key];
      final gauge = gauges[key];

      // Strongest signal wins, in the order the legend lists them.
      if (mood != null && _isLow(mood)) {
        marks[day] = DayMark.challenging;
      } else if (gauge != null && gauge >= 4) {
        marks[day] = DayMark.feelingBetter;
      } else if (stressors.containsKey(key)) {
        marks[day] = DayMark.exercise;
      } else if (mood != null) {
        marks[day] = DayMark.checkIn;
      }
    }

    if (mounted) setState(() => _marks = marks);
  }

  static bool _isLow(String mood) {
    final m = mood.toLowerCase();
    return m.contains('rough') || m.contains('sad') || m.contains('bad');
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Monthly Calendar',
      onBack: () => Navigator.of(context).pop(),
      footnote: const AccentLine('Every step counts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthCalendar(
            month: _month,
            marks: _marks,
            selected: _selected,
            onMonthChanged: (m) {
              setState(() {
                _month = m;
                _marks = const {};
              });
              _load();
            },
            onSelect: (date) {
              setState(() => _selected = date);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)),
              );
            },
          ),
          const SizedBox(height: WithMeSpace.lg),
          const CalendarLegend(),
        ],
      ),
    );
  }
}

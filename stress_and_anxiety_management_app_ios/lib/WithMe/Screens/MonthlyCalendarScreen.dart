import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCalendar.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'DailyCheckInScreen.dart';
import 'DayDetailScreen.dart';

/// `image6.png` — Monthly Calendar.
///
/// Measured: the month panel is 346 x 281 at y 146 with a 20 pt radius, and
/// the legend card 346 x 146 at y 441. "Every step counts" closes the screen
/// in the accent script.
///
/// The marks come from what is actually in the database — a reflection, a mood
/// or a control-gauge entry for that day — rather than from sample data.
///
/// Today is where the daily check-in lives. Selecting it lists every page of
/// that check-in - "Hello Maya, how are you feeling today?", the stress
/// scale, motivation and on through the strategies - and each opens on its
/// own, or "Start today's check-in" walks them in order. Any other day opens
/// its detail, as before.
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
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
    _db
        .getUserName()
        .then((n) {
          if (mounted) setState(() => _name = n);
        })
        .catchError((_) {});
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _todaySelected => _selected != null && _isToday(_selected!);

  bool get _checkedInToday {
    final now = DateTime.now();
    return _month.year == now.year &&
        _month.month == now.month &&
        _marks.containsKey(now.day);
  }

  Future<void> _openCheckIn(int step) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyCheckInScreen(initialStep: step),
      ),
    );
    // Back from the check-in, today may have a mark it did not have before.
    if (mounted) _load();
  }

  Future<void> _load() async {
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month, days);
    final marks = <int, DayMark>{};

    // Three queries for the month rather than three per day.
    Map<String, String> moods;
    Map<String, int> gauges;
    Map<String, Map<String, dynamic>> stressors;
    try {
      moods = await _db.getMoodsBetween(first, last);
      gauges = await _db.getControlGaugesBetween(first, last);
      stressors = await _db.getStressorsBetween(first, last);
    } catch (_) {
      // A device that cannot open its database should still show the empty
      // state rather than throw. sqflite has no web implementation, so this
      // is also what the browser preview takes.
      moods = const {};
      gauges = const {};
      stressors = const {};
    }

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
      action: _todaySelected
          ? WithMeButton(
              label: "Start today's check-in",
              onPressed: () => _openCheckIn(0),
            )
          : null,
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
              if (_isToday(date)) return; // Today lists its check-in below.
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)),
              );
            },
          ),
          const SizedBox(height: WithMeSpace.lg),
          if (_todaySelected) ...[
            _TodayCheckIn(
              titles: DailyCheckInScreen.pageTitles(_name),
              done: _checkedInToday,
              onOpen: _openCheckIn,
            ),
            const SizedBox(height: WithMeSpace.lg),
          ],
          const CalendarLegend(),
        ],
      ),
    );
  }
}

/// Every page of today's check-in, each one a way in.
class _TodayCheckIn extends StatelessWidget {
  const _TodayCheckIn({
    required this.titles,
    required this.done,
    required this.onOpen,
  });

  final List<String> titles;
  final bool done;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Today's check-in", style: WithMeText.question),
          const SizedBox(height: WithMeSpace.xs),
          Text(
            done
                ? "You've checked in today. Tap a page to change an answer."
                : 'Tap a page to start there, or begin from the top below.',
            style: WithMeText.caption,
          ),
          const SizedBox(height: WithMeSpace.sm),
          for (var i = 0; i < titles.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: WithMeColors.slate),
            _PageRow(number: i + 1, title: titles[i], onTap: () => onOpen(i)),
          ],
        ],
      ),
    );
  }
}

class _PageRow extends StatelessWidget {
  const _PageRow({
    required this.number,
    required this.title,
    required this.onTap,
  });

  final int number;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: WithMeSpace.md),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: WithMeColors.mint,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: WithMeText.caption.copyWith(
                  color: WithMeColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: WithMeSpace.md),
            Expanded(
              child: Text(
                title,
                style: WithMeText.body.copyWith(color: WithMeColors.ink),
              ),
            ),
            const SizedBox(width: WithMeSpace.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: WithMeColors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

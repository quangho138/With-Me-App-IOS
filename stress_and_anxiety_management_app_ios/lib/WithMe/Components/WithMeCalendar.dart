import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';
import 'WithMeCards.dart';

/// What a day was marked with. The legend on `image6.png` names exactly four.
enum DayMark { checkIn, exercise, feelingBetter, challenging }

extension DayMarkInfo on DayMark {
  Color get color => switch (this) {
        DayMark.checkIn => WithMeColors.mint,
        DayMark.exercise => WithMeColors.peach,
        DayMark.feelingBetter => WithMeColors.coral,
        DayMark.challenging => WithMeColors.pink,
      };

  String get label => switch (this) {
        DayMark.checkIn => 'Check-in',
        DayMark.exercise => 'Exercise',
        DayMark.feelingBetter => 'Feeling better',
        DayMark.challenging => 'Challenging day',
      };

  /// The marks that read as dark enough to need a white numeral.
  bool get needsLightInk =>
      this == DayMark.feelingBetter || this == DayMark.challenging;
}

/// The month grid (`image6.png`).
///
/// Measured: panel 346 wide, 281 tall, 20 pt radius; the grid is a plain 7 x 6
/// of square cells with a circular fill behind a marked day and an outlined
/// circle on today.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.marks,
    this.selected,
    this.onSelect,
    this.onMonthChanged,
  });

  /// Any date inside the month to show.
  final DateTime month;

  /// Marked days, keyed by day-of-month.
  final Map<int, DayMark> marks;

  final DateTime? selected;
  final ValueChanged<DateTime>? onSelect;
  final ValueChanged<DateTime>? onMonthChanged;

  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final daysInPrev = DateTime(month.year, month.month, 0).day;
    // DateTime.weekday is 1 = Monday; the design starts the week on Sunday.
    final leading = first.weekday % 7;
    final today = DateTime.now();

    return WithMeCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.md,
        vertical: WithMeSpace.lg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Chevron(
                icon: Icons.chevron_left_rounded,
                onTap: () => onMonthChanged?.call(
                  DateTime(month.year, month.month - 1, 1),
                ),
              ),
              Expanded(
                child: Text(
                  '${_months[month.month - 1]} ${month.year}',
                  textAlign: TextAlign.center,
                  style: WithMeText.option.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: WithMeColors.teal,
                  ),
                ),
              ),
              _Chevron(
                icon: Icons.chevron_right_rounded,
                onTap: () => onMonthChanged?.call(
                  DateTime(month.year, month.month + 1, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: WithMeSpace.md),
          Row(
            children: [
              for (final d in _weekdays)
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: WithMeText.caption.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: WithMeSpace.sm),
          for (var week = 0; week < 6; week++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _cell(
                      index: week * 7 + col,
                      leading: leading,
                      daysInMonth: daysInMonth,
                      daysInPrev: daysInPrev,
                      today: today,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell({
    required int index,
    required int leading,
    required int daysInMonth,
    required int daysInPrev,
    required DateTime today,
  }) {
    final dayNumber = index - leading + 1;
    final inMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

    // Spill-over days from the neighbouring months are shown greyed, as in
    // the mockup's first and last rows.
    final shown = inMonth
        ? dayNumber
        : (dayNumber < 1 ? daysInPrev + dayNumber : dayNumber - daysInMonth);

    final mark = inMonth ? marks[dayNumber] : null;
    final isToday = inMonth &&
        today.year == month.year &&
        today.month == month.month &&
        today.day == dayNumber;
    final isSelected = inMonth &&
        selected != null &&
        selected!.year == month.year &&
        selected!.month == month.month &&
        selected!.day == dayNumber;

    final ink = !inMonth
        ? WithMeColors.inkFaint.withValues(alpha: 0.55)
        : mark != null && mark.needsLightInk
            ? Colors.white
            : WithMeColors.ink;

    return GestureDetector(
      onTap: inMonth && onSelect != null
          ? () => onSelect!(DateTime(month.year, month.month, dayNumber))
          : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 34,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mark?.color,
              border: isToday || isSelected
                  ? Border.all(color: WithMeColors.teal, width: 1.6)
                  : null,
            ),
            child: Text(
              '$shown',
              style: WithMeText.option.copyWith(fontSize: 14, color: ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 20, color: WithMeColors.inkSoft),
        ),
      );
}

/// The four-row key under the calendar.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.lg,
        vertical: WithMeSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final mark in DayMark.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: mark.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: WithMeSpace.md),
                  Text(mark.label, style: WithMeText.option),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

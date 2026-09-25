import 'package:flutter/foundation.dart';

import 'LocalDatabase.dart';

/// A sign-in and a week of check-ins, so the app can be shown with something
/// in it.
///
/// On by default in the browser build, which is only ever a demo - there is
/// no device and no way to have used the app beforehand. Off on phones unless
/// built with `--dart-define=WITHME_DEMO=true`, so a real install never picks
/// up invented rows.
class DemoAccount {
  DemoAccount._();

  static const String email = 'demo@withme.app';
  static const String password = 'withme123';
  static const String name = 'Maya';

  static bool get enabled =>
      kIsWeb || const bool.fromEnvironment('WITHME_DEMO');

  /// Create the account if it is missing and fill any of the last seven days
  /// that have no check-in.
  ///
  /// Topping up on every launch, rather than seeding once, keeps "this week"
  /// populated however long after the first visit the demo happens. Today is
  /// left empty so a check-in can be done live, and a day that already has a
  /// mood - a real entry - is never touched.
  static Future<void> ensure() async {
    final db = DatabaseHelper();

    if (!await db.emailExists(email)) {
      await db.insertUser(email, password);
    }
    if (await db.getUserName() == null) {
      await db.saveUserName(name);
    }

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    for (var back = 1; back <= _days.length; back++) {
      final entry = _days[back - 1];
      final day = midnight.subtract(Duration(days: back));
      final date = DateTime(
        day.year,
        day.month,
        day.day,
        entry.hour,
        entry.minute,
      );
      if (await db.getMood(date) != null) continue;

      await db.insertMood(date, entry.mood);
      await db.insertControlGauge(date, entry.control);
      await db.insertStressor(date, entry.area, detail: entry.signs);
      await db.insertReflection(
        who: entry.leanedOn,
        what: entry.note,
        when: 'Late morning, once the list was written down.',
        where: entry.area,
        why: 'It is the part I keep putting off.',
        date: date,
      );
    }
  }

  // Written in the voice image45 uses: short, specific, one thought each.
  static const List<_Day> _days = [
    _Day(16, 42, 'Good', 4, 'Work', 'Workload, Time mgmt',
        'Sam, over lunch.',
        'Breathing before the meeting actually helped. Shoulders dropped.'),
    _Day(21, 10, 'Okay', 3, 'Home', 'Financial',
        'Nobody - handled it myself.', 'Box breathing, 4 rounds. Slept better.'),
    _Day(7, 55, 'Not good', 2, 'Work', 'Boss, Colleagues',
        'Mum called at the right moment.', 'Hard morning. Logged it anyway.'),
    _Day(13, 26, 'Great', 5, 'School', 'Exam pressure', 'Study group.',
        'Studied in 25-minute blocks instead of one long sit.'),
    _Day(19, 3, 'Okay', 3, 'Social', 'Social media', 'My sister.',
        'Put the phone in a drawer for the evening.'),
    _Day(8, 38, 'Not good', 2, 'Work', 'Workload', 'Told my manager.',
        'Too much on at once. Asked for the deadline to move.'),
    _Day(22, 14, 'Good', 4, 'Home', 'Domestic duties', 'Ade came round.',
        'Cooked properly for the first time this week.'),
  ];
}

class _Day {
  const _Day(
    this.hour,
    this.minute,
    this.mood,
    this.control,
    this.area,
    this.signs,
    this.leanedOn,
    this.note,
  );

  final int hour;
  final int minute;
  final String mood;
  final int control;
  final String area;
  final String signs;
  final String leanedOn;
  final String note;
}

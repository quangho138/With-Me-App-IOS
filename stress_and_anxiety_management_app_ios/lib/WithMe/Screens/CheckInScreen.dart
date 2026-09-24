import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Theme/WithMeTheme.dart';

/// Check In — the five-part self-reflection (`image24.png`) as a page of its
/// own: Who, What, Where, When and Why, each with its dropdown of questions.
///
/// This is the original app's Self-Reflection screen brought into the V1
/// design. The mood-and-stress pages that used to run before it now open from
/// today's date on the monthly calendar (`DailyCheckInScreen`).
///
/// One reflection per day. Opening it again shows today's choices, and saving
/// replaces them rather than adding a second entry to the logs.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  static const String route = '/check-in';

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _db = DatabaseHelper();

  /// Category -> chosen question. Keys are those of [kReflectionPrompts].
  final Map<String, String?> _choices = {
    for (final key in kReflectionPrompts.keys) key: null,
  };

  bool _saving = false;

  /// Database column for each category.
  static const Map<String, String> _columns = {
    'Who?': 'who',
    'What?': 'what',
    'Where?': 'where_question',
    'When?': 'when_question',
    'Why?': 'why_question',
  };

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await _db.getReflectionsByDate(DateTime.now());
    } catch (_) {
      return; // Nothing to prefill; the page still works.
    }
    if (rows.isEmpty || !mounted) return;
    final row = rows.first;
    setState(() {
      for (final entry in _columns.entries) {
        final stored = row[entry.value] as String?;
        // Only restore a value the dropdown can show. A row written some
        // other way - the demo week, an older version - holds free text,
        // and handing that to the dropdown would throw.
        if (kReflectionPrompts[entry.key]!.contains(stored)) {
          _choices[entry.key] = stored;
        }
      }
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_choices.values.any((v) => v == null)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Choose one question from each of the five.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final today = DateTime.now();
    try {
      await _db.deleteReflectionsByDate(today);
      await _db.insertReflection(
        who: _choices['Who?']!,
        what: _choices['What?']!,
        when: _choices['When?']!,
        where: _choices['Where?']!,
        why: _choices['Why?']!,
        date: today,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Couldn't save this reflection on this device."),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    messenger.showSnackBar(
      const SnackBar(content: Text('Reflection saved. Well done.')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Check In',
      action: WithMeButton(
        label: 'Save reflection',
        onPressed: _saving ? null : _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QuestionCard(
            question: 'Take a moment for self-reflection',
            questionSize: 18,
            subtitle:
                'Select one question from each category that resonates with '
                'you today.',
          ),
          // Gaps 4 pt tighter than image24's: the page carries a title row
          // the mockup does not, and at the mockup's spacing "Why?" ends up
          // half under the button.
          const SizedBox(height: WithMeSpace.md),
          for (final entry in kReflectionPrompts.entries) ...[
            WithMeDropdown(
              label: entry.key,
              value: _choices[entry.key],
              items: entry.value,
              hint: entry.key == 'Why?' ? 'Select a question...' : null,
              onChanged: (v) => setState(() => _choices[entry.key] = v),
            ),
            const SizedBox(height: WithMeSpace.sm),
          ],
        ],
      ),
    );
  }
}

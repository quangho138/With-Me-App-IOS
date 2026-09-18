import 'package:flutter/material.dart';
import '../Components/MainScaffold.dart';
import 'BreathingExerciseDetailScreen.dart';
import 'BreathingExerciseType.dart';

class BreathingExercisesSelectionScreen extends StatefulWidget {
  const BreathingExercisesSelectionScreen({super.key});

  @override
  State<BreathingExercisesSelectionScreen> createState() =>
      _BreathingExercisesSelectionScreenState();
}

class _BreathingExercisesSelectionScreenState
    extends State<BreathingExercisesSelectionScreen> {
  // The first step selects an exercise category; the second shows its guided options.
  int _step = 0;
  int _selectedExercise = 0;

  static const _teal = Color(0xFF0D756D);
  static const _cream = Color(0xFFFFFCF7);
  static const _peach = Color(0xFFF3D0AF);

  final List<(String, String, Color)> _exerciseOptions = const [
    ('Breathing Exercise', '2 min · suggested for you', Colors.orangeAccent),
    ('Breathing, Focus Exercise', '3 min', Color(0xFF86CEC7)),
    ('Sleeping Relaxation exercise', '5 min', Color(0xFFD95A86)),
    ('Other exercises', '', Color(0xFFBFCBC8)),
  ];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Exercises',
      showBackButton: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4EBE6), _peach],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: _step == 0 ? _buildChooser(context) : _buildExerciseList(context),
          ),
        ),
      ),
    );
  }

  Widget _buildChooser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brandRow(),
        const SizedBox(height: 20),
        _panelTitle('Choose an exercise'),
        const SizedBox(height: 10),
        ...List.generate(_exerciseOptions.length, (index) {
          final option = _exerciseOptions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _choiceTile(
              title: option.$1,
              subtitle: option.$2,
              color: option.$3,
              selected: index == _selectedExercise,
              onTap: () => setState(() => _selectedExercise = index),
            ),
          );
        }),
        const SizedBox(height: 105),
        _primaryButton('Continue', () {
          if (_selectedExercise == 0) setState(() => _step = 1);
        }),
      ],
    );
  }

  Widget _buildExerciseList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brandRow(),
        const SizedBox(height: 24),
        const Text('Rest your mind', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: _teal)),
        const SizedBox(height: 8),
        const Text('Longer guided exercises, for when you have a\nfew minutes.',
            textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF315B59))),
        const SizedBox(height: 20),
        _exerciseTile(context, 'Destress your day', '5 min · unwind after work', Colors.deepOrange,
            BreathingExerciseType.destressYourDay),
        _exerciseTile(context, 'Ease your sleep', '8 min · 4-7-8 breathing', const Color(0xFF86CEC7),
            BreathingExerciseType.easeYourSleep),
        _exerciseTile(context, 'Strengthen your focus', '4 min · 4-4-4-4 focus', const Color(0xFFF5C3A2),
            BreathingExerciseType.strengthenYourFocus),
        const SizedBox(height: 20),
        Image.asset('assets/logo.png', height: 105, fit: BoxFit.contain),
        const SizedBox(height: 40),
        _primaryButton('Continue', () {}),
      ],
    );
  }

  Widget _brandRow() => Row(
        children: [
          Image.asset('assets/logo.png', width: 38, height: 38),
          const SizedBox(width: 8),
          const Text('With Me', style: TextStyle(color: _teal, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      );

  Widget _panelTitle(String text) => Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(22)),
        child: Text(text, textAlign: TextAlign.center,
            style: const TextStyle(color: _teal, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _choiceTile({required String title, required String subtitle, required Color color,
      required bool selected, required VoidCallback onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(color: selected ? _teal : _cream, borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            CircleAvatar(radius: 10, backgroundColor: color),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: selected ? Colors.white : const Color(0xFF173E3D), fontWeight: FontWeight.w600)),
              if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: selected ? Colors.white70 : const Color(0xFF47706D), fontSize: 11)),
            ])),
          ]),
        ),
      );

  Widget _exerciseTile(BuildContext context, String title, String subtitle, Color color, BreathingExerciseType type) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _choiceTile(title: title, subtitle: subtitle, color: color, selected: false,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BreathingExerciseDetailScreen(exerciseType: type)))),
      );

  Widget _primaryButton(String label, VoidCallback onPressed) => SizedBox(
        height: 48,
        child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      );
}
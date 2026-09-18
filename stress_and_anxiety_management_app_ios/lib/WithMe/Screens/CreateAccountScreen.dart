import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

/// `image2.png` — "Create your account".
///
/// Measured: three 55 pt fields at y 171 / 264 / 356, each with its label
/// above it, and a 60 pt action at y 676.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const String route = '/signup';

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _db = DatabaseHelper();

  bool _agreed = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _say('Fill in your name, email and a password.');
      return;
    }
    if (!_agreed) {
      _say('Please agree to the terms to continue.');
      return;
    }

    setState(() => _busy = true);

    try {
      if (await _db.emailExists(email)) {
        if (!mounted) return;
        setState(() => _busy = false);
        _say('That email already has an account.');
        return;
      }
      await _db.insertUser(email, password);
      await _db.saveUserName(name);
    } catch (_) {
      // sqflite has no web implementation, and a device can fail to open its
      // database too. Either way the button has to come back and say so
      // rather than sit disabled for ever.
      if (!mounted) return;
      setState(() => _busy = false);
      _say("Couldn't save your account on this device.");
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WithMeHomeScreen()),
      (_) => false,
    );
  }

  void _say(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Create your account',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Create account',
        onPressed: _busy ? null : _create,
      ),
      footnote: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WithMeLoginScreen()),
        ),
        child: Text(
          'Already with us? Log in',
          style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithMeField(label: 'Name', controller: _name, hint: 'Maya'),
          const SizedBox(height: WithMeSpace.lg),
          WithMeField(
            label: 'Email',
            controller: _email,
            hint: 'maya@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeField(label: 'Password', controller: _password, obscure: true),
          const SizedBox(height: WithMeSpace.lg),
          _TermsCheck(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v),
          ),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(size: 86, expression: MascotExpression.happy),
          ),
        ],
      ),
    );
  }
}

class _TermsCheck extends StatelessWidget {
  const _TermsCheck({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? WithMeColors.teal : WithMeColors.cream,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: WithMeColors.teal, width: 1.6),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: WithMeSpace.md),
          Expanded(
            child: Text(
              'I agree to the Terms and Privacy Policy. With Me is a '
              'companion, not medical care.',
              style: WithMeText.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

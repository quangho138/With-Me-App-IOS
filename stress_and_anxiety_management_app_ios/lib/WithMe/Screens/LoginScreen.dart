import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'HomeScreen.dart';
import 'ResetPasswordScreen.dart';

/// Log in.
///
/// **Not in the design document.** `image1.png` has a "Log In" button but the
/// document never shows where it leads — it jumps straight to "Create your
/// account" (`image2`) and "Reset your password" (`image3`). This screen is
/// built to match those two exactly rather than invented from nothing: same
/// title treatment, same 55 pt fields, same 60 pt action.
class WithMeLoginScreen extends StatefulWidget {
  const WithMeLoginScreen({super.key});

  static const String route = '/login';

  @override
  State<WithMeLoginScreen> createState() => _WithMeLoginScreenState();
}

class _WithMeLoginScreenState extends State<WithMeLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _db = DatabaseHelper();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final user = await _db.getUser(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _busy = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That email and password do not match.')),
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WithMeHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Welcome back',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(label: 'Log in', onPressed: _busy ? null : _login),
      footnote: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        ),
        child: Text(
          'Forgot your password?',
          style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithMeField(
            label: 'Email',
            controller: _email,
            hint: 'maya@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeField(label: 'Password', controller: _password, obscure: true),
          const SizedBox(height: WithMeSpace.xl),
          const Center(
            child: WithMeAvatar(size: 86, expression: MascotExpression.happy),
          ),
        ],
      ),
    );
  }
}

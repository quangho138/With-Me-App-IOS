import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// `image3.png` — "Reset your password".
///
/// Measured: an 84 pt explainer card at y 145, a 55 pt email field at y 268,
/// the mascot between, a tinted confirmation panel, and the action at y 708.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static const String route = '/reset-password';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Reset your password',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Send reset link',
        onPressed: () => setState(() => _sent = true),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ReassuranceCard(
            text: "Enter your email and I'll send you a reset link.",
          ),
          const SizedBox(height: WithMeSpace.xl),
          WithMeField(
            label: 'Email',
            controller: _email,
            hint: 'maya@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: WithMeSpace.xl),
          const Center(
            child: WithMeAvatar(size: 140, expression: MascotExpression.happy),
          ),
          const SizedBox(height: WithMeSpace.xl),
          // The mockup shows this panel already filled in; it only makes sense
          // once the link has actually been requested.
          if (_sent)
            WithMeCard(
              radius: WithMeSpace.radiusMd,
              color: WithMeColors.mint.withValues(alpha: 0.45),
              child: Text(
                'Check your inbox — the link works for 30 minutes.',
                textAlign: TextAlign.center,
                style: WithMeText.body.copyWith(color: WithMeColors.ink),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../Database/LocalDatabase.dart';
import '../WithMe/Components/WithMeBackdrop.dart';
import '../WithMe/Components/WithMeWordmark.dart';
import '../WithMe/Mascot/MascotExpression.dart';
import '../WithMe/Mascot/WithMeAvatar.dart';
import '../WithMe/Theme/WithMeTheme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> showErrorPopup(String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WithMeColors.creamLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        ),
        title: Text(
          'Something needs attention',
          style: WithMeText.question.copyWith(fontSize: 18),
        ),
        content: Text(message, style: WithMeText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: WithMeColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      await showErrorPopup('All fields are required.');
      return;
    }

    if (!isValidEmail(email)) {
      await showErrorPopup('Please enter a valid email address.');
      return;
    }

    final exists = await DatabaseHelper().emailExists(email);
    if (!mounted) return;

    if (exists) {
      await showErrorPopup('That email already exists. Please log in instead.');
      return;
    }

    await DatabaseHelper().insertUser(email, password);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully.')),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: WithMeSpace.xl,
                  vertical: WithMeSpace.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const WithMeAvatar(
                        size: 88,
                        expression: MascotExpression.encouraging,
                      ),
                      const SizedBox(height: WithMeSpace.sm),
                      const WithMeWordmark(scale: 0.82),
                      const SizedBox(height: WithMeSpace.xl),
                      _signupCard(),
                      const SizedBox(height: WithMeSpace.md),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        ),
                        child: Text(
                          'Already have an account? Login',
                          style: WithMeText.body.copyWith(
                            color: WithMeColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WithMeSpace.xl),
      decoration: BoxDecoration(
        color: WithMeColors.creamLight.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create your account',
            textAlign: TextAlign.center,
            style: WithMeText.question,
          ),
          const SizedBox(height: 6),
          const Text(
            'A calm place to track how you are doing.',
            textAlign: TextAlign.center,
            style: WithMeText.caption,
          ),
          const SizedBox(height: WithMeSpace.xl),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _fieldDecoration(
              label: 'Email',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          TextField(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => registerUser(),
            decoration: _fieldDecoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
            ),
          ),
          const SizedBox(height: WithMeSpace.xl),
          ElevatedButton.icon(
            onPressed: registerUser,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            label: const Text('Sign up'),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: WithMeColors.inkSoft),
      prefixIcon: Icon(icon, color: WithMeColors.teal),
      filled: true,
      fillColor: WithMeColors.cream,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
        borderSide: BorderSide(
          color: WithMeColors.teal.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
        borderSide: const BorderSide(color: WithMeColors.teal, width: 1.6),
      ),
    );
  }
}

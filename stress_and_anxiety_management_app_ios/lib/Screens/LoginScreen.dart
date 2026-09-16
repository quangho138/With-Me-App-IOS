import 'package:flutter/material.dart';

import '../Database/LocalDatabase.dart';
import '../WithMe/Components/WithMeBackdrop.dart';
import '../WithMe/Components/WithMeWordmark.dart';
import '../WithMe/Mascot/MascotExpression.dart';
import '../WithMe/Mascot/WithMeAvatar.dart';
import '../WithMe/Theme/WithMeTheme.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      await showErrorPopup('Please fill in all fields.');
      return;
    }

    if (!isValidEmail(email)) {
      await showErrorPopup('Please enter a valid email address.');
      return;
    }

    final user = await DatabaseHelper().getUser(email, password);
    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      await showErrorPopup('The email or password does not match our records.');
    }
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
                      _loginCard(),
                      const SizedBox(height: WithMeSpace.md),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: Text(
                          "Don't have an account? Sign up",
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

  Widget _loginCard() {
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
            'Welcome back',
            textAlign: TextAlign.center,
            style: WithMeText.question,
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to continue your check-in.',
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
            onSubmitted: (_) => loginUser(),
            decoration: _fieldDecoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
            ),
          ),
          const SizedBox(height: WithMeSpace.xl),
          ElevatedButton.icon(
            onPressed: loginUser,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            label: const Text('Login'),
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

import 'package:flutter/material.dart';
import '../Database/LocalDatabase.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> showErrorPopup(String message) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blueGrey[50],
        title: const Text('Error', style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      await showErrorPopup("⚠️ All fields are required.");
      return;
    }

    if (!isValidEmail(email)) {
      await showErrorPopup("❌ Please enter a valid email address.");
      return;
    }

    final exists = await DatabaseHelper().emailExists(email);
    if (exists) {
      await showErrorPopup("❌ Email already exists. Please log in.");
      return;
    }

    await DatabaseHelper().insertUser(email, password);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Account created successfully!")),
    );

    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blueGrey[700];
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 65,
                backgroundColor: primaryColor,
                child: const Text(
                  "howRU",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 25),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email_outlined, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              Icon(Icons.lock_outline, color: primaryColor),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

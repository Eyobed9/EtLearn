import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'package:et_learn/screens/registration_success_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // NON-nullable error message to prevent crashes
  String errorMessage = "";

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength flags
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  // Check password strength live
  void _checkPassword(String value) {
    setState(() {
      hasUpper = value.contains(RegExp(r'[A-Z]'));
      hasLower = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'\d'));
      hasSpecial = value.contains(RegExp(r'[@$!%*?&]'));
      hasMinLength = value.length >= 8;
    });
  }

  bool get isPasswordStrong =>
      hasUpper && hasLower && hasNumber && hasSpecial && hasMinLength;

  // Create user function
  Future<void> createUserWithEmailAndPassword() async {
    // Check password strength first
    if (!isPasswordStrong) {
      setState(() {
        errorMessage =
            "Password does not meet security requirements. Check the indicators below.";
      });
      return;
    }

    // Check if passwords match
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = "Passwords don't match";
      });
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      if (!mounted) return;

      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        // Provide default message if null
        errorMessage = e.message ?? "Something went wrong. Please try again.";
      });
    }
  }

  // Password rule row widget
  Widget _passwordRule(String text, bool valid) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: valid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: valid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email field
            const Text("Email", style: TextStyle(color: Color(0XFF858597))),
            const SizedBox(height: 4),
            TextField(
              controller: _controllerEmail,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'example@email.com',
              ),
            ),

            const SizedBox(height: 12),

            // Password field
            const Text("Password", style: TextStyle(color: Color(0XFF858597))),
            const SizedBox(height: 4),
            TextField(
              controller: _controllerPassword,
              obscureText: _obscurePassword,
              onChanged: _checkPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '********',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                // ONLY include errorText if you want it displayed inside the field
                errorText:
                    !isPasswordStrong && _controllerPassword.text.isNotEmpty
                    ? "Password is weak"
                    : null,
              ),
            ),

            const SizedBox(height: 8),
            _passwordRule("At least 8 characters", hasMinLength),
            _passwordRule("Uppercase letter", hasUpper),
            _passwordRule("Lowercase letter", hasLower),
            _passwordRule("Number", hasNumber),
            _passwordRule("Special character (@\$!%*?&)", hasSpecial),

            const SizedBox(height: 12),

            // Confirm password
            const Text(
              "Confirm Password",
              style: TextStyle(color: Color(0XFF858597)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _controllerConfirmPassword,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '********',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Error message
            Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

            const SizedBox(height: 12),

            // Sign Up button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5CFF),
                minimumSize: const Size(double.infinity, 51),
              ),
              onPressed: createUserWithEmailAndPassword,
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

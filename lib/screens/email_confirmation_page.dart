import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:et_learn/screens/registration_success_page.dart';

class EmailConfirmationPage extends StatefulWidget {
  const EmailConfirmationPage({super.key});

  @override
  State<EmailConfirmationPage> createState() => _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends State<EmailConfirmationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  bool _isVerified = false;
  bool _canResend = true;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          setState(() {
            _isVerified = true;
          });
          // Navigate to Success Page after sort delay
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RegistrationSuccessPage(),
              ),
            );
          });
        }
      }
    });
  }

  Future<void> _resendEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        setState(() {
          _canResend = false;
          _resendCountdown = 30;
        });

        // Simple cooldown timer logic
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            if (_resendCountdown > 0) {
              _resendCountdown--;
            } else {
              _canResend = true;
              timer.cancel();
            }
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error resending email: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isVerified
                    ? Icons.check_circle_rounded
                    : Icons.mark_email_read_rounded,
                size: 80,
                color: _isVerified ? Colors.green : const Color(0xFF3D5CFF),
              ),
              const SizedBox(height: 24),
              Text(
                _isVerified ? 'Email Verified' : 'Check your email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F39),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isVerified
                    ? 'Redirecting you...'
                    : 'We have sent a confirmation email to ${_auth.currentUser?.email}.\nPlease click the link to verify your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF858597),
                ),
              ),
              const SizedBox(height: 32),
              if (!_isVerified)
                ElevatedButton(
                  onPressed: _canResend ? _resendEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5CFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _canResend
                        ? 'Resend Email'
                        : 'Resend in $_resendCountdown s',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

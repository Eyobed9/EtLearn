import 'package:et_learn/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:et_learn/authentication/signup_page.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:et_learn/services/user_sync_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final Auth auth = Auth();
  String? errorMessage = "";

  int _failedAttempts = 0;
  DateTime? _lockUntil;
  bool _obscurePassword = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    // If locked, block attempts until the lock expires.
    if (_lockUntil != null) {
      final now = DateTime.now();
      if (now.isBefore(_lockUntil!)) {
        final remaining = _lockUntil!.difference(now);
        setState(() {
          errorMessage =
              'Login locked. Try again in ${remaining.inMinutes}m ${(remaining.inSeconds % 60)}s';
        });
        return;
      } else {
        // Lock expired, reset counters.
        setState(() {
          _lockUntil = null;
          _failedAttempts = 0;
        });
      }
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WidgetTree()),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _failedAttempts = 0;
        _lockUntil = null;
        errorMessage = "";
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _failedAttempts += 1;
        if (_failedAttempts >= 5) {
          _lockUntil = DateTime.now().add(const Duration(minutes: 5));
          errorMessage = 'Too many attempts. Locked for 5 minutes.';
        } else {
          final remaining = 5 - _failedAttempts;
          errorMessage =
              '${e.message ?? 'Login failed'}. Attempts left: $remaining';
        }
      });
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() {
      errorMessage = "";
    });

    final user = await auth.loginWithGoogle();

    if (auth.googleLoginError != null) {
      setState(() {
        errorMessage = auth.googleLoginError;
      });
    }

    if (!mounted) return;
    if (user != null && mounted) {
      await UserSyncService.syncFirebaseUser(user.user!);
      final fbUser = user.user!;
      final needsSetup = await UserSyncService.needsProfileSetup(fbUser);
      if (!mounted) return;
      if (needsSetup) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WidgetTree()),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WidgetTree()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Log In",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your  Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFF858597),
                ),
              ),
              TextField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'example@gmail.com',
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF858597),
                  ),
                ),
              ),
              TextField(
                obscureText: _obscurePassword,
                controller: _controllerPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '************',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    SelectableText(
                      errorMessage == "" ? "" : "$errorMessage",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3D5CFF),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 51),
                  ),
                  onPressed: signInWithEmailAndPassword,
                  child: Text(
                    "Log In",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("Forgot password?"),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3D5CFF)),
                  ),
                  onPressed: loginWithGoogle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/Google.png',
                        width: 40,
                        height: 40,
                      ),
                      Text(
                        "Sign in with google",
                        style: TextStyle(color: Color(0xFF3D5CFF)),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: OutlinedButton(
                        onPressed: () => {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          ),
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3D5CFF)),
                        ),
                        child: Text(
                          "Create new account",
                          style: TextStyle(color: Color(0xFF3D5CFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

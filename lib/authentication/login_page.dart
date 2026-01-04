import 'package:et_learn/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:et_learn/authentication/signup_page.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final Auth auth = Auth();
  String? errorMessage = "";

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: "EtLearn"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: "EtLearn"),
        ),
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
                  hintText: 'DaniKebede@gmail.com',
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
                obscureText: true,
                controller: _controllerPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '............',
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
                          Navigator.push(
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

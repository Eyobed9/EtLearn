import 'package:et_learn/authentication/login_page.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? errorMessage = "";

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerConfirmPassword.text == _controllerPassword.text) {
      try {
        await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
      }
    } else {
      setState(() {
        errorMessage = "Passwords doesn't match";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign up",
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
                "Full name",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFF858597),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Daniel Kebede',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Your  Email",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF858597),
                  ),
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
                child: Text(
                  "Confirm password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF858597),
                  ),
                ),
              ),
              TextField(
                obscureText: true,
                controller: _controllerConfirmPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '............',
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    errorMessage == "" ? "" : "$errorMessage",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
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
                  onPressed: createUserWithEmailAndPassword,
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

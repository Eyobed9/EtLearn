import 'package:et_learn/authentication/login_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  void initState() {
    super.initState();

    _navigateToOnboarding2();
  }

  void _navigateToOnboarding2() {
    Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/onboarding1.png",
                    width: 260,
                    height: 260,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Learn from your peer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F1F39),
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      'Get video aided learning for free from your peer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF858597),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/pavigation.png",
                    width: 66,
                    height: 5,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 16.0),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF858597),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

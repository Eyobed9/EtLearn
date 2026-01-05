import 'package:et_learn/onboarding/onboarding1.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Modal extends StatefulWidget {
  const Modal({super.key, required this.title});

  final String title;

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  @override
  void initState() {
    super.initState();

    _navigateToLoginPage();
  }

  void _navigateToLoginPage() {
    Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding1()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Image.asset(
                "assets/images/EtLearn.png",
                width: 400,
                height: 165,
              ),
            ),
            Text(
              "Learn, Teach, Grow",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

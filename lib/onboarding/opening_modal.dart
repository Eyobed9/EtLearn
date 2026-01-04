import 'package:et_learn/authentication/login_page.dart';
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
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 85,
                top: 314,
                child: SizedBox(
                  width: 327,
                  height: 110,
                  child: Text(
                    'EtLearn',
                    style: TextStyle(
                      color: const Color(0xFF09174B),
                      fontSize: 64,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.56,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 143.37,
                top: 257.68,
                child: Container(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(0.19),
                  width: 51.49,
                  height: 48.13,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Stack(),
                ),
              ),
              Positioned(
                left: 62,
                top: 450,
                child: SizedBox(
                  width: 258,
                  height: 66,
                  child: Text(
                    'Learn, Teach, Grow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1F1F39),
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
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

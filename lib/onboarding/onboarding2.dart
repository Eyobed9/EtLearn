import 'package:flutter/material.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/onboarding2.png", width: 260, height: 260),
          const SizedBox(height: 20),
          const Text(
            'Teach what you know',
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
            width: 260,
            child: Text(
              'Share your knowledge to your peer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF858597),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

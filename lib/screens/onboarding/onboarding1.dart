import 'package:flutter/material.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/onboarding1.png", width: 260, height: 260),
          Padding(padding: const EdgeInsets.only(top: 20), child: Container()),
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
          Padding(padding: const EdgeInsets.only(top: 20), child: Container()),
          const SizedBox(
            width: 260,
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
        ],
      ),
    );
  }
}

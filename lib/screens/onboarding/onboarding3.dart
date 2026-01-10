import 'package:et_learn/authentication/login_page.dart';
import 'package:et_learn/authentication/signup_page.dart';
import 'package:flutter/material.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/images/onboarding3.png", width: 260, height: 260),
        Padding(padding: const EdgeInsets.only(top: 20), child: Container()),
        const Text(
          'Earn credits',
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
            'Earn credits for teaching and  use it to learn',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF858597),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: 36), child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5CFF),
                    minimumSize: const Size(160, 50),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(),
              ),

              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3D5CFF)),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(160, 50),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Color(0xFF3D5CFF),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

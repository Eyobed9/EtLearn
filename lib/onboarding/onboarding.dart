import 'package:flutter/material.dart';
import 'package:et_learn/onboarding/onboarding1.dart';
import 'package:et_learn/onboarding/onboarding2.dart';
import 'package:et_learn/onboarding/onboarding3.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _current = 0;

  void _jumpToLast() {
    _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _current = i),
              children: const [Onboarding1(), Onboarding2(), Onboarding3()],
            ),

            // Skip button (top-right)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 20.0),
                child: TextButton(
                  onPressed: _jumpToLast,
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
            ),

            // Pagination dots (bottom-center)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final bool active = index == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: active ? 14 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF3D5CFF)
                            : const Color(0xFFDFE3FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

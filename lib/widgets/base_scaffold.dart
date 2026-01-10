import 'package:flutter/material.dart';
import 'package:et_learn/widgets/credits_streak_appbar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;

  const BaseScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.backgroundColor = const Color(0xFFF4F8FE),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CreditsStreakAppBar(title: title),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

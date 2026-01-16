import 'package:flutter/material.dart';
import 'package:et_learn/widgets/credits_streak_appbar.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color backgroundColor;
  final bool padForFab;

  const BaseScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor = const Color(0xFFF4F8FE),
    this.padForFab = true,
  });

  @override
  Widget build(BuildContext context) {
    final shouldPadForFab = floatingActionButton != null && padForFab;
    final paddedBody = shouldPadForFab
        ? Padding(padding: const EdgeInsets.only(bottom: 100), child: body)
        : body;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CreditsStreakAppBar(title: title),
      body: paddedBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

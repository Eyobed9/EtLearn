import 'package:flutter/material.dart';
import "package:et_learn/authentication/auth.dart";
// import "package:facebook/authentication/login_page.dart";
import "package:et_learn/my_home_page.dart";
import "package:et_learn/onboarding/opening_modal.dart";

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHomePage(title: "Facebook");
        } else {
          return const Modal(title: "Facebook");
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:et_learn/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Firebase Auth
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🧠 Supabase Database
  await Supabase.initialize(
    url: 'https://mszcexipijoxiaglcobi.supabase.co',
    anonKey: 'sb_publishable_oTnqfNixY_dC-mQpC6qdBg_q2xgY9hT',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EtLearn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 59, 89, 152),
        ),
      ),
      home: WidgetTree(),
    );
  }
}

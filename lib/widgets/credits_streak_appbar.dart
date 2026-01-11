import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:et_learn/helpers/credits.dart';

class CreditsStreakAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final Widget? title;

  const CreditsStreakAppBar({super.key, this.title});

  @override
  State<CreditsStreakAppBar> createState() => _CreditsStreakAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CreditsStreakAppBarState extends State<CreditsStreakAppBar> {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> _fetchStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final res = await _supabase
        .from('users')
        .select('credits, streak')
        .eq('uid', user.uid)
        .maybeSingle();

    if (res == null) return null;
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.title ?? const Text('EtLearn'),
      actions: [
        FutureBuilder<Map<String, dynamic>?>(
          future: _fetchStats(),
          builder: (context, snapshot) {
            final streak = snapshot.data?['streak'] ?? 0;

            return ValueListenableBuilder<int>(
              valueListenable: totalCreditsNotifier,
              builder: (context, credits, _) {
                return Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(streak.toString()),
                    const SizedBox(width: 16),
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(credits.toString()),
                    const SizedBox(width: 12),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

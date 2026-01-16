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

  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _updateStreak();
  }

  Future<void> _updateStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final res = await _supabase
        .from('users')
        .select('credits, streak, last_active')
        .eq('uid', user.uid)
        .maybeSingle();

    if (res == null) return;

    final Map<String, dynamic> userData = Map<String, dynamic>.from(res);

    // ✅ Safely parse streak and last_active
    int streak = (userData['streak'] ?? 0) is int
        ? userData['streak'] as int
        : int.tryParse(userData['streak'].toString()) ?? 0;

    DateTime? lastActive;
    if (userData['last_active'] != null) {
      try {
        lastActive = DateTime.parse(userData['last_active'].toString());
      } catch (_) {
        lastActive = null;
      }
    }

    final today = DateTime.now().toUtc();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (lastActive != null) {
      final lastDate = DateTime(
        lastActive.year,
        lastActive.month,
        lastActive.day,
      );
      final difference = todayDateOnly.difference(lastDate).inDays;

      if (difference == 1) {
        // Consecutive day login
        streak += 1;
      } else if (difference > 1) {
        // Missed a day → reset streak
        streak = 1;
      }
      // difference == 0 → already logged in today, keep streak
    } else {
      // First login
      streak = 1;
    }

    setState(() => _streak = streak);

    // Update Supabase safely
    await _supabase
        .from('users')
        .update({
          'streak': streak,
          'last_active': todayDateOnly.toIso8601String().split('T').first,
        })
        .eq('uid', user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.title ?? const Text('EtLearn'),
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: totalCreditsNotifier,
          builder: (context, credits, _) {
            return Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 6),
                Text(_streak.toString()),
                const SizedBox(width: 16),
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 6),
                Text(credits.toString()),
                const SizedBox(width: 12),
              ],
            );
          },
        ),
      ],
    );
  }
}

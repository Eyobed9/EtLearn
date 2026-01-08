import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

final supabase = Supabase.instance.client;

class UserSyncService {
  static Future<void> syncFirebaseUser(fb.User user) async {
    await supabase.from('users').upsert({
      'id': user.uid,
      'email': user.email,
      'full_name': user.displayName ?? 'New User',
      'credits': 0,
      'streak': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

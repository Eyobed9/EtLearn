import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

final supabase = Supabase.instance.client;

class UserSyncService {
  static Future<void> syncFirebaseUser(fb.User user) async {
    await supabase.from('users').upsert({
      'uid': user.uid,
      'email': user.email,
      'full_name': user.displayName ?? 'New User',
      'credits': 0,
      'streak': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Returns true when the user's profile appears incomplete and they
  /// should be sent to the setup flow.
  static Future<bool> needsProfileSetup(fb.User user) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('uid', user.uid)
          .maybeSingle();

      if (response == null) return true;

      // response is dynamic (Map) - check key fields that indicate completion
      final fullName = response['full_name'];
      final photo = response['photo_url'];
      final bio = response['bio'];

      if (fullName == null || fullName == 'New User') return true;
      if (photo == null) return true;
      if (bio == null) return true;

      return false;
    } catch (_) {
      return true;
    }
  }
}

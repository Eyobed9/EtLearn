import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:flutter/foundation.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? googleLoginError;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      googleLoginError = null;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? "345964728818-202le5m3tu6nj02krfbd5q3usqb9goh2.apps.googleusercontent.com"
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        googleLoginError = "Login cancelled by user";
        return null;
      } // User canceled login
      final googleAuth = await googleUser.authentication;
      final OAuthCredential cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      return await _firebaseAuth.signInWithCredential(cred);
    } catch (e) {
      googleLoginError = e.toString();
      return null;
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

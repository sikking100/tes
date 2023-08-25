import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static final Auth instance = Auth._();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  factory Auth() => instance;

  Auth._();

  String? get id => _firebaseAuth.currentUser?.uid;
  String? get userName => _firebaseAuth.currentUser?.displayName;

  Future<String> signInWithCustomToken(String token) async {
    try {
      final result = await _firebaseAuth.signInWithCustomToken(token);
      return result.user!.uid;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();
}

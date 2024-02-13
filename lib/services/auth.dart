import 'package:firebase_auth/firebase_auth.dart';

abstract class Authentication {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User?> getCurrentUser();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
}

class AuthService implements Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      // Handle sign-in errors
      return Future.error(e.toString());
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      // Handle sign-up errors
      return Future.error(e.toString());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    await user!.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    User? user = _firebaseAuth.currentUser;
    return user!.emailVerified;
  }
}

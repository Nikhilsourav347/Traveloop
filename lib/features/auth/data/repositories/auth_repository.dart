import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../../../../core/services/local_storage_service.dart';

/// Firebase Auth repository.
/// Authentication is handled by Firebase.
/// User profile extras (name, photo) are cached in Hive locally.
class AuthRepository implements IAuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  // ─── authStateChanges ────────────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return _toEntity(fbUser);
    });
  }

  // ─── Sign In ─────────────────────────────────────────────────
  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final entity = _toEntity(credential.user!);
      _cacheUser(entity);
      return entity;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  // ─── Sign In with Google ─────────────────────────────────────
  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // We use the Web Client ID for Android/iOS Google Sign-in Firebase integration
        serverClientId: '278960721253-vfvcb0uqq0nq00tdtag3rf0k3jd07vu0.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was aborted.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final entity = _toEntity(userCredential.user!);
      _cacheUser(entity);
      return entity;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // ─── Sign Up ─────────────────────────────────────────────────
  @override
  Future<UserEntity> signUpWithEmail(
      String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Set display name
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      final entity = _toEntity(_firebaseAuth.currentUser!, overrideName: name);
      _cacheUser(entity);
      return entity;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
    localStorageService.clearUser();
  }

  // ─── Reset Password ──────────────────────────────────────────
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────
  UserEntity _toEntity(fb.User fbUser, {String? overrideName}) {
    return UserEntity(
      id: fbUser.uid,
      name: overrideName ?? fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Traveler',
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL,
    );
  }

  void _cacheUser(UserEntity entity) {
    localStorageService.saveUser(entity.toMap());
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      default:
        return 'Authentication failed. Please try again. ($code)';
    }
  }
}

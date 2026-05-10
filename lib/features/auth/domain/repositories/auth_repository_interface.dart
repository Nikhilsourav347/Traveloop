import '../../domain/entities/user.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String name, String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

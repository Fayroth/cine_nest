// lib/data/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Sign in anonymously
  Future<Either<Failure, User>> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Sign out
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Reset password
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Delete account
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await currentUser?.delete();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Update profile
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }

      if (displayName != null) {
        await currentUser!.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Update email
  Future<Either<Failure, void>> updateEmail(String newEmail) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Update password
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _getErrorMessage(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      // Sign-in errors — 'invalid-credential' is the unified code in Firebase SDK 5+
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      // Sign-up errors
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      // Anonymous sign-in — must be enabled in Firebase Console
      case 'operation-not-allowed':
        return 'Guest login is not enabled. Please contact support.';
      // Network errors
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      // Re-auth errors
      case 'requires-recent-login':
        return 'Please sign out and sign in again to do this.';
      default:
        // Always show the raw code so unknown errors are always visible
        return 'Authentication error ($code). Please try again.';
    }
  }
}
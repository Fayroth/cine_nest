// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/firebase_auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/models/user_profile.dart';
import '../core/di/injection_container.dart';

// Auth service provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return sl<FirebaseAuthService>();
});

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return sl<FirestoreService>();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

// User profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final firestoreService = ref.watch(firestoreServiceProvider);
  final result = await firestoreService.getUserProfile(user.uid);

  return result.fold(
        (failure) => null,
        (profile) => profile,
  );
});

// Auth state notifier for managing auth operations
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(firestoreServiceProvider),
  ),
);

// Auth state
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    bool clearUser = false,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthNotifier(this._authService, this._firestoreService)
      : super(AuthState(user: _authService.currentUser));

  void _logError(String operation, String message) {
    // Always visible in the debug console for easier diagnosis
    assert(() {
      // ignore: avoid_print
      print('[AuthNotifier] $operation failed: $message');
      return true;
    }());
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      (failure) {
        _logError('signUp', '${failure.code} — ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) async {
        await _firestoreService.createUserProfile(
          userId: user.uid,
          email: email,
          displayName: displayName,
        );
        state = state.copyWith(isLoading: false, user: user, error: null);
        return true;
      },
    );
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _logError('signIn', '${failure.code} — ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user, error: null);
        return true;
      },
    );
  }

  // Sign in anonymously
  Future<bool> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signInAnonymously();

    return result.fold(
      (failure) {
        _logError('signInAnonymously', '${failure.code} — ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) async {
        await _firestoreService.createUserProfile(
          userId: user.uid,
          email: 'anonymous@cinenest.app',
          displayName: 'Guest User',
        );
        state = state.copyWith(isLoading: false, user: user, error: null);
        return true;
      },
    );
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    await _authService.signOut();

    state = const AuthState(isLoading: false);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.resetPassword(email);

    return result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
          (_) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      },
    );
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    return result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
          (_) async {
        // Update Firestore profile
        if (_authService.currentUser != null) {
          await _firestoreService.updateUserProfile(
            userId: _authService.currentUser!.uid,
            displayName: displayName,
            photoUrl: photoURL,
          );
        }

        state = state.copyWith(
          isLoading: false,
          user: _authService.currentUser,
          error: null,
        );
        return true;
      },
    );
  }

  // Delete account
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    if (_authService.currentUser == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'No user logged in',
      );
      return false;
    }

    // Delete user data from Firestore first
    await _firestoreService.deleteAllUserData(_authService.currentUser!.uid);

    // Then delete the auth account
    final result = await _authService.deleteAccount();

    return result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
          (_) {
        state = const AuthState(isLoading: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
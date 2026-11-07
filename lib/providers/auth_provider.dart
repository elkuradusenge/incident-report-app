import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/auth_error_messages.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Holds the session state that screens and [AuthGate] render from.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AppUser? _currentUser;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSignedIn = false;
  bool _isEmailVerified = false;
  String? _email;
  String? _errorMessage;
  bool _isDisposed = false;

  /// Profile document of the signed-in, verified user.
  AppUser? get currentUser => _currentUser;

  /// True while the session is being restored or the profile is loading.
  bool get isLoading => _isLoading;

  /// True while a form action (sign in, register, resend) is running.
  bool get isSubmitting => _isSubmitting;

  bool get isSignedIn => _isSignedIn;
  bool get isEmailVerified => _isEmailVerified;
  bool get isStaff => _currentUser?.role == UserRole.staff;

  /// Email of the signed-in account, shown on the verification screen.
  String? get email => _email;
  String? get errorMessage => _errorMessage;

  Future<void> _onAuthStateChanged(User? user) async {
    _email = user?.email;
    _isSignedIn = user != null;
    _isEmailVerified = user?.emailVerified ?? false;
    _errorMessage = null;

    if (user == null) {
      _currentUser = null;
      _isLoading = false;
      _notify();
      return;
    }
    if (!user.emailVerified) {
      _currentUser = null;
      _isLoading = false;
      _notify();
      return;
    }

    await _loadProfile(user.uid);
  }

  Future<void> _loadProfile(String uid) async {
    _isLoading = true;
    _notify();
    try {
      final AppUser? profile = await _authService.fetchUserProfile(uid);
      _currentUser = profile;
      if (profile == null) {
        _errorMessage = 'We could not find your profile. Please contact an administrator.';
      }
    } catch (error) {
      _currentUser = null;
      _errorMessage = authErrorMessage(error);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _notify();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (error) {
      _errorMessage = authErrorMessage(error);
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _notify();
    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = authErrorMessage(error);
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<bool> resendVerificationEmail() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _notify();
    try {
      await _authService.sendVerificationEmail();
      return true;
    } catch (error) {
      _errorMessage = authErrorMessage(error);
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  /// Used by the "I have verified" button. Returns false while the account is
  /// still unverified.
  Future<bool> refreshEmailVerification() async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    _notify();
    try {
      final bool verified = await _authService.reloadEmailVerification();
      _isEmailVerified = verified;

      final User? user = _authService.currentUser;
      if (verified && user != null) {
        await _loadProfile(user.uid);
        return true;
      }
      return false;
    } catch (error) {
      _errorMessage = authErrorMessage(error);
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  /// Re-fetches the profile document, e.g. after an administrator sets the role.
  Future<void> reloadProfile() async {
    final User? user = _authService.currentUser;
    if (user == null) return;

    await _loadProfile(user.uid);
  }

  Future<void> signOut() async {
    _errorMessage = null;
    try {
      await _authService.signOut();
    } catch (error) {
      _errorMessage = authErrorMessage(error);
      _notify();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}

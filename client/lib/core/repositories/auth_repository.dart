import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      await SupabaseService.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.jeong://login-callback/',
      );
      return _getCurrentAppUser();
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  // Sign in with Apple
  Future<AppUser?> signInWithApple() async {
    try {
      await SupabaseService.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.jeong://login-callback/',
      );
      return _getCurrentAppUser();
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return null;
    }
  }

  // Sign in with Email
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _getCurrentAppUser();
    } catch (e) {
      debugPrint('Email sign-in error: $e');
      return null;
    }
  }

  // Sign up with Email
  Future<AppUser?> signUpWithEmail(
      String email, String password, String displayName) async {
    try {
      await SupabaseService.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': displayName},
      );
      return _getCurrentAppUser();
    } catch (e) {
      debugPrint('Email sign-up error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }

  // Get current user
  AppUser? _getCurrentAppUser() {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.id,
      displayName: user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          'Jeong User',
      email: user.email,
      profileImageUrl: user.userMetadata?['avatar_url'],
      status: AuthStatus.authenticated,
      provider: _mapProvider(user.appMetadata['provider']),
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  AuthProvider? _mapProvider(String? provider) {
    return switch (provider) {
      'google' => AuthProvider.google,
      'apple' => AuthProvider.apple,
      'email' => AuthProvider.email,
      _ => null,
    };
  }

  // Update profile
  Future<void> updateProfile({
    String? displayName,
    String? nationality,
    String? nationalityFlag,
    String? preferredLanguage,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (nationality != null) updates['nationality'] = nationality;
    if (nationalityFlag != null) updates['nationality_flag'] = nationalityFlag;
    if (preferredLanguage != null) {
      updates['preferred_language'] = preferredLanguage;
    }

    if (updates.isNotEmpty) {
      await SupabaseService.profiles().update(updates).eq('id', userId);
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      SupabaseService.auth.onAuthStateChange;
}

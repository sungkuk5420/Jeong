import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/bookmark_repository.dart';
import '../services/supabase_service.dart';
import 'repository_providers.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AppUser>((ref) {
  return AuthNotifier(
    authRepo: ref.watch(authRepositoryProvider),
    bookmarkRepo: ref.watch(bookmarkRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AppUser> {
  AuthNotifier({
    required this.authRepo,
    required this.bookmarkRepo,
  }) : super(const AppUser()) {
    _checkCurrentSession();
  }

  final AuthRepository authRepo;
  final BookmarkRepository bookmarkRepo;

  // Check if user has an existing session
  Future<void> _checkCurrentSession() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      state = AppUser(
        id: user.id,
        displayName: user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            'Jeong User',
        email: user.email,
        profileImageUrl: user.userMetadata?['avatar_url'],
        status: AuthStatus.authenticated,
        createdAt: DateTime.tryParse(user.createdAt),
      );
      await _loadBookmarks();
    }
  }

  Future<void> signInWithGoogle() async {
    final user = await authRepo.signInWithGoogle();
    if (user != null) {
      state = user;
      await _loadBookmarks();
    } else {
      // Fallback to mock for development
      state = AppUser(
        id: 'user_001',
        displayName: 'Sarah Kim',
        email: 'sarah@example.com',
        nationality: '🇺🇸',
        status: AuthStatus.authenticated,
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> signInWithApple() async {
    final user = await authRepo.signInWithApple();
    if (user != null) {
      state = user;
      await _loadBookmarks();
    } else {
      state = AppUser(
        id: 'user_002',
        displayName: 'Apple User',
        email: 'apple@example.com',
        status: AuthStatus.authenticated,
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
      );
    }
  }

  void signInAsGuest() {
    state = const AppUser();
  }

  Future<void> signOut() async {
    try {
      await authRepo.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
    state = const AppUser();
  }

  Future<void> toggleBookmark(String placeId) async {
    final bookmarks = List<String>.from(state.bookmarkedPlaceIds);
    if (bookmarks.contains(placeId)) {
      bookmarks.remove(placeId);
      await bookmarkRepo.removeBookmark(placeId);
    } else {
      bookmarks.add(placeId);
      await bookmarkRepo.addBookmark(placeId);
    }
    state = state.copyWith(bookmarkedPlaceIds: bookmarks);
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await bookmarkRepo.getBookmarkedPlaceIds();
    state = state.copyWith(bookmarkedPlaceIds: bookmarks);
  }
}

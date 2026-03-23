import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';

class BookmarkRepository {
  // Get all bookmarked place IDs
  Future<List<String>> getBookmarkedPlaceIds() async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return [];

      final response = await SupabaseService.bookmarks()
          .select('place_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => row['place_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
      return [];
    }
  }

  // Add bookmark
  Future<bool> addBookmark(String placeId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      await SupabaseService.bookmarks().insert({
        'user_id': userId,
        'place_id': placeId,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      return false;
    }
  }

  // Remove bookmark
  Future<bool> removeBookmark(String placeId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      await SupabaseService.bookmarks()
          .delete()
          .eq('user_id', userId)
          .eq('place_id', placeId);
      return true;
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      return false;
    }
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(String placeId) async {
    final bookmarks = await getBookmarkedPlaceIds();
    if (bookmarks.contains(placeId)) {
      return removeBookmark(placeId);
    } else {
      return addBookmark(placeId);
    }
  }

  // Check if place is bookmarked
  Future<bool> isBookmarked(String placeId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      final response = await SupabaseService.bookmarks()
          .select()
          .eq('user_id', userId)
          .eq('place_id', placeId);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

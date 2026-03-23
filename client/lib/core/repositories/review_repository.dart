import 'package:flutter/foundation.dart';

import '../../shared/widgets/review_source_badge.dart';
import '../models/review.dart';
import '../services/supabase_service.dart';

class ReviewRepository {
  // Fetch reviews for a place
  Future<List<Review>> getReviewsForPlace(
    String placeId, {
    String? source, // 'jeong', 'naver', 'google', or null for all
    String orderBy = 'created_at',
    bool ascending = false,
    int limit = 50,
  }) async {
    try {
      var query = SupabaseService.reviews()
          .select()
          .eq('place_id', placeId);

      if (source != null) {
        if (source == 'external') {
          query = query.neq('source', 'jeong');
        } else {
          query = query.eq('source', source);
        }
      }

      final response = await query
          .order(orderBy, ascending: ascending)
          .limit(limit);

      return (response as List).map((json) => _reviewFromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  // Create a review
  Future<Review?> createReview({
    required String placeId,
    required double rating,
    required String content,
    List<String> photoUrls = const [],
  }) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return null;

      // Get user profile
      final profile = await SupabaseService.profiles()
          .select('display_name, nationality_flag')
          .eq('id', userId)
          .single();

      final response = await SupabaseService.reviews()
          .insert({
            'place_id': placeId,
            'source': 'jeong',
            'author_id': userId,
            'author_name': '@${profile['display_name']}',
            'nationality_flag': profile['nationality_flag'],
            'rating': rating,
            'content': content,
            'photo_urls': photoUrls,
          })
          .select()
          .single();

      return _reviewFromJson(response);
    } catch (e) {
      debugPrint('Error creating review: $e');
      return null;
    }
  }

  // Like a review
  Future<bool> likeReview(String reviewId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      await SupabaseService.reviewLikes().insert({
        'user_id': userId,
        'review_id': reviewId,
      });
      return true;
    } catch (e) {
      debugPrint('Error liking review: $e');
      return false;
    }
  }

  // Unlike a review
  Future<bool> unlikeReview(String reviewId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      await SupabaseService.reviewLikes()
          .delete()
          .eq('user_id', userId)
          .eq('review_id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error unliking review: $e');
      return false;
    }
  }

  // Check if user liked a review
  Future<bool> hasLiked(String reviewId) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return false;

      final response = await SupabaseService.reviewLikes()
          .select()
          .eq('user_id', userId)
          .eq('review_id', reviewId);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Delete own review
  Future<bool> deleteReview(String reviewId) async {
    try {
      await SupabaseService.reviews().delete().eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  Review _reviewFromJson(Map<String, dynamic> json) {
    final photoUrls = List<String>.from(json['photo_urls'] ?? []);
    return Review(
      id: json['id'],
      placeId: json['place_id'],
      source: _mapSource(json['source']),
      authorName: json['author_name'],
      nationality: json['nationality_flag'],
      rating: (json['rating'] as num).toDouble(),
      date: _formatDate(json['created_at']),
      content: json['content'],
      translatedContent: json['translated_content'],
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      hasPhotos: photoUrls.isNotEmpty,
      photoUrls: photoUrls,
    );
  }

  ReviewSourceType _mapSource(String source) {
    return switch (source) {
      'jeong' => ReviewSourceType.jeong,
      'naver' => ReviewSourceType.naver,
      'google' => ReviewSourceType.google,
      _ => ReviewSourceType.jeong,
    };
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

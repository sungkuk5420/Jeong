import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/review_source_badge.dart';
import '../models/mock_data.dart';
import '../models/review.dart';

import 'repository_providers.dart';

// ─── Toggle: set to true when Supabase is connected ───
const _useSupabase = false;

// All reviews for a place
final reviewsForPlaceProvider =
    FutureProvider.family<List<Review>, String>((ref, placeId) async {
  if (_useSupabase) {
    final repo = ref.watch(reviewRepositoryProvider);
    return repo.getReviewsForPlace(placeId);
  }
  return getReviewsForPlace(placeId);
});

// Jeong reviews only
final jeongReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, placeId) async {
  if (_useSupabase) {
    final repo = ref.watch(reviewRepositoryProvider);
    return repo.getReviewsForPlace(placeId, source: 'jeong');
  }
  return getReviewsForPlace(placeId)
      .where((r) => r.source == ReviewSourceType.jeong)
      .toList();
});

// External reviews only
final externalReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, placeId) async {
  if (_useSupabase) {
    final repo = ref.watch(reviewRepositoryProvider);
    return repo.getReviewsForPlace(placeId, source: 'external');
  }
  return getReviewsForPlace(placeId)
      .where((r) => r.source != ReviewSourceType.jeong)
      .toList();
});

// Review sort option
enum ReviewSort { latest, highest, mostHelpful }

final reviewSortProvider =
    StateProvider<ReviewSort>((ref) => ReviewSort.latest);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mock_data.dart';
import '../models/place.dart';

import 'auth_provider.dart';
import 'repository_providers.dart';

// ─── Toggle: set to true when Supabase is connected ───
const _useSupabase = false;

// All places
final placesProvider = FutureProvider<List<Place>>((ref) async {
  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    return repo.getPlaces();
  }
  return allMockPlaces;
});

// Official places only
final officialPlacesProvider = FutureProvider<List<Place>>((ref) async {
  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    return repo.getOfficialPlaces();
  }
  return mockOfficialPlaces;
});

// Community places only
final communityPlacesProvider = FutureProvider<List<Place>>((ref) async {
  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    return repo.getCommunityPlaces();
  }
  return mockCommunityPlaces;
});

// Single place by ID
final placeByIdProvider =
    FutureProvider.family<Place?, String>((ref, id) async {
  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    return repo.getPlaceById(id);
  }
  final places = allMockPlaces;
  try {
    return places.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

// Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered places based on category + search
final filteredPlacesProvider = FutureProvider<List<Place>>((ref) async {
  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    return repo.getPlaces(category: category, searchQuery: query);
  }

  final places = allMockPlaces;
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  var filtered = places;

  if (category != null) {
    filtered = filtered.where((p) => p.category == category).toList();
  }

  if (query.isNotEmpty) {
    filtered = filtered
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.district.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false) ||
            p.tags.any((t) => t.toLowerCase().contains(query)))
        .toList();
  }

  return filtered;
});

// Bookmarked places
final bookmarkedPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final user = ref.watch(authProvider);
  if (user.isGuest) return [];

  if (_useSupabase) {
    final repo = ref.watch(placeRepositoryProvider);
    final places = <Place>[];
    for (final id in user.bookmarkedPlaceIds) {
      final place = await repo.getPlaceById(id);
      if (place != null) places.add(place);
    }
    return places;
  }

  final allPlaces = allMockPlaces;
  return allPlaces
      .where((p) => user.bookmarkedPlaceIds.contains(p.id))
      .toList();
});

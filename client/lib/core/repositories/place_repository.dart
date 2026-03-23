import 'package:flutter/foundation.dart';

import '../../shared/widgets/source_badge.dart';
import '../models/place.dart';
import '../services/supabase_service.dart';

class PlaceRepository {
  // Fetch all places (with optional filters)
  Future<List<Place>> getPlaces({
    String? category,
    String? district,
    String? sourceType,
    String? searchQuery,
    String orderBy = 'avg_rating',
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseService.places().select('''
        *,
        foreigner_tips (id, icon, text)
      ''');

      if (category != null) {
        query = query.eq('category', category);
      }
      if (district != null) {
        query = query.eq('district', district);
      }
      if (sourceType != null) {
        query = query.eq('source_type', sourceType);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,description.ilike.%$searchQuery%,district.ilike.%$searchQuery%',
        );
      }

      final response = await query
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => _placeFromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching places: $e');
      return [];
    }
  }

  // Fetch official places
  Future<List<Place>> getOfficialPlaces({int limit = 20}) async {
    return getPlaces(sourceType: 'official', limit: limit);
  }

  // Fetch community places
  Future<List<Place>> getCommunityPlaces({int limit = 20}) async {
    return getPlaces(sourceType: 'community', limit: limit);
  }

  // Fetch single place by ID
  Future<Place?> getPlaceById(String id) async {
    try {
      final response = await SupabaseService.places()
          .select('''
            *,
            foreigner_tips (id, icon, text)
          ''')
          .eq('id', id)
          .single();

      return _placeFromJson(response);
    } catch (e) {
      debugPrint('Error fetching place: $e');
      return null;
    }
  }

  // Search places
  Future<List<Place>> searchPlaces(String query) async {
    return getPlaces(searchQuery: query);
  }

  // Register a community place
  Future<Place?> registerPlace({
    required String name,
    required String category,
    required String district,
    String? address,
    String? phone,
    String? openingHours,
    String? description,
    double? latitude,
    double? longitude,
    List<String> tags = const [],
  }) async {
    try {
      final userId = SupabaseService.userId;
      if (userId == null) return null;

      // Get user profile for registered_by_name
      final profile = await SupabaseService.profiles()
          .select('display_name')
          .eq('id', userId)
          .single();

      final response = await SupabaseService.places()
          .insert({
            'name': name,
            'category': category,
            'district': district,
            'address': address,
            'phone': phone,
            'opening_hours': openingHours,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            'source_type': 'community',
            'tags': tags,
            'registered_by': userId,
            'registered_by_name': '@${profile['display_name']}',
          })
          .select('''
            *,
            foreigner_tips (id, icon, text)
          ''')
          .single();

      return _placeFromJson(response);
    } catch (e) {
      debugPrint('Error registering place: $e');
      return null;
    }
  }

  // Convert JSON to Place model
  Place _placeFromJson(Map<String, dynamic> json) {
    final tips = (json['foreigner_tips'] as List?)
            ?.map((t) => ForeignerTip(
                  icon: t['icon'] ?? 'info',
                  text: t['text'] ?? '',
                ))
            .toList() ??
        [];

    return Place(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      district: json['district'],
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      jeongRating: (json['jeong_rating'] as num?)?.toDouble(),
      externalRating: (json['external_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      jeongReviewCount: json['jeong_review_count'] ?? 0,
      externalReviewCount: json['external_review_count'] ?? 0,
      sourceType: json['source_type'] == 'community'
          ? SourceType.community
          : SourceType.official,
      imageUrl: json['image_url'],
      description: json['description'],
      registeredBy: json['registered_by_name'],
      address: json['address'],
      phone: json['phone'],
      openingHours: json['opening_hours'],
      tags: List<String>.from(json['tags'] ?? []),
      tips: tips,
    );
  }
}

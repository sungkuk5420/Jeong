import '../../shared/widgets/source_badge.dart';

class Place {
  final String id;
  final String name;
  final String category;
  final String district;
  final double rating;
  final double? jeongRating;
  final double? externalRating;
  final int reviewCount;
  final int jeongReviewCount;
  final int externalReviewCount;
  final SourceType sourceType;
  final String? imageUrl;
  final String? distance;
  final String? description;
  final String? registeredBy;
  final String? address;
  final String? phone;
  final String? openingHours;
  final bool isBookmarked;
  final List<String> tags;
  final List<ForeignerTip> tips;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.district,
    required this.rating,
    this.jeongRating,
    this.externalRating,
    required this.reviewCount,
    this.jeongReviewCount = 0,
    this.externalReviewCount = 0,
    required this.sourceType,
    this.imageUrl,
    this.distance,
    this.description,
    this.registeredBy,
    this.address,
    this.phone,
    this.openingHours,
    this.isBookmarked = false,
    this.tags = const [],
    this.tips = const [],
  });

  Place copyWith({
    String? id,
    String? name,
    String? category,
    String? district,
    double? rating,
    double? jeongRating,
    double? externalRating,
    int? reviewCount,
    int? jeongReviewCount,
    int? externalReviewCount,
    SourceType? sourceType,
    String? imageUrl,
    String? distance,
    String? description,
    String? registeredBy,
    String? address,
    String? phone,
    String? openingHours,
    bool? isBookmarked,
    List<String>? tags,
    List<ForeignerTip>? tips,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      district: district ?? this.district,
      rating: rating ?? this.rating,
      jeongRating: jeongRating ?? this.jeongRating,
      externalRating: externalRating ?? this.externalRating,
      reviewCount: reviewCount ?? this.reviewCount,
      jeongReviewCount: jeongReviewCount ?? this.jeongReviewCount,
      externalReviewCount: externalReviewCount ?? this.externalReviewCount,
      sourceType: sourceType ?? this.sourceType,
      imageUrl: imageUrl ?? this.imageUrl,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      registeredBy: registeredBy ?? this.registeredBy,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      tips: tips ?? this.tips,
    );
  }
}

class ForeignerTip {
  final String icon;
  final String text;

  const ForeignerTip({required this.icon, required this.text});
}

enum PlaceCategory {
  food('Food', 'restaurant_rounded'),
  cafe('Cafe', 'coffee_rounded'),
  attraction('Attractions', 'photo_camera_rounded'),
  bar('Bars', 'local_bar_rounded'),
  shopping('Shopping', 'shopping_bag_rounded'),
  culture('Culture', 'museum_rounded');

  final String label;
  final String iconName;
  const PlaceCategory(this.label, this.iconName);
}

import '../../shared/widgets/review_source_badge.dart';

class Review {
  final String id;
  final String placeId;
  final ReviewSourceType source;
  final String authorName;
  final String? nationality;
  final double rating;
  final String date;
  final String content;
  final String? translatedContent;
  final int likes;
  final int comments;
  final bool hasPhotos;
  final List<String> photoUrls;

  const Review({
    required this.id,
    required this.placeId,
    required this.source,
    required this.authorName,
    this.nationality,
    required this.rating,
    required this.date,
    required this.content,
    this.translatedContent,
    this.likes = 0,
    this.comments = 0,
    this.hasPhotos = false,
    this.photoUrls = const [],
  });

  bool get isExternal => source != ReviewSourceType.jeong;
  bool get hasTranslation => translatedContent != null;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/bookmark_repository.dart';
import '../repositories/place_repository.dart';
import '../repositories/review_repository.dart';

// Repository singletons
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

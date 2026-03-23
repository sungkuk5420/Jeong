import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/translation_service.dart';

// Singleton TranslationService (memory cache + DB cache + Azure API)
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

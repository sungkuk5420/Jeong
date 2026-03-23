import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'supabase_service.dart';

class TranslationService {
  // In-memory cache (session-level, avoids even DB lookups)
  final Map<String, String> _memCache = {};

  String _cacheKey(String reviewId, String lang) => '${reviewId}_$lang';

  /// 번역 요청 흐름:
  /// 1) 메모리 캐시 확인
  /// 2) Supabase translations 테이블 확인
  /// 3) Azure API 호출 → Supabase에 저장 → 메모리 캐시에 저장
  Future<String?> translateReview({
    required String reviewId,
    required String content,
    required String targetLanguage,
  }) async {
    final key = _cacheKey(reviewId, targetLanguage);

    // 1) 메모리 캐시
    if (_memCache.containsKey(key)) {
      debugPrint('Translation cache hit (memory): $key');
      return _memCache[key];
    }

    // 2) Supabase DB 캐시
    try {
      final existing = await SupabaseService.translations()
          .select('translated_text')
          .eq('review_id', reviewId)
          .eq('language', targetLanguage)
          .maybeSingle();

      if (existing != null) {
        final text = existing['translated_text'] as String;
        _memCache[key] = text;
        debugPrint('Translation cache hit (DB): $key');
        return text;
      }
    } catch (e) {
      debugPrint('Translation DB lookup failed: $e');
    }

    // 3) Azure API 호출
    final result = await ApiService.translate(content, targetLanguage);
    if (result == null) return null;

    final translatedText = result['translatedText'] as String?;
    final sourceLanguage = result['from'] as String?;
    if (translatedText == null) return null;

    // Supabase에 저장
    try {
      await SupabaseService.translations().upsert({
        'review_id': reviewId,
        'language': targetLanguage,
        'translated_text': translatedText,
        'source_language': sourceLanguage,
      });
      debugPrint('Translation saved to DB: $key');
    } catch (e) {
      debugPrint('Translation DB save failed: $e');
      // 저장 실패해도 번역 결과는 반환
    }

    // 메모리 캐시
    _memCache[key] = translatedText;
    return translatedText;
  }

  /// 특정 리뷰의 모든 번역 가져오기 (DB에서)
  Future<Map<String, String>> getTranslationsForReview(String reviewId) async {
    try {
      final response = await SupabaseService.translations()
          .select('language, translated_text')
          .eq('review_id', reviewId);

      final map = <String, String>{};
      for (final row in response as List) {
        map[row['language'] as String] = row['translated_text'] as String;
      }
      return map;
    } catch (e) {
      debugPrint('Error fetching translations: $e');
      return {};
    }
  }

  void clearCache() => _memCache.clear();
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for calling NestJS backend APIs
/// (Naver Map, Diningcode, etc.)
class ApiService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  // ─── Naver Map ───

  static Future<Map<String, dynamic>?> naverAllSearch(
    String query, {
    String? coords,
  }) async {
    final params = {'query': query};
    if (coords != null) params['coords'] = coords;
    return _get('/api/naver-map/all-search', params);
  }

  static Future<Map<String, dynamic>?> naverSearch(
    String query, {
    int display = 5,
    int start = 1,
  }) async {
    return _get('/api/naver-map/search', {
      'query': query,
      'display': display.toString(),
      'start': start.toString(),
    });
  }

  static Future<Map<String, dynamic>?> naverGeocode(String address) async {
    return _get('/api/naver-map/geocode', {'query': address});
  }

  static Future<Map<String, dynamic>?> naverReverseGeocode(String coords) async {
    return _get('/api/naver-map/reverse-geocode', {'coords': coords});
  }

  // ─── Diningcode ───

  static Future<Map<String, dynamic>?> diningcodeSearch(String query) async {
    return _get('/api/diningcode/search', {'query': query});
  }

  static Future<Map<String, dynamic>?> diningcodeDetail(String id) async {
    return _get('/api/diningcode/detail', {'id': id});
  }

  // ─── Translate ───

  static Future<Map<String, dynamic>?> translate(
    String text,
    String to, {
    String? from,
  }) async {
    return _post('/api/translate', {
      'text': text,
      'to': to,
      if (from != null) 'from': from,
    });
  }

  static Future<List<dynamic>?> translateBatch(
    List<String> texts,
    String to, {
    String? from,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/translate/batch');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'texts': texts,
              'to': to,
              if (from != null) 'from': from,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      debugPrint('API error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('API call failed: $e');
      return null;
    }
  }

  // ─── HTTP Helper ───

  static Future<Map<String, dynamic>?> _get(
    String path,
    Map<String, String> queryParams,
  ) async {
    try {
      final uri = Uri.parse(_baseUrl + path).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      debugPrint('API error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('API call failed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      debugPrint('API error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('API call failed: $e');
      return null;
    }
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  // Auth shortcuts
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static String? get userId => currentUser?.id;

  // Table shortcuts
  static SupabaseQueryBuilder places() => client.from('places');
  static SupabaseQueryBuilder reviews() => client.from('reviews');
  static SupabaseQueryBuilder profiles() => client.from('profiles');
  static SupabaseQueryBuilder bookmarks() => client.from('bookmarks');
  static SupabaseQueryBuilder foreignerTips() => client.from('foreigner_tips');
  static SupabaseQueryBuilder reviewLikes() => client.from('review_likes');
  static SupabaseQueryBuilder translations() => client.from('translations');
  static SupabaseQueryBuilder notificationPrefs() =>
      client.from('notification_preferences');
}

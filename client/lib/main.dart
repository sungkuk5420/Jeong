import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize push notifications
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('FCM 초기화 실패 (에뮬레이터에서는 정상): $e');
  }

  runApp(const ProviderScope(child: JeongApp()));
}

import 'dart:ui';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodakuu/app.dart';
import 'package:rodakuu/core/config/app_env.dart';
import 'package:rodakuu/core/widgets/config_error_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Menginisialisasi binding, konfigurasi environment, Supabase, dan menjalankan aplikasi.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Kesalahan tak tertangani: $error');
    }
    return true;
  };

  if (!AppEnv.isConfigured) {
    runApp(const ConfigErrorApp());
    return;
  }

  await initializeDateFormatting('id_ID');
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: const RodaKuuApp(),
    ),
  );
}

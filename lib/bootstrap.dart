import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodakuu/app.dart';
import 'package:rodakuu/core/config/app_env.dart';
import 'package:rodakuu/core/widgets/config_error_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _diagnoseSupabaseConnection() async {
  try {
    final uri = Uri.tryParse(AppEnv.supabaseUrl);
    final host = uri?.host ?? '';
    if (host.isEmpty) return;
    debugPrint('🔍 [DNS_CHECK] Memeriksa resolusi host: $host');
    final addresses = await InternetAddress.lookup(host);
    final ips = addresses.map((a) => a.address).join(', ');
    debugPrint('✅ [DNS_CHECK] Resolusi host berhasil ($host -> $ips)');
  } catch (e) {
    debugPrint('❌ [DNS_CHECK_FAILED] Gagal me-resolve host Supabase: $e');
    debugPrint(
      '💡 [DNS_HINT] Perangkat atau emulator tidak dapat mengakses internet atau DNS gagal. '
      'Jika menggunakan Android Emulator, pastikan emulator memiliki koneksi internet aktif.',
    );
  }
}

/// Menginisialisasi binding, konfigurasi environment, Supabase, dan menjalankan aplikasi.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Kesalahan tak tertangani: $error');
      debugPrint('Stack trace: $stack');
    }
    return true;
  };

  if (!AppEnv.isConfigured) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ [CONFIG_WARNING] AppEnv belum dikonfigurasi (SUPABASE_URL atau SUPABASE_PUBLISHABLE_KEY kosong). '
        'Menampilkan ConfigErrorApp.',
      );
    }
    runApp(const ConfigErrorApp());
    return;
  }

  if (kDebugMode) {
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('🚀 [RODAKUU_BOOTSTRAP] Memulai inisialisasi aplikasi...');
    debugPrint('🌐 [SUPABASE_URL] ${AppEnv.supabaseUrl}');
    const key = AppEnv.supabasePublishableKey;
    final masked = key.length > 15
        ? '${key.substring(0, 15)}... (panjang: ${key.length})'
        : '***';
    debugPrint('🔑 [SUPABASE_KEY] $masked');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
  }

  await initializeDateFormatting('id_ID');

  try {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
      debug: kDebugMode,
    );
    if (kDebugMode) {
      debugPrint(
        '🔌 [SUPABASE_INIT] Supabase Client berhasil diinisialisasi (debug=$kDebugMode)',
      );
      unawaited(_diagnoseSupabaseConnection());
    }
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('❌ [SUPABASE_INIT_ERROR] Gagal menginisialisasi Supabase: $e');
      debugPrint('$st');
    }
  }

  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: const RodaKuuApp(),
    ),
  );
}

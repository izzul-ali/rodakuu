import 'dart:async';
import 'dart:ui';

/// Helper untuk menunda pemanggilan fungsi sampai jeda waktu tertentu berhenti.
class Debouncer {
  Debouncer({required this.delay});

  final Duration delay;
  Timer? _timer;

  /// Menjalankan aksi setelah [delay] tanpa panggilan baru.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Membatalkan timer yang sedang berjalan.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifier untuk memberi tahu GoRouter saat status login pengguna berubah.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<String?> userIdChanges) {
    _subscription = userIdChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<String?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

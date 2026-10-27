import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/widgets/not_found_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider konfigurasi GoRouter utama aplikasi.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('RodaKuu'))),
      ),
    ],
  );
});

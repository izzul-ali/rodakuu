import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/router/auth_refresh_notifier.dart';
import 'package:rodakuu/core/widgets/not_found_screen.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/auth/presentation/screens/login_screen.dart';
import 'package:rodakuu/features/auth/presentation/screens/register_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_form_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_history_screen.dart';
import 'package:rodakuu/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:rodakuu/features/profile/presentation/screens/profile_screen.dart';
import 'package:rodakuu/features/shell/main_shell_screen.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_detail_screen.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_list_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider konfigurasi GoRouter utama aplikasi yang menangani auth redirect dan bottom shell.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authRepositoryProvider);
  final refresh = AuthRefreshNotifier(auth.userIdChanges);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUserId != null;
      final location = state.matchedLocation;
      final atAuth =
          location == AppRoutes.login || location == AppRoutes.register;
      if (!loggedIn && !atAuth) return AppRoutes.login;
      if (loggedIn && atAuth) return AppRoutes.home;
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const VehicleListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                builder: (context, state) => const BookingHistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => BookingDetailScreen(
                      bookingId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'ubah',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/kendaraan/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            VehicleDetailScreen(vehicleId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'pesan',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                BookingFormScreen(vehicleId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

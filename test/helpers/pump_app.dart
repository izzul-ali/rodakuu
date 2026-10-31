import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_theme.dart';

/// Helper pengujian untuk merender widget dalam ProviderScope dan MaterialApp RodaKuu.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(393, 852),
  double textScale = 1.0,
  GoRouter? customRouter,
}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  addTearDown(tester.view.reset);

  final testRouter =
      customRouter ??
      GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => child),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) =>
                const Scaffold(body: Text('Login Screen Mock')),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (context, state) =>
                const Scaffold(body: Text('Register Screen Mock')),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const Scaffold(body: Text('Home Screen Mock')),
          ),
        ],
      );

  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: overrides,
      child: MaterialApp.router(
        theme: AppTheme.light(useGoogleFonts: false),
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: testRouter,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              textScale,
            ).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3),
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
}

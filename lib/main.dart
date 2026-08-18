import 'dart:io';

import 'package:cosmox_client/core/constants.dart';
import 'package:cosmox_client/core/global_keys.dart';
import 'package:cosmox_client/presentation/pages/api_manager.dart';
import 'package:cosmox_client/presentation/pages/client_setting.dart';
import 'package:cosmox_client/presentation/pages/dashboard.dart';
import 'package:cosmox_client/presentation/pages/dashboard_shell.dart';
import 'package:cosmox_client/presentation/pages/error.dart';
import 'package:cosmox_client/presentation/widgets/under_construction.dart';
import 'package:cosmox_client/presentation/pages/guide.dart';
import 'package:device_preview/device_preview.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cosmox_client/presentation/pages/home.dart';
import 'package:cosmox_client/presentation/pages/library_content.dart';
import 'package:cosmox_client/presentation/pages/library_manager.dart';
import 'package:cosmox_client/presentation/pages/library_view.dart';
import 'package:cosmox_client/presentation/pages/logs.dart';
import 'package:cosmox_client/presentation/pages/media_playback/comics_reader.dart';
import 'package:cosmox_client/presentation/pages/media_playback/markdown_reader.dart';
import 'package:cosmox_client/presentation/pages/media_playback/novel_reader.dart';
import 'package:cosmox_client/presentation/pages/metadata_editor.dart';
import 'package:cosmox_client/presentation/pages/network_settings.dart';
import 'package:cosmox_client/presentation/pages/plugin_manager.dart';
import 'package:cosmox_client/presentation/pages/resource_detail.dart';
import 'package:cosmox_client/presentation/pages/debug.dart';
import 'package:cosmox_client/presentation/pages/search.dart';
import 'package:cosmox_client/presentation/pages/select_server.dart';
import 'package:cosmox_client/presentation/pages/user.dart';
import 'package:cosmox_client/presentation/pages/user_manager.dart';
import 'package:cosmox_client/presentation/pages/media_playback/video_player.dart';
import 'package:cosmox_client/presentation/pages/media_playback/music_player.dart';
import 'package:cosmox_client/presentation/pages/home_shell.dart';
import 'package:cosmox_client/presentation/pages/about.dart';
import 'package:cosmox_client/presentation/pages/login.dart';
import 'package:cosmox_client/presentation/pages/user/setting.dart';
import 'package:cosmox_client/presentation/pages/user/setting_subtitle.dart';
import 'package:cosmox_client/presentation/pages/user/setting_playback.dart';
import 'package:cosmox_client/presentation/pages/user/setting_profile.dart';
import 'package:cosmox_client/presentation/pages/user/setting_account.dart';
import 'package:cosmox_client/presentation/pages/user/setting_sessions.dart';
import 'package:cosmox_client/presentation/pages/user/setting_notifications.dart';
import 'package:cosmox_client/presentation/pages/user/setting_preferences.dart';
import 'package:cosmox_client/presentation/pages/user/setting_danger.dart';
import 'package:cosmox_client/presentation/pages/global/setting.dart';
import 'package:cosmox_client/l10n/app_localizations.dart';
import 'package:cosmox_client/core/state.dart';
import 'package:cosmox_client/core/app_info.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:media_kit/media_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';

import 'package:cosmox_client/core/transitions.dart';
import 'package:cosmox_client/src/rust/frb_generated.dart';

final Logger _logger = Logger('main');

final routes = [
  ShellRoute(
    builder: (context, state, child) => HomeShellPage(child: child),
    routes: [
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            slideRightPage(const HomePage(), state.pageKey),
      ),
      GoRoute(
        path: '/client/setting',
        pageBuilder: (context, state) =>
            slideRightPage(const ClientSettingPage(), state.pageKey),
      ),
    ],
  ),
  GoRoute(
    path: '/about',
    pageBuilder: (context, state) => fadePage(const AboutPage(), state.pageKey),
  ),
  GoRoute(
    path: '/about/content',
    pageBuilder: (context, state) =>
        fadePage(const AboutContentPage(), state.pageKey),
  ),
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) =>
        slideUpPage(const LoginPage(), state.pageKey),
  ),
  GoRoute(
    path: '/logout',
    redirect: (context, state) async {
      await context.read<AuthController>().removeToken();
      return '/login';
    },
  ),
  GoRoute(
    path: '/debug',
    pageBuilder: (context, state) =>
        instantPage(const DebugPage(), state.pageKey),
  ),
  GoRoute(
    path: '/search',
    pageBuilder: (context, state) =>
        slideRightPage(const SearchPage(), state.pageKey),
  ),
  GoRoute(
    path: '/user/setting',
    pageBuilder: (context, state) => slideRightPage(
      const UserSettingPage(title: 'user setting'),
      state.pageKey,
    ),
    routes: [
      GoRoute(
        path: 'subtitle',
        pageBuilder: (context, state) => slideRightPage(
          const SubtitleSettingPage(title: 'subtitle setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'playback',
        pageBuilder: (context, state) => slideRightPage(
          const PlaybackSettingPage(title: 'playback setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'profile',
        pageBuilder: (context, state) => slideRightPage(
          const ProfileSettingPage(title: 'profile setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'account',
        pageBuilder: (context, state) => slideRightPage(
          const AccountSettingPage(title: 'account setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'sessions',
        pageBuilder: (context, state) => slideRightPage(
          const DeviceSessionSettingPage(title: 'sessions setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'notifications',
        pageBuilder: (context, state) => slideRightPage(
          const NotificationSettingPage(title: 'notification setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'preferences',
        pageBuilder: (context, state) => slideRightPage(
          const PreferenceSettingPage(title: 'preference setting'),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: 'danger',
        pageBuilder: (context, state) => slideRightPage(
          const DangerSettingPage(title: 'danger setting'),
          state.pageKey,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/user/:id',
    redirect: (context, state) {
      final idStr = state.pathParameters['id'];
      final id = int.tryParse(idStr ?? '');
      if (id == null || id < 0) return '/error/404';
      return null;
    },
    pageBuilder: (context, state) => slideRightPage(
      UserPage(uid: int.parse(state.pathParameters['id']!)),
      state.pageKey,
    ),
  ),
  GoRoute(
    path: '/resource/:id',
    redirect: (context, state) {
      final idStr = state.pathParameters['id'];
      final id = int.tryParse(idStr ?? '');
      if (id == null || id < 0) return '/error/404';
      return null;
    },
    pageBuilder: (context, state) => slideRightPage(
      ResourceDetailPage(rid: int.parse(state.pathParameters['id']!)),
      state.pageKey,
    ),
  ),
  GoRoute(
    path: '/library/view/:id',
    redirect: (context, state) {
      final idStr = state.pathParameters['id'];
      final id = int.tryParse(idStr ?? '');
      if (id == null || id < 0) return '/error/404';
      return null;
    },
    pageBuilder: (context, state) => slideRightPage(
      LibraryViewPage(lid: int.parse(state.pathParameters['id']!)),
      state.pageKey,
    ),
  ),
  GoRoute(
    path: '/library/content/:id',
    redirect: (context, state) {
      final idStr = state.pathParameters['id'];
      final id = int.tryParse(idStr ?? '');
      if (id == null || id < 0) return '/error/404';
      return null;
    },
    pageBuilder: (context, state) => slideRightPage(
      LibraryContentPage(lid: int.parse(state.pathParameters['id']!)),
      state.pageKey,
    ),
  ),
  GoRoute(
    path: '/reader/comics/:id',
    redirect: (context, state) {
      final idStr = state.pathParameters['id'];
      final id = int.tryParse(idStr ?? '');
      if (id == null || id < 0) return '/error/404';
      return null;
    },
    pageBuilder: (context, state) =>
        fadePage(const ComicsPlayerPage(), state.pageKey),
  ),
  GoRoute(
    path: '/select/server',
    pageBuilder: (context, state) =>
        slideUpPage(const SelectServerPage(), state.pageKey),
  ),
  ShellRoute(
    builder: (context, state, child) => GuideShellPage(
      currentStep: int.tryParse(state.pathParameters['step'] ?? '1') ?? 1,
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/guide/:step',
        pageBuilder: (context, state) {
          final step = int.tryParse(state.pathParameters['step'] ?? '1') ?? 1;
          final page = switch (step) {
            1 => const GuideStep1Page(),
            2 => const GuideStep2Page(),
            3 => const GuideStep3Page(),
            4 => const GuideStep4Page(),
            _ => const GuideStep1Page(),
          };
          return slideRightPage(page, state.pageKey);
        },
      ),
    ],
  ),
  ShellRoute(
    builder: (context, state, child) => DashboardShellPage(child: child),
    routes: [
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) =>
            slideRightPage(const DashboardPage(), state.pageKey),
        routes: [
          GoRoute(
            path: 'network/setting',
            pageBuilder: (context, state) =>
                slideRightPage(const NetworkSettingPage(), state.pageKey),
          ),
          GoRoute(
            path: 'usermanager',
            pageBuilder: (context, state) =>
                slideRightPage(const UserManagerPage(), state.pageKey),
          ),
          GoRoute(
            path: 'librarymanager',
            pageBuilder: (context, state) =>
                slideRightPage(const LibraryManagerPage(), state.pageKey),
          ),
          GoRoute(
            path: 'plugin',
            pageBuilder: (context, state) =>
                slideRightPage(const PluginManagerPage(), state.pageKey),
          ),
          GoRoute(
            path: 'metadata/editor',
            pageBuilder: (context, state) =>
                slideRightPage(const MetadataEditorPage(), state.pageKey),
          ),
          GoRoute(
            path: 'logs',
            pageBuilder: (context, state) =>
                slideRightPage(const LogsPage(), state.pageKey),
          ),
          GoRoute(
            path: 'global/setting',
            pageBuilder: (context, state) =>
                slideRightPage(const GlobalSettingPage(), state.pageKey),
          ),
          GoRoute(
            path: 'api/keys',
            pageBuilder: (context, state) =>
                slideRightPage(const ApiKeysManagerPage(), state.pageKey),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/player',
    builder: (context, state) => const SizedBox.shrink(),
    routes: [
      GoRoute(
        path: 'video/:id',
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is VideoPlaybackPayload) {
            return fadePage(
              VideoPlayerPage(
                items: extra.items,
                token: extra.token,
                startIndex: extra.startIndex,
              ),
              state.pageKey,
            );
          }
          String id = state.pathParameters['id']!;
          return fadePage(
            VideoPlayerPage(
              items: [PlaybackItem(title: '', url: id)],
            ),
            state.pageKey,
          );
        },
      ),
      GoRoute(
        path: 'music/:id',
        pageBuilder: (context, state) {
          String id = state.pathParameters['id']!;
          return fadePage(MusicPlayerPage(musicUrl: id), state.pageKey);
        },
      ),
      GoRoute(
        path: 'markdown/:id',
        pageBuilder: (context, state) =>
            fadePage(const MarkdownReaderPage(), state.pageKey),
      ),
      GoRoute(
        path: 'novel/:id',
        pageBuilder: (context, state) =>
            fadePage(const NovelReaderPage(), state.pageKey),
      ),
    ],
  ),
  GoRoute(
    path: '/error',
    pageBuilder: (context, state) {
      final params = state.uri.queryParameters;
      return fadePage(
        ErrorPage(
          type: ErrorType.error,
          title: params['title'],
          message: params['message'],
          details: params['details'],
        ),
        state.pageKey,
      );
    },
    routes: [
      GoRoute(
        path: '404',
        pageBuilder: (context, state) =>
            fadePage(const ErrorPage(type: ErrorType.notFound), state.pageKey),
      ),
    ],
  ),
  GoRoute(
    path: '/under-construction',
    pageBuilder: (context, state) =>
        fadePage(const UnderConstructionPage(), state.pageKey),
  ),
];

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await RustLib.init();

  WidgetsFlutterBinding.ensureInitialized();
  // Load app metadata (version, build number, etc.).
  await AppInfo.init();
  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();
  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    await windowManager.ensureInitialized();
  }
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final AuthController authController = AuthController();
  final ThemeController themeController = ThemeController();
  await authController.init();
  await themeController.init();
  _logger.info("---> ${authController.status} <---");

  final router = GoRouter(
    initialLocation: '/home',
    errorBuilder: (context, state) => const ErrorPage(),
    routes: routes,
    refreshListenable: authController,
    redirect: (context, state) {
      final currentLocation = state.matchedLocation;
      final status = authController.status;
      final isLoggingIn = currentLocation == '/login';
      final isSelectServer = currentLocation == '/select/server';
      final isGuide = currentLocation.startsWith('/guide/');

      final directTo = switch (status) {
        AuthStatus.serverUnselected => isSelectServer ? null : '/select/server',
        AuthStatus.serverUninitialized => isGuide ? null : '/guide/1',
        AuthStatus.unauthenticated =>
          (isLoggingIn || isSelectServer) ? null : '/login',
        AuthStatus.authenticated =>
          (isGuide || isSelectServer || isLoggingIn) ? '/home' : null,
      };
      return directTo;
    },
  );

  // Build the app widget tree (without DevicePreview wrapper).
  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: authController),
        Provider<GoRouter>.value(value: router),
      ],
      child: const MyApp(),
    );
  }

  if (kReleaseMode) {
    runApp(buildApp());
  } else {
    runApp(
      DevicePreview(
        enabled: true,
        availableLocales: const [Locale('en'), Locale('zh')],
        builder: (context) => buildApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final router = context.watch<GoRouter>();

    return ResponsiveBreakpoints.builder(
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'cosmox flutter client',
        debugShowCheckedModeBanner: false,
        builder: !kReleaseMode ? DevicePreview.appBuilder : null,
        locale: !kReleaseMode ? DevicePreview.locale(context) : null,
        themeMode: themeController.themeMode,
        theme: ThemeData(
          colorSchemeSeed:
              themeController.colorSelectionMethod ==
                  ColorSelectionMethod.colorSeed
              ? themeController.colorSeed.color
              : null,
          colorScheme:
              themeController.colorSelectionMethod == ColorSelectionMethod.image
              ? themeController.imageColorScheme
              : null,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed:
              themeController.colorSelectionMethod ==
                  ColorSelectionMethod.colorSeed
              ? themeController.colorSeed.color
              : themeController.imageColorScheme!.primary,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('zh'), // Chinese
        ],
        routerConfig: router,
      ),
      breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    );
  }
}

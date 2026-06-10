import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../screens/mes_sessions_page.dart';
import '../screens/mes_sessions_page_2.dart';
import '../screens/session.dart';
import '../screens/user_search.dart';
import '../screens/auth.dart';
import '../screens/menu_principal.dart';
import '../screens/splash_screen.dart';
import 'package:ensiconnect/screens/demande_aide_page.dart';
import '../screens/top_tutors.dart';
import '../service/session_service.dart';

// On garde le notifier global
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

class EnsiConnectApp extends StatefulWidget {
  const EnsiConnectApp({super.key});

  // Charte graphique
  static const Color ensisaBlue = Color(0xFF0055A5);
  static const Color ensisaLightBlue = Color(0xFFE6F0FA);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color backgroundlightColor = Colors.lightBlueAccent;

  @override
  State<EnsiConnectApp> createState() => _EnsiConnectAppState();
}

class _EnsiConnectAppState extends State<EnsiConnectApp>
    with WidgetsBindingObserver {
  static const Duration _cleanupInterval = Duration(minutes: 5);
  static const Duration _minGapBetweenRuns = Duration(minutes: 1);

  final SessionService _sessionService = SessionService();
  Timer? _cleanupTimer;
  bool _cleanupInProgress = false;
  DateTime? _lastCleanupAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runCleanupIfNeeded(force: true);
    _cleanupTimer = Timer.periodic(
      _cleanupInterval,
      (_) => _runCleanupIfNeeded(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runCleanupIfNeeded();
    }
  }

  Future<void> _runCleanupIfNeeded({bool force = false}) async {
    if (_cleanupInProgress) {
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastCleanupAt != null &&
        now.difference(_lastCleanupAt!) < _minGapBetweenRuns) {
      return;
    }

    _cleanupInProgress = true;
    try {
      await _sessionService.cleanupOldSessions();
      _lastCleanupAt = DateTime.now();
    } finally {
      _cleanupInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'EnsiConnect',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
          ],

          // ── THÈME CLAIR ──
          theme: ThemeData(
            scaffoldBackgroundColor: EnsiConnectApp.backgroundColor,
            primaryColor: EnsiConnectApp.ensisaBlue,
            fontFamily: 'Roboto',
            brightness: Brightness.light,
            cardColor: Colors.white,
          ),

          // ── THÈME SOMBRE ──
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: EnsiConnectApp.ensisaBlue,
            fontFamily: 'Roboto',
            brightness: Brightness.dark,
            cardColor: const Color(0xFF1E1E1E),
          ),

          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const Auth(),
            '/home': (context) => const MainNavigationScreen(),
            '/mes_sessions': (context) => const MesSessionsPage(),
            '/mes_sessions_page_2': (context) => const MesSessionsPage2(),
            '/demande_aide': (context) => const DemandeAidePage(),
            '/post_session': (context) => const PostSessionPage(),
            '/user_search': (context) => const SearchPage(),
            '/top_tutors': (context) => const TopTutorsPage(),
          },
        );
      },
    );
  }
}

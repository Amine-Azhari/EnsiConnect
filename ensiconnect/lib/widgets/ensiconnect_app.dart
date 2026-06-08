import 'package:flutter/material.dart';
import '../screens/mes_sessions_page.dart';
import '../screens/mes_sessions_page_2.dart';
import '../screens/session.dart';
import '../screens/user_search.dart';
import '../screens/auth.dart';
import '../screens/menu_principal.dart';
import '../screens/splash_screen.dart';
import 'package:ensiconnect/screens/demande_aide_page.dart';
import '../screens/top_tutors.dart';

// On garde le notifier global
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

class EnsiConnectApp extends StatelessWidget {
  const EnsiConnectApp({super.key});
  
  // Charte graphique
  static const Color ensisaBlue = Color(0xFF0055A5);
  static const Color ensisaLightBlue = Color(0xFFE6F0FA);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color backgroundlightColor = Colors.lightBlueAccent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'EnsiConnect',
          debugShowCheckedModeBanner: false,

          // ── THÈME CLAIR ──
          theme: ThemeData(
            scaffoldBackgroundColor: backgroundColor,
            primaryColor: ensisaBlue,
            fontFamily: 'Roboto',
            brightness: Brightness.light,
            cardColor: Colors.white,
          ),

          // ── THÈME SOMBRE ──
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: ensisaBlue,
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
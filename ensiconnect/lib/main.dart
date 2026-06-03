import 'package:ensiconnect/chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'menu_principal.dart';
import 'splash_screen.dart';
import 'database_maker.dart';
import 'session.dart';

// On garde le notifier global
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

void main() async {
  // Indispensable pour s'assurer que Flutter est prêt avant de lire le stockage
  WidgetsFlutterBinding.ensureInitialized();

  // On ouvre le stockage local
  final prefs = await SharedPreferences.getInstance();

  // On lit la valeur sauvegardée (si elle n'existe pas encore, on met true  par défaut)
  final isDarkSaved = prefs.getBool('isDarkMode') ?? true;

  // On applique la valeur sauvegardée à notre Notifier
  isDarkModeNotifier.value = isDarkSaved;

  runApp(const EnsiConnectApp());
}

class EnsiConnectApp extends StatelessWidget {
  const EnsiConnectApp({super.key});

  static const Color ensisaBlue = Color(0xFF0055A5);
  static const Color ensisaLightBlue = Color(0xFFE6F0FA);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color accentOrange = Color(0xFFFF9800);

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

          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const Auth(),
            '/home': (context) => const MainNavigationScreen(),
            '/post_session': (context) => const PostSessionPage(),
            '/chat': (context) => const ChatPage(),
          },
        );
      },
    );
  }
}

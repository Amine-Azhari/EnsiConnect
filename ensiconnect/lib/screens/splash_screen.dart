import 'dart:async';
import 'package:flutter/material.dart';
import '../service/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // On attend 3 secondes pour l'animation
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Vérifie si une session existe
    final user = await UserServices().getCurrentUser();
    
    if (mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/icon-192.png'),
              width: 150,
              height: 150,
            ),

            // Espacement
            SizedBox(height: 32),

            Image(
              image: AssetImage('assets/images/Logo-ENSISA.png'),
              width: 300,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}

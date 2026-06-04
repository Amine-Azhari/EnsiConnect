import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redirection vers l'écran de navigation après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
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

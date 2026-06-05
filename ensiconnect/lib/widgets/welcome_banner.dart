import 'package:flutter/material.dart';
import "ensiconnect_app.dart";

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EnsiConnectApp.ensisaBlue, Color(0xFF0077E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack( 
        children: [
          Positioned(
            right: 15,
            bottom: 0,
            child: Icon(
              Icons.school_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Apprends.\nPartage.",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                ),
                SizedBox(height: 8),
                Text(
                  "Progresse ensemble.",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
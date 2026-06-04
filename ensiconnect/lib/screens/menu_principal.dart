import 'package:flutter/material.dart';
import '../main.dart'; // Pour accéder aux couleurs de l'app
import '../models/user.dart';
import 'profil.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_demand_card.dart';
import 'chat.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_notification_button.dart';
import 'user_search.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  List<Widget> get _pages => [
    const HomePage(),
    const SearchPage(),
    const ChatPage(),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: SizedBox(
        width: 54,
        height: 54,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: isDark ? Colors.lightBlueAccent : EnsiConnectApp.ensisaBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: isDark ? Colors.black87 : Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    const User currentUser = User(
      id: '1',
      firstName: 'Ayoubbb',
      lastName: 'Darka',
      email: 'ayoub.darkaoui@uha.fr',
      promotion: '1A',
      filiere: 'Informatique',
      role: 'Étudiant',
      profilePictureUrl: 'assets/images/pdp.png',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    // Gris renforcé en mode jour pour corriger le problème de visibilité
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      key: _scaffoldKey, 
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(), 
                    icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const CustomNotificationButton(),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Bonjour, ${currentUser.firstName} 👋",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                "Que veux-tu apprendre aujourd'hui ?",
                style: TextStyle(fontSize: 14, color: subtitleColor),
              ),
              const SizedBox(height: 24),
              const WelcomeBanner(),
              const SizedBox(height: 20),
              const CustomSearchBar(),
              const SizedBox(height: 24),
              Text(
                "Actions rapides",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 16),
              const QuickActionsGrid(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Demandes récentes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Voir tout", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const RecentDemandCard(
                title: "Java - POO",
                subtitle: "Besoin d'explication sur les classes abstraites et interfaces.",
                time: "Il y a 20 min",
                iconData: Icons.code_rounded,
                iconColor: Color(0xFF2196F3),
              ),
              const SizedBox(height: 12),
              const RecentDemandCard(
                title: "Réseaux - Routage",
                subtitle: "Compréhension du routage dynamique (RIP, OSPF).",
                time: "Il y a 1 h",
                iconData: Icons.hub_rounded,
                iconColor: EnsiConnectApp.accentOrange,
              ),
              const SizedBox(height: 30), 
            ],
          ),
        ),
      ),
    );
  }
}

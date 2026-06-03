import 'package:flutter/material.dart';
import 'setting_page.dart'; // Importation de la page de paramètres
import 'main.dart'; // Pour accéder aux couleurs de l'app
import 'models/user.dart';
import 'user_search.dart';
import 'chat.dart';
import 'demande_aide_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ChatPage(),
    const Center(child: Text("Mon Profil")),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: isDark ? 16 : 8,
        shadowColor: isDark ? Colors.black : Colors.black45,
        clipBehavior: Clip.antiAlias,
        color: isDark ? Colors.grey.shade900 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Accueil", 0),
              _buildNavItem(Icons.search_rounded, "Explorer", 1),
              const SizedBox(width: 44), 
              _buildNavItem(Icons.chat_bubble_outline_rounded, "Messages", 2),
              _buildNavItem(Icons.person_outline_rounded, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final color = isSelected 
        ? (isDark ? Colors.lightBlueAccent : EnsiConnectApp.ensisaBlue) 
        : (isDark ? Colors.grey.shade300 : Colors.grey.shade500);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28), 
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
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
    final User currentUser = const User(
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: EnsiConnectApp.ensisaBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser.profilePictureUrl != null
                        ? (currentUser.profilePictureUrl!.startsWith('http')
                            ? NetworkImage(currentUser.profilePictureUrl!) as ImageProvider
                            : AssetImage(currentUser.profilePictureUrl!))
                        : null,
                    child: currentUser.profilePictureUrl == null
                        ? Text(
                            '${currentUser.firstName[0]}${currentUser.lastName[0]}',
                            style: const TextStyle(fontSize: 24, color: EnsiConnectApp.ensisaBlue, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser.fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currentUser.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context); // Ferme le Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()), 
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Aide & Support'),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Redirige vers la page d'authentification et vide la pile de navigation
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
              },
            ),
          ],
        ),
      ),
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
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
                      boxShadow: isDark ? [] : [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_none_rounded, color: textColor),
                    ),
                  ),
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
              QuickActionsGrid(),
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

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher une matière, un tuteur...",
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ActionItem(
          icon: Icons.school_outlined, 
          label: "Demander\nune aide", 
          color: const Color(0xFF7E57C2),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DemandeAidePage()));
          },
        ),
        const ActionItem(icon: Icons.people_alt_outlined, label: "Trouver\nun tuteur", color: Color(0xFF42A5F5)),
        const ActionItem(icon: Icons.calendar_today_rounded, label: "Mes\nsessions", color: Color(0xFFEF5350)),
        const ActionItem(icon: Icons.bookmark_border_rounded, label: "Mes\nréservations", color: Color(0xFF66BB6A)),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const ActionItem({super.key, required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.w500, 
              color: isDark ? Colors.grey.shade300 : Colors.black87, 
              height: 1.2
            ),
          ),
        ],
      ),
    );
  }
}

class RecentDemandCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData iconData;
  final Color iconColor;

  const RecentDemandCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardTitleColor = isDark ? Colors.white : Colors.black87;
    final cardSubtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    final cardTimeColor = isDark ? Colors.grey.shade500 : Colors.black45;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardTitleColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: cardSubtitleColor, height: 1.3)),
                const SizedBox(height: 12),
                Text(time, style: TextStyle(fontSize: 11, color: cardTimeColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EnsiConnectApp.ensisaLightBlue.withValues(alpha: isDark ? 0.2 : 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Nouveau",
              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
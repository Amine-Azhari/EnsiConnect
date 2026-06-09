import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import 'package:ensiconnect/screens/mes_sessions_page.dart';
import 'package:flutter/material.dart';
import "../widgets/ensiconnect_app.dart";
import '../models/user.dart';
import 'profil.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_demand_card.dart';
import 'chat.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_header.dart';
import 'user_search.dart';
import '../service/user_service.dart';
import 'sessions_details.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _focusExplorerSearch = false;

  List<Widget> get _pages => [
        HomePage(
          onSearchTap: () => setState(() {
            _currentIndex = 1;
            _focusExplorerSearch = true;
          }),
        ),
        SearchPage(autoFocusSearch: _focusExplorerSearch),
        const ChatPage(),
        const ProfilPage(),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 54,
        height: 54,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/post_session');
          },
          backgroundColor: isDark
              ? EnsiConnectApp.backgroundlightColor
              : EnsiConnectApp.ensisaBlue,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(Icons.add,
              color: isDark ? Colors.black87 : Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
            _focusExplorerSearch = false;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Map<String, dynamic>>> _fetchUpcomingSessions() async {
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    final sessionSnap = await db.collection('Session').get();

    List<Map<String, dynamic>> upcoming = [];

    final matieresSnap = await db.collection('Matiere').get();
    final Map<String, String> matieresCache = {};
    for (var doc in matieresSnap.docs) {
      matieresCache[doc.id] = doc.data()['Nom'] ?? 'Matière inconnue';
    }

    for (var doc in sessionSnap.docs) {
      final session = Session.fromMap(doc.data(), doc.id);
      if (session.date.isNotEmpty) {
        try {
          final parsedDate = DateTime.parse(session.date);

          DateTime sessionDateTime =
              DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          if (session.heureDebut.isNotEmpty) {
            final parts = session.heureDebut.split(':');
            if (parts.length >= 2) {
              final hour = int.tryParse(parts[0]) ?? 0;
              final minute = int.tryParse(parts[1]) ?? 0;
              sessionDateTime = DateTime(parsedDate.year, parsedDate.month,
                  parsedDate.day, hour, minute);
            }
          }

          if (sessionDateTime.isAfter(now)) {
            final matiereNom =
                matieresCache[session.matiereId] ?? 'Matière inconnue';
            final title = matiereNom != 'Matière inconnue'
                ? matiereNom
                : (session.sujet.isNotEmpty ? session.sujet : 'Session');

            // Generate a simple relative time or just use the date and time
            final nowDateOnly = DateTime(now.year, now.month, now.day);
            final sessionDateOnly =
                DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
            final differenceInDays =
                sessionDateOnly.difference(nowDateOnly).inDays;

            String timeString;
            if (differenceInDays == 0) {
              timeString = "Aujourd'hui à ${session.heureDebut}";
            } else if (differenceInDays == 1) {
              timeString = "Demain à ${session.heureDebut}";
            } else {
              final mois = [
                '',
                'janv.',
                'févr.',
                'mars',
                'avr.',
                'mai',
                'juin',
                'juil.',
                'août',
                'sept.',
                'oct.',
                'nov.',
                'déc.'
              ];
              timeString =
                  "Le ${sessionDateOnly.day} ${mois[sessionDateOnly.month]} à ${session.heureDebut}";
            }

            upcoming.add({
              'title': title,
              'subtitle':
                  session.description.isNotEmpty ? session.description : title,
              'time': timeString,
              'dateTime': sessionDateTime,
              'session': session,
            });
          }
        } catch (e) {
          // Ignore
        }
      }
    }

    upcoming.sort((a, b) =>
        (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
    return upcoming.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    // Gris renforcé en mode jour pour corriger le problème de visibilité
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: FutureBuilder<User?>(
        future: UserServices().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = snapshot.data ??
              const User(
                id: 'unknown',
                firstName: 'Utilisateur',
                lastName: '',
                email: '',
              );

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHeader(
                    onMenuPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bonjour, ${currentUser.firstName} 👋",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Que veux-tu apprendre aujourd'hui ?",
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                  const SizedBox(height: 24),
                  const WelcomeBanner(),
                  const SizedBox(height: 20),
                  CustomSearchBar(onTap: widget.onSearchTap),
                  const SizedBox(height: 24),
                  Text(
                    "Actions rapides",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sessions à venir",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MesSessionsPage()),
                          );
                        },
                        child: const Text(
                          "Voir tout",
                          style: TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUpcomingSessions(),
                    builder: (context, sessionSnapshot) {
                      if (sessionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (sessionSnapshot.hasError ||
                          !sessionSnapshot.hasData ||
                          sessionSnapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text("Aucune session à venir pour le moment.",
                              style: TextStyle(color: Colors.grey)),
                        );
                      }

                      final sessions = sessionSnapshot.data!;
                      return Column(
                        children: sessions.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var sessionData = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: idx < sessions.length - 1 ? 12.0 : 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SessionsDetailsPage(
                                      session:
                                          sessionData['session'] as Session,
                                    ),
                                  ),
                                );
                              },
                              child: RecentDemandCard(
                                title: sessionData['title'],
                                subtitle: sessionData['subtitle'],
                                time: sessionData['time'],
                                iconData: Icons.event_note_rounded,
                                iconColor: idx == 0
                                    ? const Color(0xFF2196F3)
                                    : EnsiConnectApp.accentOrange,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

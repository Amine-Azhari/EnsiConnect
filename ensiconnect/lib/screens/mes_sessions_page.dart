import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import 'sessions_details.dart';
import "../widgets/ensiconnect_app.dart";

class MesSessionsPage extends StatefulWidget {
  const MesSessionsPage({super.key});

  @override
  State<MesSessionsPage> createState() => _MesSessionsPageState();
}

class _MesSessionsPageState extends State<MesSessionsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Session>> _sessionsByDate = {};
  List<Session> _selectedSessions = [];
  bool _isLoading = true;

  // Caches pour afficher les vrais noms au lieu des IDs
  final Map<String, String> _matieresCache = {};
  final Map<String, String> _sallesCache = {};
  final Map<String, String> _etudiantsCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchData();
  }

  // Normalise une date (retire l'heure) pour comparer uniquement les jours
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> _fetchData() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Récupération des matières, des salles et des étudiants pour le cache
      final matieresSnap = await db.collection('Matiere').get();
      for (var doc in matieresSnap.docs) {
        _matieresCache[doc.id] = doc.data()['Nom'] ?? 'Matière inconnue';
      }

      final sallesSnap = await db.collection('Salle').get();
      for (var doc in sallesSnap.docs) {
        _sallesCache[doc.id] = doc.data()['Nom'] ?? 'Salle inconnue';
      }

      final etudiantsSnap = await db.collection('Etudiant').get();
      for (var doc in etudiantsSnap.docs) {
        final data = doc.data();
        final nom = data['Nom'] ?? '';
        final prenom = data['Prenom'] ?? '';
        _etudiantsCache[doc.id] = '$prenom $nom'.trim();
      }

      // 2. Récupération des sessions
      final sessionSnap = await db.collection('Session').get();
      final Map<DateTime, List<Session>> newSessionsByDate = {};
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var doc in sessionSnap.docs) {
        final session = Session.fromMap(doc.data(), doc.id);
        if (session.date.isNotEmpty) {
          try {
            // Suppose la date est au format 'YYYY-MM-DD' (comme inséré dans data_insert.dart)
            final DateTime parsedDate = DateTime.parse(session.date);
            final sessionDate =
                DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

            // Supprimer la session si elle est passée de date
            bool isExpired = false;

            if (sessionDate.isBefore(today)) {
              isExpired = true;
            } else if (sessionDate.isAtSameMomentAs(today)) {
              if (session.heureFin.isNotEmpty) {
                final parts = session.heureFin.split(':');
                if (parts.length >= 2) {
                  final hour = int.tryParse(parts[0]) ?? 23;
                  final minute = int.tryParse(parts[1]) ?? 59;
                  final endTime = DateTime(sessionDate.year, sessionDate.month,
                      sessionDate.day, hour, minute);
                  if (endTime.isBefore(now)) {
                    isExpired = true;
                  }
                }
              }
            }

            if (isExpired) {
              db.collection('Session').doc(doc.id).delete();
              continue; // Ne pas l'ajouter à l'affichage
            }

            final normalized = _normalizeDate(parsedDate);

            if (newSessionsByDate[normalized] == null) {
              newSessionsByDate[normalized] = [];
            }
            newSessionsByDate[normalized]!.add(session);
          } catch (e) {
            debugPrint(
                "Erreur de parsing de date pour la session ${doc.id}: $e");
          }
        }
      }

      for (final sessions in newSessionsByDate.values) {
        sessions.sort(Session.compareByStartTime);
      }

      if (mounted) {
        setState(() {
          _sessionsByDate = newSessionsByDate;
          _isLoading = false;
          _updateSelectedSessions(_selectedDay!);
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des données: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateSelectedSessions(DateTime day) {
    final normalized = _normalizeDate(day);
    _selectedSessions = List<Session>.from(_sessionsByDate[normalized] ?? [])
      ..sort(Session.compareByStartTime);
  }

  // Cette méthode est appelée par table_calendar pour savoir s'il faut afficher un point
  List<Session> _getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    return _sessionsByDate[normalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sessions prévues",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendrier
                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TableCalendar<Session>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _updateSelectedSessions(selectedDay);
                      });
                    },
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: const BoxDecoration(
                              color: EnsiConnectApp.ensisaBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      // Style du jour sélectionné
                      selectedDecoration: const BoxDecoration(
                        color: EnsiConnectApp.ensisaBlue,
                        shape: BoxShape.circle,
                      ),
                      // Style d'aujourd'hui
                      todayDecoration: const BoxDecoration(
                        color: EnsiConnectApp.ensisaLightBlue,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color:
                            isDark ? Colors.white : EnsiConnectApp.ensisaBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Titre de la liste
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedSessions.isNotEmpty
                          ? "Sessions du ${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}"
                          : "Aucune session prévue ce jour",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Liste des sessions du jour
                Expanded(
                  child: _selectedSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  size: 64,
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "Repose-toi bien !",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _selectedSessions.length,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final session = _selectedSessions[index];
                            final matiereNom =
                                _matieresCache[session.matiereId] ??
                                    'Matière inconnue';
                            final salleNom = _sallesCache[session.salleId] ??
                                'Salle inconnue';
                            final organisateurNom =
                                _etudiantsCache[session.organisateurId] ??
                                    'Organisateur inconnu';
                            final subjectColor =
                                _getSubjectColor(matiereNom, isDark);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.shade900
                                    : subjectColor.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : subjectColor.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : subjectColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SessionsDetailsPage(session: session),
                                    ),
                                  );
                                },
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Barre de couleur sur la gauche
                                      Container(
                                        width: 8,
                                        decoration: BoxDecoration(
                                          color: subjectColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        session.heureDebut,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color:
                                                                subjectColor),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        width: 2,
                                                        height: 16,
                                                        color: subjectColor
                                                            .withValues(
                                                                alpha: 0.5),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        session.heureFin,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: isDark
                                                                ? Colors.grey
                                                                    .shade400
                                                                : Colors.grey
                                                                    .shade600),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          matiereNom,
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .person_outline_rounded,
                                                                size: 16,
                                                                color: isDark
                                                                    ? Colors
                                                                        .grey
                                                                        .shade400
                                                                    : Colors
                                                                        .grey
                                                                        .shade600),
                                                            const SizedBox(
                                                                width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                "Organisé par $organisateurNom",
                                                                style:
                                                                    TextStyle(
                                                                  color: isDark
                                                                      ? Colors
                                                                          .grey
                                                                          .shade400
                                                                      : Colors
                                                                          .grey
                                                                          .shade600,
                                                                  fontSize: 14,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .location_on_outlined,
                                                                size: 16,
                                                                color: isDark
                                                                    ? Colors
                                                                        .grey
                                                                        .shade400
                                                                    : Colors
                                                                        .grey
                                                                        .shade600),
                                                            const SizedBox(
                                                                width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                salleNom,
                                                                style:
                                                                    TextStyle(
                                                                  color: isDark
                                                                      ? Colors
                                                                          .grey
                                                                          .shade400
                                                                      : Colors
                                                                          .grey
                                                                          .shade600,
                                                                  fontSize: 14,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 16,
                                                      color: isDark
                                                          ? Colors.grey.shade600
                                                          : Colors
                                                              .grey.shade400),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/post_session');
        },
        backgroundColor: EnsiConnectApp.ensisaBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter une session",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _getSubjectColor(String subject, bool isDark) {
    final List<MaterialColor> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.green,
    ];
    final index = subject.hashCode.abs() % colors.length;
    return isDark ? colors[index].shade300 : colors[index].shade600;
  }
}

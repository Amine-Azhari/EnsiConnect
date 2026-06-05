import 'package:flutter/material.dart';

import '../main.dart';
import '../service/joined_session_service.dart';

enum _SessionFilter { all, today, week }

class MesSessionsPage2 extends StatefulWidget {
  const MesSessionsPage2({super.key});

  @override
  State<MesSessionsPage2> createState() => _MesSessionsPage2State();
}

class _MesSessionsPage2State extends State<MesSessionsPage2> {
  final JoinedSessionService _joinedSessionService = JoinedSessionService();

  late Future<List<JoinedSessionDetails>> _sessionsFuture;
  _SessionFilter _selectedFilter = _SessionFilter.all;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _joinedSessionService.getJoinedSessionsForCurrentUser();
  }

  Future<void> _reloadSessions() async {
    final future = _joinedSessionService.getJoinedSessionsForCurrentUser();
    setState(() {
      _sessionsFuture = future;
    });
    await future;
  }

  List<JoinedSessionDetails> _applyFilter(List<JoinedSessionDetails> sessions) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekEnd = todayStart.add(const Duration(days: 7));

    switch (_selectedFilter) {
      case _SessionFilter.all:
        return sessions;
      case _SessionFilter.today:
        return sessions.where((session) {
          final date = session.sessionDateTime;
          if (date == null) {
            return false;
          }
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
      case _SessionFilter.week:
        return sessions.where((session) {
          final date = session.sessionDateTime;
          if (date == null) {
            return false;
          }
          return !date.isBefore(todayStart) && date.isBefore(weekEnd);
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes reservations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<JoinedSessionDetails>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                onRetry: _reloadSessions,
                message: 'Impossible de charger vos reservations Firebase.',
              );
            }

            final sessions = snapshot.data ?? const <JoinedSessionDetails>[];
            final filteredSessions = _applyFilter(sessions);

            return RefreshIndicator(
              onRefresh: _reloadSessions,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FilterChipLabel(
                        label: 'Toutes',
                        isSelected: _selectedFilter == _SessionFilter.all,
                        onTap: () => setState(() {
                          _selectedFilter = _SessionFilter.all;
                        }),
                      ),
                      _FilterChipLabel(
                        label: 'Aujourd\'hui',
                        isSelected: _selectedFilter == _SessionFilter.today,
                        onTap: () => setState(() {
                          _selectedFilter = _SessionFilter.today;
                        }),
                      ),
                      _FilterChipLabel(
                        label: 'Cette semaine',
                        isSelected: _selectedFilter == _SessionFilter.week,
                        onTap: () => setState(() {
                          _selectedFilter = _SessionFilter.week;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reservations programmees',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filteredSessions.length} session${filteredSessions.length > 1 ? 's' : ''} trouvee${filteredSessions.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (sessions.isEmpty)
                    const _EmptyState(
                      title: 'Aucune reservation',
                      subtitle:
                          'Votre profil n\'est inscrit a aucune session',
                    )
                  else if (filteredSessions.isEmpty)
                    const _EmptyState(
                      title: 'Aucun resultat pour ce filtre',
                      subtitle:
                          'Essayez un autre filtre pour afficher vos inscriptions.',
                    )
                  else
                    ...filteredSessions.map(
                      (reservation) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReservationCard(
                          reservation: reservation,
                          isDark: isDark,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reloadSessions,
        backgroundColor: EnsiConnectApp.ensisaBlue,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
    );
  }
}

class _FilterChipLabel extends StatelessWidget {
  const _FilterChipLabel({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? EnsiConnectApp.ensisaBlue
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? EnsiConnectApp.ensisaBlue
                : Theme.of(context).dividerColor.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.isDark,
  });

  final JoinedSessionDetails reservation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = _getSubjectColor(reservation.subjectName, isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.subjectName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reservation.session.description.isNotEmpty
                  ? reservation.session.description
                  : reservation.joinMessage.isNotEmpty
                      ? reservation.joinMessage
                      : 'Inscription confirmee pour cette session.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _InfoPill(
                  icon: Icons.calendar_month_rounded,
                  text: _formatDate(reservation.session.date),
                  isDark: isDark,
                ),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  text:
                      '${reservation.session.heureDebut} - ${reservation.session.heureFin}',
                  isDark: isDark,
                ),
                _InfoPill(
                  icon: Icons.location_on_outlined,
                  text: reservation.roomName,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.16),
                  child: Text(
                    _initials(reservation.organizerName),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.organizerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Organisateur de la session',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 52),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(String rawDate) {
  try {
    final date = DateTime.parse(rawDate);
    const months = <String>[
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  } catch (_) {
    return rawDate;
  }
}

String _initials(String fullName) {
  final parts = fullName
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  return parts.map((part) => part[0].toUpperCase()).join();
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

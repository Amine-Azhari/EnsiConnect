import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ensiconnect_app.dart';
import '../service/user_service.dart';
import '../widgets/person_avatar.dart';
import 'profil.dart';
import '../models/user.dart';

class StarRating extends StatelessWidget {
  final double note;

  const StarRating({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (note >= i + 1) {
          return const Icon(Icons.star, size: 14, color: Colors.amber);
        } else if (note >= i + 0.5) {
          return const Icon(Icons.star_half, size: 14, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 14, color: Colors.amber);
        }
      }),
    );
  }
}

class TopTutorsPage extends StatefulWidget {
  const TopTutorsPage({super.key});

  @override
  State<TopTutorsPage> createState() => _TopTutorsPageState();
}

class _TopTutorsPageState extends State<TopTutorsPage> {
  List<Map<String, dynamic>> _allTutors = [];
  List<Map<String, dynamic>> _topTutorsPodium = [];
  List<Map<String, dynamic>> _otherTutors = [];
  bool _isLoading = true;
  String? currentUserId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTopTutors();
  }

  double _readAverageNote(Map<String, dynamic> data) {
    final value = data['averageNote'];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  Future<void> _loadTopTutors() async {
    try {
      final user = await UserServices().getCurrentUser();
      currentUserId = user?.id;

      final etudiantSnap =
          await FirebaseFirestore.instance.collection('Etudiant').get();

      final liste = etudiantSnap.docs.map((doc) {
        final data = doc.data();
        final skills = data.containsKey("skills")
            ? List<String>.from(data["skills"])
            : <String>[];

        final double averageNote = _readAverageNote(data);

        return {
          "id": doc.id,
          "nom": data["Nom"] ?? '',
          "prenom": data["Prenom"] ?? '',
          "matieres": skills,
          "averageNote": averageNote,
          "imageUrl": data["imageUrl"]
        };
      }).toList();

      liste.sort(
        (a, b) =>
            (b["averageNote"] as double).compareTo(a["averageNote"] as double),
      );

      final limitedListe = liste.take(10).toList();

      if (mounted) {
        setState(() {
          _allTutors = limitedListe;
          if (limitedListe.length >= 3) {
            _topTutorsPodium = limitedListe.take(3).toList();
            _otherTutors = limitedListe.skip(3).toList();
          } else {
            _topTutorsPodium = limitedListe;
            _otherTutors = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des tuteurs: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meilleurs tuteurs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _allTutors.isEmpty
                ? const Center(
                    child: Text("Aucun tuteur classé pour le moment."))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        _buildTabSelector(isDark),
                        const SizedBox(height: 24),
                        if (_topTutorsPodium.isNotEmpty)
                          _buildPodiumWidget(isDark, textColor),
                        const SizedBox(height: 24),
                        if (_otherTutors.isNotEmpty)
                          _buildOtherTutorsList(isDark, textColor),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    const tabs = ["Global", "Cette semaine"];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final isSelected = index == _selectedTabIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.grey.shade800 : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected && !isDark
                    ? [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4)
                      ]
                    : [],
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : EnsiConnectApp.ensisaBlue)
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPodiumWidget(bool isDark, Color textColor) {
    if (_topTutorsPodium.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_topTutorsPodium.length >= 2)
            _buildPodiumItem(_topTutorsPodium[1], 2, const Color(0xFFC0C0C0),
                isDark, textColor, 70),
          if (_topTutorsPodium.isNotEmpty)
            Hero(
              tag: 'tutor_profile_${_topTutorsPodium[0]["id"]}',
              child: _buildPodiumItem(_topTutorsPodium[0], 1,
                  const Color(0xFFFFD700), isDark, textColor, 110),
            ),
          if (_topTutorsPodium.length >= 3)
            _buildPodiumItem(_topTutorsPodium[2], 3, const Color(0xFFCD7F32),
                isDark, textColor, 50),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> tuteur, int rank,
      Color rankColor, bool isDark, Color textColor, double stepHeight) {
    final double avatarSize = rank == 1 ? 85 : 70;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilPage(userId: currentUserId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium,
              color: rankColor, size: rank == 1 ? 36 : 28),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: rankColor, width: rank == 1 ? 4 : 3),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PersonAvatar(
                  name: '${tuteur["prenom"]} ${tuteur["nom"]}',
                  imageUrl: tuteur["imageUrl"] as String?,
                  radius: avatarSize / 2,
                  fontSize: rank == 1 ? 24 : 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: rank == 1 ? 110 : 90,
            child: Text(
              tuteur["prenom"],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rank == 1 ? 16 : 14,
                  color: textColor),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    color: Colors.amber, size: rank == 1 ? 16 : 14),
                const SizedBox(width: 4),
                Text(
                  (tuteur["averageNote"] as double).toStringAsFixed(1),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: rank == 1 ? 14 : 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: rank == 1 ? 110 : 90,
            height: stepHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  rankColor.withValues(alpha: 0.3),
                  rankColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: rankColor, width: 2),
                left: BorderSide(
                    color: rankColor.withValues(alpha: 0.5), width: 1),
                right: BorderSide(
                    color: rankColor.withValues(alpha: 0.5), width: 1),
              ),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "$rank",
              style: TextStyle(
                fontSize: rank == 1 ? 32 : 24,
                fontWeight: FontWeight.w900,
                color: rankColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTutorsList(bool isDark, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _otherTutors.asMap().entries.map((entry) {
          final index = entry.key;
          final tuteur = entry.value;
          final rank = index + 4;

          return _buildOtherTutorListItem(tuteur, rank, isDark, textColor,
              index == _otherTutors.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildOtherTutorListItem(Map<String, dynamic> tuteur, int rank,
      bool isDark, Color textColor, bool isLast) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: SizedBox(
            width: 80,
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "#$rank",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: PersonAvatar(
                    name: '${tuteur["prenom"]} ${tuteur["nom"]}',
                    imageUrl: tuteur["imageUrl"] as String?,
                    radius: 22.5,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            "${tuteur["prenom"]} ${tuteur["nom"]}",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
          ),
          subtitle: (tuteur["matieres"] as List).isNotEmpty
              ? Text(
                  (tuteur["matieres"] as List<String>).take(2).join(" • "),
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  (tuteur["averageNote"] as double).toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilPage(
                  userId: tuteur["id"] as String,
                ),
              ),
            );
          },
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 16),
            child: Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                height: 1),
          ),
      ],
    );
  }
}

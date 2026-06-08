import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ensiconnect_app.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../service/user_service.dart';
import 'profil.dart';

class StarRating extends StatelessWidget {
  final double note;

  const StarRating({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (note >= i + 1) {
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        } else if (note >= i + 0.5) {
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        } else {
          return const Icon(Icons.star_border, size: 16, color: Colors.amber);
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _topTutors = [];
  bool _isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTopTutors();
  }

  Future<void> _loadTopTutors() async {
    try {
      final user = await UserServices().getCurrentUser();
      currentUserId = user?.id;

      final etudiantSnap = await FirebaseFirestore.instance.collection('Etudiant').get();

      final liste = etudiantSnap.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
            final data = doc.data();
            final skills = data.containsKey("skills")
                ? List<String>.from(data["skills"])
                : <String>[];
            final note = (data["averageNote"] ?? 0.0).toDouble();

            return {
              "id": doc.id,
              "nom": data["Nom"] ?? '',
              "prenom": data["Prenom"] ?? '',
              "matieres": skills,
              "note": note,
            };
          })
          .toList();

      liste.sort((a, b) => (b["note"] as double).compareTo(a["note"] as double));

      if (mounted) {
        setState(() {
          _topTutors = liste;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Le classement des étudiants les mieux notés",
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _topTutors.isEmpty
                        ? const Center(child: Text("Aucun tuteur évalué pour le moment."))
                        : ListView.builder(
                            itemCount: _topTutors.length,
                            itemBuilder: (context, index) {
                              final tuteur = _topTutors[index];
                              final rank = index + 1;
                              
                              Color rankColor;
                              if (rank == 1) {
                                rankColor = const Color(0xFFFFD700); // Or
                              } else if (rank == 2) {
                                rankColor = const Color(0xFFC0C0C0); // Argent
                              } else if (rank == 3) {
                                rankColor = const Color(0xFFCD7F32); // Bronze
                              } else {
                                rankColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: rank <= 3 
                                    ? BorderSide(color: rankColor, width: 2) 
                                    : BorderSide.none,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 30,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "#$rank",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: rank <= 3 ? rankColor : textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        backgroundColor: rank <= 3 ? rankColor.withValues(alpha: 0.2) : null,
                                        child: Text(
                                          '${(tuteur["prenom"] as String)[0]}'
                                          '${(tuteur["nom"] as String)[0]}'
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: rank <= 3 ? rankColor : null,
                                            fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    "${tuteur["prenom"]} ${tuteur["nom"]}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          StarRating(note: tuteur["note"] as double),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${tuteur["note"]}/5",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: (tuteur["matieres"] as List<String>)
                                            .take(3) // Limiter l'affichage à 3 matières
                                            .map(
                                              (matiere) => Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? EnsiConnectApp.ensisaBlue.withValues(alpha: 0.3)
                                                      : EnsiConnectApp.ensisaLightBlue,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  matiere,
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
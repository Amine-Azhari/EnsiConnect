import 'package:flutter/material.dart';
// Importation de la page de paramètres
import "../widgets/ensiconnect_app.dart";
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/user_service.dart';
import 'profil.dart';
import 'dart:async';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

//Gestion des étoiles
class StarRating extends StatelessWidget {
  final double note;

  const StarRating({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _SearchPageState extends State<SearchPage> {
  String? currentUserId;
  String resultat = "";
  String recherche = "";
  Set<String> filtresSelectionnes = {};
  Timer? _debounce;

  List<String> filtres = [];

  final List<Map<String, dynamic>> tuteurs = [];

  @override
  void initState() {
    super.initState();
    initialiserPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> initialiserPage() async {
    await initUser();
    await chargerTuteurs();
  }

  //Utilisateur actuel
  Future<void> initUser() async {
    final userService = UserServices();
    final user = await userService.getCurrentUser();

    setState(() {
      currentUserId = user?.id;
    });
  }

  //Récupère les données dans Etudiant
  Future<void> chargerTuteurs() async {
    
    final etudiantSnap = await FirebaseFirestore.instance.collection('Etudiant').get();

    final Set<String> matieresUniques = {};

    final liste = etudiantSnap.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) {
          final skills = doc.data().containsKey("skills")
              ? List<String>.from(doc.data()["skills"])
              : <String>[];

          matieresUniques.addAll(skills);

          return {
            "id": doc.id,
            "nom": doc["Nom"],
            "prenom": doc["Prenom"],
            "matieres": skills,
            "note": (doc.data()["averageNote"] ?? 0.0).toDouble(),
          };
        })
        .toList();
    //Trier par note décroissantes
    liste.sort(
      (a, b) => (b["note"] as double).compareTo(a["note"] as double),
    );

    setState(() {
      tuteurs.clear();
      tuteurs.addAll(liste);

      //créé une liste sans répétition
      filtres = matieresUniques.toList()..sort();
    });
  }

  //Recherche lorsqu'il y a une pause
  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => recherche = val);
    });
  }

  
  List<Map<String, dynamic>> get tuteursFiltres {

    return tuteurs.where((tuteur) {
      
      final nom = (tuteur["nom"] as String).toLowerCase();
      final prenom = (tuteur["prenom"] as String).toLowerCase();
      final matieres = (tuteur["matieres"] as List<String>);

      // Filtres multiples
      final correspondFiltres =
          filtresSelectionnes.isEmpty ||
          matieres.any((m) => filtresSelectionnes.contains(m));

      // Recherche par nom ou matière
      final correspondRecherche =
          recherche.isEmpty ||
          nom.contains(recherche.toLowerCase()) ||
          prenom.contains(recherche.toLowerCase()) ||
          matieres.any(
            (m) => m.toLowerCase().contains(recherche.toLowerCase()),
          );

      return correspondFiltres && correspondRecherche;
    }).toList();



  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      key: _scaffoldKey,
      //Drawer
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Trouver un tuteur",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(height: 20),

              // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Rechercher une matière ou un tuteur...",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: hintColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filtres.map((filtre) {
                  final selected = filtresSelectionnes.contains(filtre);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filtre),
                      selected: selected,
                      selectedColor: Theme.of(context).brightness == Brightness.dark ? EnsiConnectApp.ensisaBlue : EnsiConnectApp.ensisaLightBlue,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            filtresSelectionnes.add(filtre);
                          } else {
                            filtresSelectionnes.remove(filtre);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${tuteursFiltres.length} tuteur(s)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            //Affichage tuteurs
            Expanded(
              child: tuteursFiltres.isEmpty
                ? const Center(
                    child: Text("Aucun tuteur trouvé"),
                  )
                :ListView.builder(
                  itemCount: tuteursFiltres.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${(tuteursFiltres[index]["prenom"] as String)[0]}${(tuteursFiltres[index]["nom"] as String)[0]}'.toUpperCase(),
                            ),
                        ),
                        title: Text("${tuteursFiltres[index]["prenom"]} ${tuteursFiltres[index]["nom"]}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: (tuteursFiltres[index]["matieres"] as List<String>)
                                  .map(
                                    (matiere) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? EnsiConnectApp.ensisaBlue
                                            : EnsiConnectApp.ensisaLightBlue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        matiere,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                            const SizedBox(height: 6),

                            //Affichage des étoiles
                            Row(
                              children: [
                                StarRating(note: tuteursFiltres[index]["note"] as double),
                                const SizedBox(width: 8),
                                Text(
                                  "${(tuteursFiltres[index]["note"]as double).toStringAsFixed(1)}/5",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        //redirection profil tuteur
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilPage(
                                userId: tuteursFiltres[index]["id"] as String,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              
            )
          ],
        ),
      ),
      ),
    );
  }
}
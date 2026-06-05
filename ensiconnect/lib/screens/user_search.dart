import 'package:flutter/material.dart';
// Importation de la page de paramètres
import '../main.dart'; // Pour accéder aux couleurs de l'app
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  String resultat = "";
  String recherche = "";
  Set<String> filtresSelectionnes = {};

  //temporaire
  final List<String> filtres = [
    "Programmation",
    "Mathématiques",
    "Réseaux",
    "SGBD",
  ];

  //temporaire
  final List<Map<String, dynamic>> tuteurs = [
    {
      "nom": "Amine",
      "matieres": ["Mathématiques", "SGBD"],
      "note": 4.5,
    },
    {
      "nom": "Ayoub",
      "matieres": ["Programmation"],
      "note": 4.0,
    },
    {
      "nom": "Alexis",
      "matieres": ["Réseaux","Mathématiques"],
      "note": 4.8,
    },
  ];

  
  List<Map<String, dynamic>> get tuteursFiltres {
    return tuteurs.where((tuteur) {
      final nom = (tuteur["nom"] as String).toLowerCase();
      final matieres = (tuteur["matieres"] as List<String>);

      // Filtres multiples
      final correspondFiltres =
          filtresSelectionnes.isEmpty ||
          matieres.any((m) => filtresSelectionnes.contains(m));

      // Recherche par nom ou matière
      final correspondRecherche =
          recherche.isEmpty ||
          nom.contains(recherche.toLowerCase()) ||
          matieres.any(
            (m) => m.toLowerCase().contains(recherche.toLowerCase()),
          );

      return correspondFiltres && correspondRecherche;
    }).toList();

    Widget buildStars(double note) {
      List<Widget> stars = [];

      for (int i = 1; i <= 5; i++) {
        if (note >= i) {
          stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
        } else if (note >= i - 0.5) {
          stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
        } else {
          stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
        }
      }

      return Row(children: stars);
    }
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
                onChanged: (value) {
                  setState(() {
                    recherche = value;
                  });
                },
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

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tuteurs recommandés",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(tuteursFiltres[index]["nom"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
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
                                      child: Text(matiere),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                buildStars((tuteursFiltres[index]["note"] as double)),
                                const SizedBox(width: 8),
                                Text("${tuteursFiltres[index]["note"]}/5"),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          print("Tuteur sélectionné : ${tuteursFiltres[index]["nom"]}");
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
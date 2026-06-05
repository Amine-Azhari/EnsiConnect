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
    },
    {
      "nom": "Ayoub",
      "matieres": ["Programmation"],
    },
    {
      "nom": "Alexis",
      "matieres": ["Réseaux","Mathématiques"],
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
                        subtitle: Wrap(
                          spacing: 6,
                          children: (tuteursFiltres[index]["matieres"] as List<String>)
                              .map(
                                (matiere) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark ? EnsiConnectApp.ensisaBlue : EnsiConnectApp.ensisaLightBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(matiere),
                                )
                              )
                              .toList(),
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
import 'package:flutter/material.dart';
import 'setting_page.dart'; // Importation de la page de paramètres
import '../main.dart'; // Pour accéder aux couleurs de l'app
import '../widgets/custom_drawer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  String resultat = "";
  String filtreSelectionne = "Toutes";

  //temporaire
  final List<String> filtres = [
    "Toutes",
    "Programmation",
    "Maths",
    "Réseaux",
    "Autre",
  ];

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
      "matieres": ["Réseaux"],
    },
  ];

  //temporaire
  List<Map<String, dynamic>> get tuteursFiltres {
    if (filtreSelectionne == "Toutes") return tuteurs;

    return tuteurs.where((t) {
      final matieres = t["matieres"] as List<String>;
      return matieres.contains(filtreSelectionne);
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
      //Titre
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Trouver un tuteur",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher une matière, un tuteur...",
                  hintStyle: TextStyle(color: hintColor, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: hintColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filtres.map((filtre) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filtre),
                      labelStyle: TextStyle(color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                      selected: filtreSelectionne == filtre,
                      selectedColor:Theme.of(context).brightness == Brightness.dark ? EnsiConnectApp.ensisaBlue : EnsiConnectApp.ensisaLightBlue,
                      onSelected: (selected) {
                        setState(() {
                          filtreSelectionne = filtre;
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
              child: ListView.builder(
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
                        children: (tuteursFiltres[index]["matieres"] as List)
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
    );
  }
}
import 'package:flutter/material.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String resultat = "";

  void rechercher(String texte) {
    setState(() {
      resultat = "Vous recherchez : $texte";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: rechercher,
              decoration: const InputDecoration(
                labelText: "Entrer un mot-clé",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              resultat,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
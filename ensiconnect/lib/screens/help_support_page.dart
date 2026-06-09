import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/user_service.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  // --- CONFIGURATION EMAILJS ---

  final String serviceId = 'service_jcl7t5m'; 
  final String templateId = 'template_g7s1joo';
  final String userId = 'fLLCWcUfgc0dwdZsY'; // Appelé "Public Key" sur EmailJS

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final currentUser = await UserServices().getCurrentUser();
        final userEmail = currentUser?.email ?? 'Email inconnu';
        final userName = currentUser?.fullName ?? 'Utilisateur inconnu';

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        
        final response = await http.post(
          url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'user_name': userName,
              'user_email': userEmail,
              'subject': _subjectController.text,
              'message': _messageController.text,
            }
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Votre message a été envoyé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            _subjectController.clear();
            _messageController.clear();
            Navigator.pop(context);
          }
        } else {
           debugPrint('Erreur EmailJS: \${response.body}');
           throw Exception('Échec de l\'envoi');
        }

      } catch (e) {
        debugPrint('Erreur: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'envoi du message. Veuillez vérifier votre connexion.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Contactez-nous',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Une question ou un problème ? Envoyez-nous un message et nous vous répondrons dans les plus brefs délais.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Sujet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subject),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un sujet.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre message.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Envoi en cours...' : 'Envoyer le message'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

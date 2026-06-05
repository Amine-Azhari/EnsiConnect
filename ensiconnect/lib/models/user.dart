class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String promotion;
  final String filiere;
  final String role;
  final String? profilePictureUrl;

  final String description;
  final List<String> skills;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.promotion = '1A',
    this.filiere = 'Informatique',
    this.role = 'Étudiant',
    this.profilePictureUrl,
    this.description = '',
    this.skills = const [],
  });

  String get fullName => '$firstName $lastName';
}
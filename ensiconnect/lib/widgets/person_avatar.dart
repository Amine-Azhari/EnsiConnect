import 'package:flutter/material.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20,
    this.fontSize,
  });

  static const List<Color> _palette = <Color>[
    Color(0xFFE4572E),
    Color(0xFF4C956C),
    Color(0xFF2E86AB),
    Color(0xFFF3A712),
    Color(0xFF7B6CF6),
  ];

  final String name;
  final String? imageUrl;
  final double radius;
  final double? fontSize;

  static String initialsForName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Color colorForName(String fullName) {
    final normalized = fullName.trim().toLowerCase();
    final index = normalized.isEmpty
        ? 0
        : normalized.codeUnits.fold<int>(0, (hash, unit) => hash + unit) %
            _palette.length;
    return _palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = colorForName(name);
    final trimmedImageUrl = imageUrl?.trim() ?? '';
    final hasImage = trimmedImageUrl.isNotEmpty;
    final ImageProvider<Object>? imageProvider = hasImage
        ? (trimmedImageUrl.startsWith('assets/')
            ? AssetImage(trimmedImageUrl) as ImageProvider<Object>
            : NetworkImage(trimmedImageUrl) as ImageProvider<Object>)
        : null;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        backgroundImage: imageProvider,
        child: hasImage
            ? null
            : Text(
                initialsForName(name),
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize ?? radius * 0.9,
                ),
              ),
      ),
    );
  }
}

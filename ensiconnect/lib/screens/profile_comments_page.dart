import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileCommentsPage extends StatelessWidget {
  const ProfileCommentsPage({
    super.key,
    required this.profileUserId,
    required this.profileName,
    required this.averageNote,
  });

  final String profileUserId;
  final String profileName;
  final double averageNote;

  Future<List<_ReviewItem>> _loadReviews() async {
    final snapshots = await Future.wait([
      FirebaseFirestore.instance
          .collection('Evaluation')
          .where('tutorId', isEqualTo: profileUserId)
          .get(),
      FirebaseFirestore.instance
          .collection('Evaluation')
          .where('tutorID', isEqualTo: profileUserId)
          .get(),
    ]);

    final seenIds = <String>{};
    final reviews = <_ReviewItem>[];

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (!seenIds.add(doc.id)) {
          continue;
        }

        final data = doc.data();
        final comment = (data['Commentaire'] ?? '').toString().trim();
        if (comment.isEmpty) {
          continue;
        }

        final authorId = (data['userId'] ?? data['EvaluateurID'] ?? '')
            .toString()
            .trim();
        final note = data['Note'];
        final authorName = await _loadAuthorName(authorId);

        reviews.add(
          _ReviewItem(
            authorName: authorName,
            comment: comment,
            note: note is num ? note.toDouble() : 0.0,
          ),
        );
      }
    }

    return reviews;
  }

  Future<String> _loadAuthorName(String authorId) async {
    if (authorId.isEmpty) {
      return 'Utilisateur inconnu';
    }

    final doc = await FirebaseFirestore.instance
        .collection('Etudiant')
        .doc(authorId)
        .get();
    final data = doc.data();
    if (data == null) {
      return 'Utilisateur inconnu';
    }

    final prenom = (data['Prenom'] ?? '').toString().trim();
    final nom = (data['Nom'] ?? '').toString().trim();
    final fullName = '$prenom $nom'.trim();
    return fullName.isEmpty ? 'Utilisateur inconnu' : fullName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? const Color(0xFFACB1BC) : Colors.black54;
    final cardColor = isDark ? const Color(0xD90A111C) : Colors.white;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF6F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF203047)
                        : const Color(0xFFF1F4FA),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.18)
                          : const Color(0xFF8FA5C7).withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0A400).withValues(
                          alpha: isDark ? 0.18 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.star_border_rounded,
                        color: Color(0xFFE0A400),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            averageNote.toStringAsFixed(1),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profileName.isEmpty
                                ? 'Note moyenne'
                                : 'Note moyenne de $profileName',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: mutedColor, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Commentaires',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<_ReviewItem>>(
                  future: _loadReviews(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Impossible de charger les commentaires.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    final reviews = snapshot.data ?? [];

                    if (reviews.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun commentaire pour le moment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final review = reviews[index];

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF203047)
                                  : const Color(0xFFF1F4FA),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.authorName,
                                      style: TextStyle(
                                        color: mutedColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE0A400,
                                      ).withValues(alpha: isDark ? 0.18 : 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFE0A400),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          review.note.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Color(0xFFE0A400),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                review.comment,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

class _ReviewItem {
  const _ReviewItem({
    required this.authorName,
    required this.comment,
    required this.note,
  });

  final String authorName;
  final String comment;
  final double note;
}

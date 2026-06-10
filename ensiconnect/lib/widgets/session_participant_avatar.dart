import '../widgets/person_avatar.dart';
import '../models/session_participant.dart';
import 'package:flutter/material.dart';

class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({
    super.key,
    required this.participant,
    required this.color,
  });

  final SessionParticipant participant;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // final imageUrl = participant.imageUrl;

    return PersonAvatar(
      name: participant.name,
      imageUrl: participant.imageUrl,
      radius: 24,
      fontSize: 16,
    );
  }
}
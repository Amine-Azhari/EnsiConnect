import 'package:flutter/material.dart';
import '../widgets/person_avatar.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.fullName,
    required this.filiere,
    required this.promotion,
    required this.profilePictureUrl,
    required this.isOwnProfile,
    required this.isEditing,
    required this.onActionPressed,
    required this.currentUserId,
    required this.profileUserId,
    required this.chatService,
  });

  final String fullName;
  final String filiere;
  final String promotion;
  final String profilePictureUrl;
  final bool isOwnProfile;
  final bool isEditing;
  final VoidCallback onActionPressed;
  final String currentUserId;
  final String profileUserId;
  final ChatService chatService;

  ButtonStyle _outlinedActionStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: isOwnProfile ? Colors.white : const Color(0xFF0B77E3),
      backgroundColor:
          isOwnProfile ? const Color(0xFF0B77E3) : Colors.transparent,
      side: const BorderSide(color: Color(0xFF0B77E3)),
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Widget _profileActionButton() {
  //   if (isOwnProfile) {
  //     return OutlinedButton.icon(
  //       onPressed: onActionPressed,// _toggleEdit,
  //       icon: Icon(
  //         isEditing ? Icons.save_outlined : Icons.edit_outlined,
  //         color: Colors.white,
  //       ),
  //       label: Text(isEditing ? "Sauvegarder" : "Modifier le profil"),
  //       style: _outlinedActionStyle(),
  //     );
  //   }

  //   return OutlinedButton.icon(
  //     onPressed: () async {
  //       final convoId = await chatService.getOrCreateConversation(
  //         participants: [
  //           currentUserId,
  //           profileUserId,// widget.userId!,
  //         ],
  //       );

  //       if (!context.mounted) return;

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => ConversationPage(
  //             conversation: Conversation(
  //               id: convoId,
  //               participants: [
  //                 currentUserId,
  //                 profileUserId,// widget.userId!,
  //               ],
  //               messages: const [],
  //               lastMessage: '',
  //               lastMessageAt: null,
  //               createdAt: null,
  //               name: null,
  //             ),
  //             currentUserId: currentUserId,
  //           ),
  //         ),
  //       );
  //     },
  //     icon: const Icon(Icons.chat_bubble_outline_rounded),
  //     label: const Text("Envoyer un message"),
  //     style: _outlinedActionStyle(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actionButton = isOwnProfile
        ? OutlinedButton.icon(
            onPressed: onActionPressed, // _toggleEdit,
            icon: Icon(
              isEditing ? Icons.save_outlined : Icons.edit_outlined,
              color: Colors.white,
            ),
            label: Text(isEditing ? "Sauvegarder" : "Modifier le profil"),
            style: _outlinedActionStyle(),
          )
        : OutlinedButton.icon(
            onPressed: () async {
              final convoId = await chatService.getOrCreateConversation(
                participants: [
                  currentUserId,
                  profileUserId, // widget.userId!,
                ],
              );

              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationPage(
                    conversation: Conversation(
                      id: convoId,
                      participants: [
                        currentUserId,
                        profileUserId, // widget.userId!,
                      ],
                      messages: const [],
                      lastMessage: '',
                      lastMessageAt: null,
                      createdAt: null,
                      name: null,
                    ),
                    currentUserId: currentUserId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text("Envoyer un message"),
            style: _outlinedActionStyle(),
          );
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF101A28) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF248BFF).withValues(alpha: 0.20),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: PersonAvatar(
                  name: fullName.isEmpty ? 'Profil' : fullName,
                  imageUrl: profilePictureUrl,
                  radius: 58,
                  fontSize: 40,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? 'Profil' : fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 25,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  actionButton, // _profileActionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

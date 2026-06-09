import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../models/conversation.dart';
import '../service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/user_service.dart';
import 'chat_messages.dart';
import '../models/user.dart';
import '../widgets/person_avatar.dart';
import "../widgets/ensiconnect_app.dart";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final chatService = ChatService();

  final UserServices _user = UserServices();

  final Map<String, String> _userNamesCache = {};

  final filters = ['Toutes', 'Solo' ,'Groupe'];

  var selectedFilter='Toutes';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(
          child: FutureBuilder<User?>(
        future: _user.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = userSnapshot.data!.id;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomHeader(
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(height: 20),
                Text(
                  "Vos messages",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),

                  const SizedBox(height: 10),

                  //Filtres
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final selected = selectedFilter.contains(filter);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: selected,
                            selectedColor: Theme.of(context).brightness == Brightness.dark ? EnsiConnectApp.ensisaBlue : EnsiConnectApp.ensisaLightBlue,
                            onSelected: (value) {
                              setState(() {
                                selectedFilter=filter;                                
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                    stream: chatService.getConversations(currentUserId),
                    builder: (context, snapshot) {
                      // Debug
                      print("state: ${snapshot.connectionState}");
                      print("hasData: ${snapshot.hasData}");
                      print("hasError: ${snapshot.hasError}");
                      print("data: ${snapshot.data}");

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text("Erreur de chargement"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Aucune conversation"));
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final participants =
                              List<String>.from(data['participants']);

                          final lastMessageAt =
                              (data['lastMessageAt'] as Timestamp?)?.toDate();

                          if(
                            (selectedFilter=='Solo' && data['name'] ==null) ||
                            (selectedFilter=='Groupe' && data['name'] !=null) ||
                            selectedFilter=='Toutes'
                          ){
                            return ListTile(
                              leading: FutureBuilder<String>(
                                future: data['name'] != null
                                    ? Future.value(data['name'])
                                    : getUserName(getOtherUser(participants, currentUserId)),
                                builder: (context, snapshot) {
                                  final name = snapshot.data ?? '?';
                                  return PersonAvatar(
                                    name: name,
                                  );
                                },
                              ),
                              title: FutureBuilder<String>(
                                future: data['name'] != null
                                    ? Future.value(data['name'])
                                    : getUserName(getOtherUser(participants, currentUserId)),
                                builder: (context, snapshot) {
                                  final name = snapshot.data ?? '...';

                                  return Text(name);
                                },
                              ),
                              subtitle: Text(
                                data['lastMessage'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,),
                              trailing: Text(
                                formatTimeAgo(lastMessageAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              
                              // Ouvre la page de la conversation sélectionée
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConversationPage(
                                      conversation:Conversation(
                                        id:docs[index].id,
                                        participants: participants,
                                        messages: const[],
                                        lastMessage: data['lastMessage'] ?? '',
                                        lastMessageAt: lastMessageAt,
                                        createdAt: null,
                                        name: data['name'],
                                      ),
                                      currentUserId: currentUserId,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      );
                    })
              ],
            ),
          );
        },
      )),
    );
  }

  Future<String> getUserName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }

    final user = await chatService.getUserById(userId);

    final name = user?.fullName ?? userId;

    _userNamesCache[userId] = name;

    return name;
  }
}

String getOtherUser(List<String> participants, String currentUserId) {
  return participants.firstWhere(
    (p) => p != currentUserId,
    orElse: () => participants.first,
  );
}

String formatTimeAgo(DateTime? date) {
  if (date == null) return '';

  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) {
    return "À l'instant";
  }

  if (difference.inHours < 1) {
    return "Il y a ${difference.inMinutes} min";
  }

  if (difference.inDays < 1) {
    return "Il y a ${difference.inHours} h";
  }

  return "Il y a ${difference.inDays} j";
}

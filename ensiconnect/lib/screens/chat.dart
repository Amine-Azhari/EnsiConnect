import '../main.dart';
import 'package:flutter/material.dart';
import 'setting_page.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatPage extends StatefulWidget{
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      key: _scaffoldKey, 
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(height: 20),
              Text(
                "Vos messages",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];



                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(convo.participants[0][0].toUpperCase()),
                    ),
                    title: Text(convo.participants[0]),
                    subtitle: Text(convo.lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Conversation(
                            conversation:convo,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: Text(userName),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      body:Container(
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: 61,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(35.0),
              border: Border.all(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.face,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    // onChanged: ,
                    decoration: InputDecoration(
                      hintText: "Votre message",
                      hintStyle: TextStyle(
                        color: EnsiConnectApp.ensisaBlue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  // onPressed : ,
                  icon: Icon(
                    Icons.send,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<Conversation> conversations = [
  Conversation(
    id: "c1",
    participants: ["user1", "user2"],
    lastMessage: "Salut, ça va",
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    messages: [
      Message(
        senderId: "user2",
        content: "Salut !",
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        senderId: "user1",
        content: "Salut, ça va",
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  ),

  Conversation(
    id: "c2",
    participants: ["user1", "user3"],
    lastMessage: "J'ai faim",
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    messages: [
      Message(
        senderId: "user3",
        content: "Tu fais quoi ?",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        senderId: "user1",
        content: "Rien de spécial",
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Message(
        senderId: "user3",
        content: "J'ai faim",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),

  Conversation(
    id: "c3",
    participants: ["user1", "user4"],
    lastMessage: ":) 👍",
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    messages: [
      Message(
        senderId: "user4",
        content: "On révise ensemble demain ?",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        senderId: "user1",
        content: "Oui carrément",
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        senderId: "user4",
        content: ":) 👍",
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  ),
];

String getOtherUser(List<String> participants, String currentUserId) {
  return participants.firstWhere(
    (p) => p != currentUserId,
    orElse: () => participants.first,
  );
}
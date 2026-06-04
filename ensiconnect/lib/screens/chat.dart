import '../main.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_notification_button.dart';


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
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      key: _scaffoldKey, 
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: EnsiConnectApp.ensisaBlue),
              child: Text(
                'EnsiConnect',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context); // Ferme le Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()), 
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Aide & Support'),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(), 
                    icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark ? [] : [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_none_rounded, color: textColor),
                    ),
                  ),
                ],
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
                      child: Text(convo.name[0]),
                    ),
                    title: Text(convo.name),
                    subtitle: Text(convo.lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Conversation(
                            userName: convo.name,
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

class Conversation extends StatelessWidget {
  final String userName;

  const Conversation({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      body:Container(
      ) ,
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

class ConversationModel {
  final String name;
  final String lastMessage;

  ConversationModel({
    required this.name,
    required this.lastMessage,
  });
}

class Message {
  final String content;
  

  Message({
    required this.content,
  });
}

final List<ConversationModel> conversations = [
  ConversationModel(name: "Moi", lastMessage: "Salut"),
  ConversationModel(name: "wsgdhrh", lastMessage: "J'ai faim"),
  ConversationModel(name: "La personne à côté de moi", lastMessage: ":) 👍"),
];
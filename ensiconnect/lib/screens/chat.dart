import 'setting_page.dart';
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
      drawer: const CustomDrawer(),
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
                  const CustomNotificationButton(),
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
      body: Column(
        children: [
          // Cet Expanded prend tout l'espace vide disponible et repousse la barre de texte en bas.
          // C'est ici que tu mettras ta ListView avec les vrais messages plus tard !
          Expanded(
            child: Container(),
          ),
          Container(
            margin: const EdgeInsets.all(15.0),
            height: 61,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.face, color: EnsiConnectApp.ensisaBlue), onPressed: () {}),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Votre message",
                          hintStyle: TextStyle(color: EnsiConnectApp.ensisaBlue),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.blueAccent),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: EnsiConnectApp.ensisaBlue),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          ),
        ],
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

final List<ConversationModel> conversations = [
  ConversationModel(name: "Moi", lastMessage: "Salut"),
  ConversationModel(name: "wsgdhrh", lastMessage: "J'ai faim"),
  ConversationModel(name: "La personne à côté de moi", lastMessage: ":) 👍"),
];
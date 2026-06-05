import '../main.dart';
import 'package:flutter/material.dart';
import 'setting_page.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../models/message.dart';

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
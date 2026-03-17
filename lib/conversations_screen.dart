import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/providers/conversation_provider.dart';
import 'package:flutter_maps/widgets/size_config.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:flutter_maps/widgets/cards/conversation_card.dart';
import 'package:flutter_maps/chat_screen.dart';
import 'package:provider/provider.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    var provider = Provider.of<ConversationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Style.darkColor,
        title: const Text('Conversations'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            // ممكن تضيف وظيفة البحث هنا لاحقًا
          },
          icon: const Icon(Icons.search),
        ),
      ),
      body: Center(
        child: provider.busy
            ? const CircularProgressIndicator(
          color: Colors.white,
        )
            : provider.concersations.isEmpty
            ? const Text(
          "No conversations yet",
          style: TextStyle(color: Colors.white),
        )
            : ListView.builder(
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical * 2,
          ),
          itemCount: provider.concersations.length,
          itemBuilder: (context, index) => ConversationCard(
            conversation: provider.concersations[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
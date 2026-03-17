import 'dart:convert';

import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter_maps/providers/conversation_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'conversations_screen.dart';

class MainScreen extends StatefulWidget {
  static final routeName = 'main';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  @override
  initState() {
    super.initState();

    notification();
  }

  void notification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        handleNotification(message.data, false);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {}
    });
  }

  handleNotification(data, bool push) {
    var messageJson = json.decode(data['message']);
    var message = MessageModal.fromJson(messageJson);
    Provider.of<ConversationProvider>(
      context,
    ).addMessageToConversation(message.conversationId, message);
  }

  final PageController _pageController = new PageController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConversationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: <Widget>[
              ConversationsScreen(),
              Container(color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

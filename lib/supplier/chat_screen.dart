import 'dart:convert';
import 'dart:async';
import 'package:flutter_maps/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_maps/classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:flutter_maps/widgets/cards/friend_message_card.dart';
import 'package:flutter_maps/widgets/cards/my_message_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_maps/lang.dart';

class SuChatScreen extends StatefulWidget {
  const SuChatScreen({Key? key}) : super(key: key);

  @override
  _SuChatScreenState createState() => _SuChatScreenState();
}

class _SuChatScreenState extends State<SuChatScreen> {
  TextEditingController messageTextEditController = TextEditingController();

  late ScrollController _scrollController;
  bool _scrolled = false;
  bool _isSending = false;

  List<dynamic>? messages;

  Future<List<dynamic>?> getMessages() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? token = preferences.getString("token");
    if (token == null) return null;

    final chat = ModalRoute.of(context)!.settings.arguments as Chat;

    try {
      int id = int.parse(chat.conservistion_id, radix: 10);

      String url =
          "https://www.ordervite.com/api/supplier/order/$id/messages/shipper";

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var responseBody = jsonDecode(response.body);

      if (responseBody["data"] != null) {
        setState(() {
          messages = responseBody["data"]["order message"] as List<dynamic>;
        });
        return messages;
      }

      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrolled = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageTextEditController.dispose();
    super.dispose();
  }

  void _sendMessage(Chat chat, Lang lang) async {
    FocusScope.of(context).requestFocus(FocusNode());

    final messageText = messageTextEditController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    if (token == null) {
      setState(() {
        _isSending = false;
      });
      return;
    }

    int id = int.parse(chat.conservistion_id, radix: 10);

    String url =
        "https://www.ordervite.com/api/supplier/order/messages/store/$id";

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          "user_id": chat.supplier_id.toString(),
          "type": "supplier",
          "body": messageText,
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        messageTextEditController.clear();
        setState(() {
          _scrolled = false; // To scroll to new message
          messages = null; // Trigger reload
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang.lang == "en"
                  ? "Failed to send message"
                  : "فشل في إرسال الرسالة",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.lang == "en" ? "Network error" : "خطأ في الشبكة"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    final chat = ModalRoute.of(context)!.settings.arguments as Chat;

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              OrderDist orderDist = OrderDist(
                chat.disLat.toString(),
                chat.sorLat.toString(),
                chat.disLong.toString(),
                chat.sorlong.toString(),
                true,
                chat.conservistion_id.toString(),
                chat.order_cost.toString(),
                chat.order_price.toString(),
                chat.order_pricecheck.toString(),
                chat.order_state.toString(),
                chat.order_shippier_id.toString(),
              );

              Navigator.pushNamed(context, "orderscreen", arguments: orderDist);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            lang.lang == "en"
                ? '${chat.supplier_name} | Order ${chat.conservistion_id}'
                : '${chat.supplier_name} | طلب شحن ${chat.conservistion_id}',
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>?>(
                future: getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        lang.lang == "en"
                            ? "Error loading messages"
                            : "خطأ في تحميل الرسائل",
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_scrolled && _scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                        _scrolled = true;
                      }
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final messageData = snapshot.data![index];
                        final messageText = messageData["body"].toString();
                        final messageType = messageData["type"].toString();
                        final messageModal = MessageModal(body: messageText);
                        if (messageType == "supplier") {
                          return MyMessageCard(message: messageModal);
                        } else {
                          return FriendMessageCard(message: messageModal);
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        lang.lang == "en" ? "No messages" : "لا توجد رسائل",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Style.darkColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: messageTextEditController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: lang.lang == "en"
                            ? 'Type your message...'
                            : '....أكتب رسالتك ',
                        hintStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _isSending ? null : () => _sendMessage(chat, lang),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

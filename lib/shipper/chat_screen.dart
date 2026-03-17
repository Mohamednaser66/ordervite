import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';

import 'package:flutter_maps/models/message_model.dart';

import 'package:flutter_maps/widgets/style.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ShChatScreen extends StatefulWidget {
  const ShChatScreen({Key? key}) : super(key: key);

  @override
  _ShChatScreenState createState() => _ShChatScreenState();
}

class _ShChatScreenState extends State<ShChatScreen> {
  TextEditingController messageTextEditController = TextEditingController();

  MessageModal? message;
  ScrollController _scrollController = ScrollController();

  late StreamController _messageController;
  var data;

  Future getMessges() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? token = preferences.getString("token");

    Chat chat = ModalRoute.of(context)?.settings.arguments as Chat;
    try {
      int id = int.parse(chat.conservistion_id, radix: 10);

      String Url =
          "https://www.ordervite.com/api/shippier/order/$id/messages/supplier";

      var response = await http.get(
        Uri.parse(Url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',

          'Authorization': 'Bearer $token',
        },
      );

      var reposnsebody = jsonDecode(response.body);

      if (reposnsebody["data"] != null) {
        setState(() {
          this.data = reposnsebody["data"]["order message"];
        });

        message?.conversationId = int.parse(
          chat.conservistion_id.toString(),
          radix: 10,
        );
      }

      return this.data;
    } catch (e) {
      return this.data;
    }
  }

  loadMessage() async {
    getMessges().then((res) async {
      _messageController.add(res);
      return res;
    });
  }

  @override
  void initState() {
    _messageController = StreamController();
    loadMessage();

    message = MessageModal();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Chat chat = ModalRoute.of(context)?.settings.arguments as Chat;
    Lang lang = Lang.of(context);
    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        backgroundColor: Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              OrderData orderData = new OrderData(
                chat.disLat.toString(),
                chat.sorLat.toString(),
                chat.disLong.toString(),
                chat.sorlong.toString(),
                chat.conservistion_id.toString(),
                true,
                chat.order_cost.toString(),
                chat.order_price.toString(),
                chat.order_pricecheck.toString(),
                chat.order_state.toString(),
                chat.order_supplier_id.toString(),
              );
              Navigator.pushNamed(context, "shorder", arguments: orderData);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            lang.lang == "en"
                ? '${chat.shippier_name} | Order  ${chat.conservistion_id}'
                : '${chat.shippier_name} | طلب شحن  ${chat.conservistion_id}',
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                future: getMessges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data[index]["type"].toString() ==
                            "shipper") {
                          return Align(
                            alignment: Alignment.centerRight,

                            child: Container(
                              width: 150,
                              padding: EdgeInsets.all(14),
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  topRight: Radius.circular(28),
                                  bottomLeft: Radius.circular(28),
                                ),
                              ),

                              child: Column(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          snapshot.data[index]["body"]
                                              .toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 150,
                              padding: EdgeInsets.all(14),
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  topRight: Radius.circular(28),
                                  bottomRight: Radius.circular(28),
                                ),
                              ),

                              child: Column(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          snapshot.data[index]["body"]
                                              .toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        lang.lang == "en"
                            ? "Network missed"
                            : "تحقق من جوده الانترنت ",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Style.darkColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: messageTextEditController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: lang.lang == "en"
                            ? 'Type your message...'
                            : '....أكتب رسالتك ',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      if (messageTextEditController.text.isEmpty) return;
                      message?.body = messageTextEditController.text.trim();

                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      String? token = preferences.getString("token");

                      Chat? chat =
                          ModalRoute.of(context)?.settings.arguments as Chat;
                      try {
                        int id = int.parse(
                          chat.conservistion_id.toString(),
                          radix: 10,
                        );
                        final url =
                            "https://www.ordervite.com/api/shippier/order/messages/store/$id";
                        var response = await http.post(
                          Uri.parse(url),
                          body: {
                            "user_id": chat.shippier_id.toString(),
                            "type": "shipper",
                            "body": messageTextEditController.text.trim(),
                          },

                          headers: {'Authorization': 'Bearer  ' + token!},
                        );

                        jsonDecode(response.body);

                        String api_token = chat.api_token.toString();
                        String message_id = chat.conservistion_id.toString();

                        String Url3 =
                            "https://www.ordervite.com/api/notify/page/ordervite/you have new message for your order $message_id/$api_token/1/ordervite/shipper/new message";

                        await http.get(
                          Uri.parse(Url3),
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'Authorization': 'Bearer  ' + token,
                          },
                        );
                      } catch (e) {}

                      messageTextEditController.clear();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.grey,
                      ),
                      child: Icon(Icons.send),
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

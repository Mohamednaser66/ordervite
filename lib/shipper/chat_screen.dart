import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShChatScreen extends StatefulWidget {
  const ShChatScreen({Key? key}) : super(key: key);

  @override
  _ShChatScreenState createState() => _ShChatScreenState();
}

class _ShChatScreenState extends State<ShChatScreen> {
  final TextEditingController messageTextEditController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Chat? _chat;
  Future<List<dynamic>>? _messagesFuture;
  bool _isInitialized = false;
  bool _isSending = false;

  Future<List<dynamic>> _fetchMessages() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("token");

    if (token == null || token.isEmpty || _chat == null) {
      return [];
    }

    try {
      final id = int.tryParse(_chat!.conservistion_id) ?? -1;
      if (id < 0) return [];

      final url =
          "https://www.ordervite.com/api/shippier/order/$id/messages/supplier";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = jsonDecode(response.body);
      final messages = responseBody["data"]?["order message"];
      if (messages is List) {
        return messages;
      }
    } catch (_) {
      // ignore: avoid_print
      print('Failed to load messages');
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Chat) {
      _chat = args;
      _messagesFuture = _fetchMessages();
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    messageTextEditController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final lang = Lang.of(context);

    if (chat == null) {
      return Directionality(
        textDirection: lang.lang == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(lang.lang == "en" ? 'Chat' : 'محادثة')),
          body: Center(
            child: Text(
              lang.lang == "en"
                  ? 'Chat data unavailable'
                  : 'بيانات المحادثة غير متاحة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        backgroundColor: Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                return;
              }

              final chatData = _chat;
              if (chatData == null) return;

              final orderData = OrderData(
                chatData.disLat.toString(),
                chatData.sorLat.toString(),
                chatData.disLong.toString(),
                chatData.sorlong.toString(),
                chatData.conservistion_id.toString(),
                true,
                chatData.order_cost.toString(),
                chatData.order_price.toString(),
                chatData.order_pricecheck.toString(),
                chatData.order_state.toString(),
                chatData.order_supplier_id.toString(),
              );

              Navigator.pushNamed(
                context,
                RoutesManager.shOrder,
                arguments: orderData,
              );
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
              child: FutureBuilder<List<dynamic>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        lang.lang == "en"
                            ? "Failed to load messages"
                            : "فشل في تحميل الرسائل",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        lang.lang == "en"
                            ? 'No messages yet'
                            : 'لا توجد رسائل بعد',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 6.h,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final item = messages[index] as Map<String, dynamic>;
                      final messageType = item["type"]?.toString() ?? "";
                      final messageBody = item["body"]?.toString() ?? "";
                      if (messageType == "shipper") {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 150.w,
                            padding: EdgeInsets.all(14.r),
                            margin: EdgeInsets.only(bottom: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(28.r),
                                topRight: Radius.circular(28.r),
                                bottomLeft: Radius.circular(28.r),
                              ),
                            ),
                            child: Text(messageBody),
                          ),
                        );
                      }
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 150.w,
                          padding: EdgeInsets.all(14.r),
                          margin: EdgeInsets.only(bottom: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28.r),
                              topRight: Radius.circular(28.r),
                              bottomRight: Radius.circular(28.r),
                            ),
                          ),
                          child: Text(messageBody),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(12.r),
              margin: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Style.darkColor,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 12.w),
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
                    onTap: _isSending
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();

                            final messageText = messageTextEditController.text
                                .trim();
                            if (messageText.isEmpty || _chat == null) return;

                            final preferences =
                                await SharedPreferences.getInstance();
                            final token = preferences.getString("token");
                            final chatData = _chat;

                            if (token == null ||
                                token.isEmpty ||
                                chatData == null)
                              return;
                            if (chatData.shippier_id == null ||
                                chatData.shippier_id!.isEmpty)
                              return;

                            setState(() => _isSending = true);

                            try {
                              final id =
                                  int.tryParse(chatData.conservistion_id) ?? -1;
                              if (id < 0) return;

                              final url =
                                  "https://www.ordervite.com/api/shippier/order/messages/store/$id";
                              await http.post(
                                Uri.parse(url),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Accept': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode({
                                  "user_id": chatData.shippier_id,
                                  "type": "shipper",
                                  "body": messageText,
                                }),
                              );

                              final apiToken = chatData.api_token;
                              final messageId = chatData.conservistion_id;
                              final notifyUrl =
                                  "https://www.ordervite.com/api/notify/page/ordervite/you have new message for your order $messageId/$apiToken/1/ordervite/shipper/new message";

                              await http.get(
                                Uri.parse(notifyUrl),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Accept': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                              );

                              messageTextEditController.clear();
                              setState(() {
                                _messagesFuture = _fetchMessages();
                              });
                            } catch (e) {
                              debugPrint('Failed to send chat message: $e');
                            } finally {
                              if (mounted) {
                                setState(() => _isSending = false);
                              }
                            }
                          },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: _isSending
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(Icons.send),
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

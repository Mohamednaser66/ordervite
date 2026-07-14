import 'dart:convert';
import 'dart:async';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_maps/classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:flutter_maps/widgets/cards/friend_message_card.dart';
import 'package:flutter_maps/widgets/cards/my_message_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuChatScreen extends StatefulWidget {
  const SuChatScreen({Key? key}) : super(key: key);

  @override
  _SuChatScreenState createState() => _SuChatScreenState();
}

class _SuChatScreenState extends State<SuChatScreen> {
  final TextEditingController messageTextEditController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Chat? _chat;
  Future<List<Map<String, dynamic>>>? _messagesFuture;
  bool _isInitialized = false;
  bool _isSending = false;

  Future<List<Map<String, dynamic>>> _fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final chat = _chat;

    if (token == null || token.isEmpty || chat == null) {
      return [];
    }

    final id = int.tryParse(chat.conservistion_id) ?? -1;
    if (id < 0) return [];

    try {
      final url =
          "https://www.ordervite.com/api/supplier/order/$id/messages/shipper";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final responseBody = jsonDecode(response.body);
      final rawMessages = responseBody["data"]?["order message"];
      if (rawMessages is List) {
        return rawMessages.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Failed to load supplier messages: $e');
    }

    return [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Chat) {
      _chat = args;
      _messagesFuture = _fetchMessages();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageTextEditController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage(Chat chat, Lang lang) async {
    FocusScope.of(context).requestFocus(FocusNode());

    final messageText = messageTextEditController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null || token.isEmpty) {
      setState(() => _isSending = false);
      return;
    }

    final id = int.tryParse(chat.conservistion_id) ?? -1;
    if (id < 0) {
      setState(() => _isSending = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          "https://www.ordervite.com/api/supplier/order/messages/store/$id",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "user_id": chat.supplier_id.toString(),
          "type": "supplier",
          "body": messageText,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        messageTextEditController.clear();
        setState(() {
          _messagesFuture = _fetchMessages();
        });
        _scrollToBottom();
      } else {
        if (!mounted) return;
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
      debugPrint('send supplier chat message error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.lang == "en" ? "Network error" : "خطأ في الشبكة"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final chat = _chat;

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
        backgroundColor: const Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              OrderDist orderDist = OrderDist(
                chat.disLat.toString(),
                chat.sorLat.toString(),
                chat.disLong.toString(),
                chat.sorlong.toString(),
                chat.isConfirm,
                chat.conservistion_id.toString(),
                chat.order_cost.toString(),
                chat.order_price.toString(),
                chat.order_pricecheck.toString(),
                chat.order_state.toString(),
                chat.order_shippier_id.toString(),
              );

              Navigator.pushNamed(
                context,
                RoutesManager.orderPage,
                arguments: orderDist,
              );
            },
            icon: Icon(Icons.arrow_back_ios),
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        lang.lang == "en"
                            ? "Error loading messages"
                            : "خطأ في تحميل الرسائل",
                        style: TextStyle(fontSize: 18.sp, color: Colors.red),
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        lang.lang == "en" ? "No messages" : "لا توجد رسائل",
                        style: TextStyle(fontSize: 18.sp, color: Colors.white),
                      ),
                    );
                  }

                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.h.w,
                      vertical: 6.h,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index];
                      final messageText = messageData["body"]?.toString() ?? '';
                      final messageType = messageData["type"]?.toString() ?? '';
                      final messageModal = MessageModal(body: messageText);
                      if (messageType == "supplier") {
                        return MyMessageCard(message: messageModal);
                      }
                      return FriendMessageCard(message: messageModal);
                    },
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(14.r),
              margin: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Style.darkColor,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Row(
                children: [
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
                    onTap: _isSending ? null : () => _sendMessage(chat, lang),
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

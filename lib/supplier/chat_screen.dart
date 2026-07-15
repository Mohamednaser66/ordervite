import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_maps/supplier/supplier_chat_cubit/supplier_chat_cubit.dart';

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
  bool _isInitialized = false;
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Chat) {
      _chat = args;
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    messageTextEditController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
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
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return BlocProvider<SupplierChatCubit>(
      create: (context) {
        final cubit = SupplierChatCubit();
        SharedPreferences.getInstance().then((preferences) {
          final token = preferences.getString("token") ?? "";
          if (token.isNotEmpty) {
            cubit.loadMessages(orderId: chat.conservistion_id, token: token);
            cubit.startPolling(orderId: chat.conservistion_id, token: token);
          }
        });
        return cubit;
      },
      child: Builder(
        builder: (context) {
          return Directionality(
            textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color.fromRGBO(21, 42, 72, 0.9),
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      return;
                    }

                    final chatData = _chat;
                    if (chatData == null) return;

                    final orderDist = OrderDist(
                      chatData.disLat.toString(),
                      chatData.sorLat.toString(),
                      chatData.disLong.toString(),
                      chatData.sorlong.toString(),
                      chatData.isConfirm,
                      chatData.conservistion_id.toString(),
                      chatData.order_cost.toString(),
                      chatData.order_price.toString(),
                      chatData.order_pricecheck.toString(),
                      chatData.order_state.toString(),
                      chatData.order_shippier_id.toString(),
                    );

                    Navigator.pushNamed(
                      context,
                      RoutesManager.orderPage,
                      arguments: orderDist,
                    );
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
                children: <Widget>[
                  Expanded(
                    child: BlocConsumer<SupplierChatCubit, SupplierChatState>(
                      listener: (context, state) {
                        if (state is SupplierChatLoaded) {
                          _scrollToBottom();
                        }
                      },
                      builder: (context, state) {
                        if (state is SupplierChatLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is SupplierChatError) {
                          return Center(
                            child: Text(
                              lang.lang == "en"
                                  ? "Failed to load messages"
                                  : "فشل في تحميل الرسائل",
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (state is SupplierChatLoaded) {
                          final messages = state.messages;

                          if (messages.isEmpty) {
                            return Center(
                              child: Text(
                                lang.lang == "en"
                                    ? 'No messages yet'
                                    : 'لا توجد رسائل بعد',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          _scrollToBottom();

                          return ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 6.h,
                            ),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final item = messages[index];
                              final messageType = item["type"]?.toString() ?? "";
                              final messageBody = item["body"]?.toString() ?? "";

                              if (messageType == "supplier") {
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
                                    child: Text(
                                      messageBody,
                                      style: const TextStyle(color: Colors.white),
                                    ),
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
                                  child: Text(
                                    messageBody,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
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
                          onTap: _isSending
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();

                                  final messageText =
                                      messageTextEditController.text.trim();
                                  if (messageText.isEmpty || _chat == null)
                                    return;

                                  final preferences =
                                      await SharedPreferences.getInstance();
                                  final token = preferences.getString("token");
                                  final chatData = _chat;

                                  if (token == null ||
                                      token.isEmpty ||
                                      chatData == null) return;
                                  if (chatData.supplier_id == null ||
                                      chatData.supplier_id!.isEmpty) return;

                                  setState(() => _isSending = true);

                                  try {
                                    final success = await context
                                        .read<SupplierChatCubit>()
                                        .sendMessage(
                                          orderId: chatData.conservistion_id,
                                          token: token,
                                          supplierId: chatData.supplier_id!,
                                          messageText: messageText,
                                          shipperApiToken: chatData.api_token,
                                        );

                                    if (success) {
                                      messageTextEditController.clear();
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        'Failed to send supplier chat message: $e');
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSending = false);
                                    }
                                  }
                                },
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: _isSending
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
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
        },
      ),
    );
  }
}

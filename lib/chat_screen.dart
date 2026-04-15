import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/widgets/style.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController ;
  late ScrollController _scrollController;

  final List<Map<String, dynamic>> _messages = [];
  Chat? _chat;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_chat != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Chat) {
      _chat = args;
      _loadMessages();
      return;
    }

    setState(() {
      _error = 'خطأ: لم يتم العثور على بيانات المحادثة';
    });
  }

  Future<void> _loadMessages() async {
    if (_chat == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final fetched = await _fetchMessages();

    setState(() {
      _isLoading = false;
      if (fetched == null) {
        _error = 'تعذر تحميل الرسائل. حاول مرة أخرى.';
      } else {
        _messages
          ..clear()
          ..addAll(fetched);
        _error = null;
      }
    });
    _scrollToBottom();
  }

  Future<List<Map<String, dynamic>>?> _fetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final chat = _chat;
      if (token == null || chat == null) return null;
      final id = int.tryParse(chat.conservistion_id);
      if (id == null) return null;
      final url = 'https://www.ordervite.com/api/supplier/order/$id/messages';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('fetchMessages status: ${response.statusCode}');
        return null;
      }

      final body = jsonDecode(response.body);
      final raw = body['data']?['order message'];
      if (raw is! List) return null;

      return raw.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('fetchMessages error: $e');
      return null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_chat == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'body': text, 'type': 'supplier'});
      _messageController.clear();
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final chat = _chat;

      if (token == null || chat == null) return;

      final url =
          'https://www.ordervite.com/api/supplier/order/messages/store/${chat.conservistion_id}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'user_id': chat.supplier_id.toString(),
          'type': 'supplier',
          'body': text,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('sendMessage error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إرسال الرسالة. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }

    final title = _chat?.supplier_name ?? 'الدردشة';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMessages,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children:  [
            SizedBox(height: 200.h),
            Center(
              child: Text(
                'لا توجد رسائل بعد.\nاسحب لأسفل للتحديث.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(12.r),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => SizedBox(height: 6.h),
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isMe = message['type']?.toString() == 'supplier';
          final body = message['body']?.toString() ?? '';
          return _buildChatBubble(body, isMe);
        },
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 1.h.w, vertical: 1.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Style.darkColor : Colors.grey[700],
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(20.r),
            topRight:  Radius.circular(20.r),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 8.h),
      margin: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Style.darkColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSending
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
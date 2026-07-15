import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:http/http.dart' as http;

part 'supplier_chat_state.dart';

class SupplierChatCubit extends Cubit<SupplierChatState> {
  Timer? _pollTimer;
  List<Map<String, dynamic>> _currentMessages = [];

  SupplierChatCubit() : super(SupplierChatInitial());

  Future<List<Map<String, dynamic>>?> _fetchMessages(String orderId, String token) async {
    try {
      final id = int.tryParse(orderId) ?? -1;
      if (id < 0) return [];

      final url = "${AppConfig.baseUrl}/supplier/order/$id/messages/shipper";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final responseBody = jsonDecode(response.body);
      final rawMessages = responseBody["data"]?["order message"];
      if (rawMessages is List) {
        return rawMessages.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch messages: $e');
    }
    return null;
  }

  Future<void> loadMessages({required String orderId, required String token}) async {
    emit(SupplierChatLoading());
    final messages = await _fetchMessages(orderId, token);
    if (messages != null) {
      _currentMessages = messages;
      emit(SupplierChatLoaded(List.from(_currentMessages)));
    } else {
      emit(SupplierChatError("Failed to load messages"));
    }
  }

  void startPolling({required String orderId, required String token, int intervalSeconds = 5}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      final messages = await _fetchMessages(orderId, token);
      if (messages != null && !isClosed) {
        // Compare lists to avoid unnecessary emissions
        if (_hasMessagesChanged(_currentMessages, messages)) {
          _currentMessages = messages;
          emit(SupplierChatLoaded(List.from(_currentMessages)));
        }
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool _hasMessagesChanged(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return true;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i]['body'] != list2[i]['body'] || list1[i]['type'] != list2[i]['type']) {
        return true;
      }
    }
    return false;
  }

  Future<bool> sendMessage({
    required String orderId,
    required String token,
    required String supplierId,
    required String messageText,
    required String shipperApiToken,
  }) async {
    try {
      final id = int.tryParse(orderId) ?? -1;
      if (id < 0) return false;

      final url = "${AppConfig.baseUrl}/supplier/order/messages/store/$id";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "user_id": supplierId,
          "type": "supplier",
          "body": messageText,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Send notification if shipper token is present
        if (shipperApiToken.isNotEmpty) {
          final notifyUrl =
              "${AppConfig.baseUrl}/notify/page/ordervite/you have new message for your order $orderId/$shipperApiToken/1/ordervite/supplier/new message";
          try {
            await http.get(
              Uri.parse(notifyUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            ).timeout(const Duration(seconds: 10));
          } catch (e) {
            debugPrint('Failed to send message notification: $e');
          }
        }

        // Fetch messages immediately to update the list
        final messages = await _fetchMessages(orderId, token);
        if (messages != null) {
          _currentMessages = messages;
          emit(SupplierChatLoaded(List.from(_currentMessages)));
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
    return false;
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}

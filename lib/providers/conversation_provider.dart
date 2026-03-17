import 'dart:convert';

import 'package:flutter_maps/models/conversation_model.dart';
import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter_maps/providers/base_provider.dart';
import 'package:flutter_maps/services/conversation_service.dart';

class ConversationProvider extends BaseProvider {
  final ConversationService _conversationService = ConversationService();

  List<ConversationModel> _concersations = [];
  List<ConversationModel> get concersations => _concersations;

  Future<List<ConversationModel>> getConversations() async {
    if (_concersations.isNotEmpty) return _concersations;

    try {
      setBusy(true);

      var response = await _conversationService.getConversations();

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        _concersations.clear();

        for (var conversation in data['data']) {
          _concersations.add(
              ConversationModel.fromJson(conversation));
        }

        notifyListeners();
      }
    } finally {
      setBusy(false);
    }

    return _concersations;
  }

  Future<void> storeMessage(MessageModal message) async {
    try {
      setBusy(true);

      var response =
      await _conversationService.storeMessage(message);

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);

        addMessageToConversation(
          message.conversationId,
          MessageModal.fromJson(data['data']),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  void addMessageToConversation(
      int? conversationId, MessageModal message) {
    if (conversationId == null) return;

    var conversation = _concersations
        .where((c) => c.id == conversationId)
        .toList();

    if (conversation.isEmpty) return;

    var conv = conversation.first;

    conv.messages ??= [];
    conv.messages!.add(message);

    toTheTop(conv);

    notifyListeners();
  }

  void toTheTop(ConversationModel conversation) {
    _concersations.remove(conversation);
    _concersations.insert(0, conversation);
  }
}
import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter_maps/models/user_model.dart';

class ConversationModel {
  int? id;
  UserModel? user;
  String? createdAt;
  List<MessageModal>? messages;

  ConversationModel({ this.id, this.user,  this.createdAt, this.messages});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new UserModel.fromJson(json['user']) : null;
    createdAt = json['created_at'];
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages?.add(new MessageModal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    final user = this.user;
    if (user != null) {
      data['user'] = user.toJson();
    }
    data['created_at'] = this.createdAt;
    final messages = this.messages;
    if (messages != null) {
      data['messages'] = messages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

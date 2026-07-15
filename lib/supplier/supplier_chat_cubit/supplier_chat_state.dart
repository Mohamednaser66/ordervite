part of 'supplier_chat_cubit.dart';

@immutable
sealed class SupplierChatState {}

final class SupplierChatInitial extends SupplierChatState {}

final class SupplierChatLoading extends SupplierChatState {}

final class SupplierChatLoaded extends SupplierChatState {
  final List<Map<String, dynamic>> messages;
  SupplierChatLoaded(this.messages);
}

final class SupplierChatError extends SupplierChatState {
  final String error;
  SupplierChatError(this.error);
}

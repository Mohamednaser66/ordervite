import 'package:flutter_maps/providers/conversation_provider.dart';
import 'package:get_it/get_it.dart';




GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton(() => ConversationProvider());

}

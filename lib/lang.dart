import 'package:flutter/material.dart';

/// A simple language provider that uses an [InheritedNotifier] to rebuild
class Lang extends InheritedNotifier<ValueNotifier<String>> {
  Lang({
    Key? key,
    String initialLang = 'ar',
    required Widget child,
  }) : super(
          key: key,
          notifier: ValueNotifier<String>(initialLang),
          child: child,
        );

  String get lang => notifier!.value;
  set lang(String value) => notifier!.value = value;

  static Lang of(BuildContext context) {
    final Lang? result =
        context.dependOnInheritedWidgetOfExactType<Lang>();
    assert(result != null, 'No Lang found in context');
    return result!;
  }
}

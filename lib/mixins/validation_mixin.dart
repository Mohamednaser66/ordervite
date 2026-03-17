import 'dart:async';

mixin ValidationMixin {
  // Streams
  final validatorEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (!ValidationMixin._validateEmail(email)) {
        sink.addError('Email is not valid');
      } else {
        sink.add(email);
      }
    },
  );

  final validatorPassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (!ValidationMixin._validatePassword(password)) {
        sink.addError('Password is not valid!');
      } else {
        sink.add(password);
      }
    },
  );

  // Helper methods
  static bool _validateEmail(String email) {
    final regExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regExp.hasMatch(email);
  }

  static bool _validatePassword(String password) {
    final regExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z]).{8,}$');
    return regExp.hasMatch(password);
  }
}
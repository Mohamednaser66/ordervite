import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../mixins/validation_mixin.dart';

class FormBloc with ValidationMixin {
  final _email = BehaviorSubject<String>.seeded('');
  final _password = BehaviorSubject<String>.seeded('');
  final _errorMessage = BehaviorSubject<String?>.seeded(null);
  Function(String) get changeEmail {
    addError(null);
    return _email.sink.add;
  }

  Function(String) get changePassword {
    addError(null);
    return _password.sink.add;
  }

  Function(String?) get addError => _errorMessage.sink.add;
  Stream<String> get email => _email.stream.transform(validatorEmail);

  Stream<String> get password => _password.stream.transform(validatorPassword);

  Stream<String?> get errorMessage => _errorMessage.stream;

  Stream<bool> get submitValidForm => Rx.combineLatest3(
    email,
    password,
    errorMessage,
    (e, p, er) => er == null || er.isEmpty,
  );

  void dispose() {
    _email.close();
    _password.close();
    _errorMessage.close();
  }
}

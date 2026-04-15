import 'package:flutter/material.dart';
import 'package:flutter_maps/blocs/form_bloc.dart';

class Helper {
  Widget errorMessage(FormBloc bloc) {
    return StreamBuilder<String?>(
      stream: bloc.errorMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data ?? '',
            style: TextStyle(color: Colors.red),
          );
        }
        return const Text('');
      },
    );
  }
}
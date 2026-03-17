import 'package:flutter/material.dart';
import 'package:flutter_maps/lang.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    return Directionality(
      textDirection:
      lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang.lang=='en'?'Cart':'سلة التسوق'),
        ),
      ),
    );
  }
}

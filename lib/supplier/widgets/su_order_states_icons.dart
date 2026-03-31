import 'package:flutter/material.dart';

class SuOrderStatesIcons extends StatelessWidget {
  const SuOrderStatesIcons({super.key, required this.isConfirm, required this.isShConfirm, required this.isShReceived, required this.isShDelviered});
 final bool isConfirm;
 final bool isShConfirm;
 final bool isShReceived;
 final bool isShDelviered;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,

            decoration:  BoxDecoration(
              borderRadius:
               BorderRadius.circular(
                50.0,
              ),
              color: isConfirm
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_New order.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),

        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,

            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                50.0,
              ),
              color: isShConfirm
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_shipper confirm.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),

        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration:  BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                50.0,
              ),
              color: isShReceived
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_shipper received.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration:  BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                50.0,
              ),
              color: isShDelviered
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),

              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_package delivered.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration:  BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                50.0,
              ),
              color: Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_order complete.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';

class OrdersNamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final int? notificationCount;
  final bool isVerified;

  const OrdersNamedIcon({
    Key? key,
    required this.text,
    required this.iconData,
    this.notificationCount,
    required this.isVerified,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isVerified) {
          Navigator.pushNamed(context, RoutesManager.shOrders);
        }
      },
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text, overflow: TextOverflow.ellipsis),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: (notificationCount != null && notificationCount! > 0)
                  ? Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  '$notificationCount',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

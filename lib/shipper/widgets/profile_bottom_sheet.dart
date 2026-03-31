import 'package:flutter/material.dart';
import 'package:flutter_maps/lang.dart';

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key, required this.onCameraClick, required this.onGalleryClick, required this.title});
final VoidCallback onCameraClick;
final VoidCallback onGalleryClick;
final String title;
  @override
  Widget build(BuildContext context) {
    Lang lang=Lang.of(context);

    return Container(
      height: 100.0,
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(
            title,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera),
                onPressed: onCameraClick,
                label: Text(lang.lang == "en" ? "Camera" : "كاميرا "),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text(lang.lang == "en" ? "Gallery" : "معرض الصور "),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed:onGalleryClick,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

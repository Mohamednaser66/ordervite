import 'package:flutter/material.dart';
import '../size_Config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback onTap;

  const PrimaryButton({Key? key, this.child, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
          vertical: SizeConfig.blockSizeHorizontal * 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: child,
      ),
    );
  }
}
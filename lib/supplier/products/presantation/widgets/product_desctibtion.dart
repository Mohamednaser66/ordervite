import 'package:flutter/material.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({super.key});

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Padding(
        padding: REdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.lang == 'en' ? 'Product Name' : 'اسم المنتج',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                Text(lang.lang == 'en' ? '' : ' ',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.lang == 'en' ? 'description' : 'الوصف ',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
                Text(lang.lang == 'en' ? '' : '',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.lang == 'en' ? 'price' : 'السعر',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
                Text(lang.lang == 'en' ? '0 EGP' : '0 جنيه',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.lang == 'en' ? 'count' : 'العدد',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
                SizedBox(width: 10.w,),
                Text(lang.lang == 'en' ? '' : '',style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),),
              ],
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue

              ),
              child: Text(lang.lang == 'en' ? 'Add' : 'اضافه',style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),),
            ),
          ],
        ),
      ),
    );
  }
}

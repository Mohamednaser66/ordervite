import 'package:flutter/material.dart';
import 'package:flutter_maps/supplier/products/presantation/widgets/product_desctibtion.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key,required this.image, required this.name});
 final String image;
 final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  REdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
              height: 130.h,
              width: 100.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,width: 2.w,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(image,fit:BoxFit.fill,)),
                  Text(name,style: TextStyle(color: Colors.blue,fontSize: 16.sp,fontWeight: FontWeight.w400),)
                ],
              ),
            ),

        ],
      ),
    );
  }
}

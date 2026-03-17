import 'package:flutter/material.dart';
import 'package:flutter_maps/supplier/products/presantation/widgets/product_desctibtion.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key,required this.image, required this.name});
 final String image;
 final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            showModalBottomSheet(context: context, builder: (context) {
             return ProductDescription();
            },);
          },
          child: Container(
            height: 100.h,
            width: 100.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,width: 2.w,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(image,fit:BoxFit.fill,)),
          ),
        ),
        SizedBox(height: 4.h,),
        Text(name,style: TextStyle(color: Colors.blue,fontSize: 16.sp,fontWeight: FontWeight.w400),)
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/widgets/su_order_states_icons.dart';

class OrderStatusWidget extends StatelessWidget {
  final bool isConfirm;
  final bool isShConfirm;
  final bool isShDelviered;
  final bool isShReceived;
  final String? orderState;
  final String? orderId;

  const OrderStatusWidget({
    Key? key,
    required this.isConfirm,
    required this.isShConfirm,
    required this.isShDelviered,
    required this.isShReceived,
    this.orderState,
    this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              lang.lang == "en"
                  ? "Order State: ${orderState ?? 'Unknown'}"
                  : (orderState == "new"
                      ? "حالة الطلب : جديد"
                      : (orderState == "shipper confirmed"
                          ? "حالة الطلب : تأكيد مسئول الشحن  "
                          : (orderState == "order received"
                              ? "حالة الطلب :   استلام الشحنة   "
                              : (orderState == "order delivered"
                                  ? "حالة الطلب :      اكتمال الطلب    "
                                  : "حالة الطلب :   توصيل الشحنة  الشحنة   ")))),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),
        SizedBox(height: 10.h),
        SuOrderStatesIcons(
          isConfirm: isConfirm,
          isShConfirm: isShConfirm,
          isShDelviered: isShDelviered,
          isShReceived: isShReceived,
        ),
        SizedBox(height: 10.h),
            Text(
              lang.lang == "en" ? "Order ID: ${orderId ?? ''}" : "كود الطلب :${orderId ?? ''}",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),
        // Add more status-related widgets here
      ],
    );
  }
}
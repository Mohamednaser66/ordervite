import 'package:flutter/material.dart';
import 'package:flutter_maps/shipper/models/sh_orders_history.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShipperOrderDetailsScreen extends StatelessWidget {
  final ShOrdersHistory order;

  const ShipperOrderDetailsScreen({
    super.key,
    required this.order,
  });

  Widget buildItem(String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: TextStyle(
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${order.id}"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildItem("Order ID", order.id),
                buildItem("Supplier ID", order.supplierId),
                buildItem("Shipper ID", order.shippierId),

                const Divider(),

                buildItem("Cost", "${order.cost} EGP"),
                buildItem("Price", order.price),
                buildItem("Price Check", order.pricecheck),
                buildItem("Commission", order.commission),
                buildItem("Percentage", order.percentage),
                buildItem("Shipper Pay", order.shipperPay),
                buildItem("Payment Status", order.paymentStatus),

                const Divider(),

                buildItem("Type", order.type),
                buildItem("Size", order.size),
                buildItem("Distance", "${order.distance} KM"),
                buildItem("Order State", order.orderState),
                buildItem("Rating", order.rating),
                buildItem("Review", order.review),
                buildItem("Order Note", order.orderNote),

                const Divider(),

                buildItem("Source Address", order.sourceAddress),
                buildItem("Destination Address", order.destinationAddress),

                const Divider(),

                buildItem("Source Latitude", order.soLatitude),
                buildItem("Source Longitude", order.soLongitude),

                buildItem("Destination Latitude", order.distLatitude),
                buildItem("Destination Longitude", order.distLongitude),

                buildItem("Shipper Latitude", order.shLatitude),
                buildItem("Shipper Longitude", order.shLongitude),

                const Divider(),

                buildItem("Created At", order.createdAt),
                buildItem("Updated At", order.updatedAt),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
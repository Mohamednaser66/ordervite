import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/widgets/sh_order_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class ShOrderStatesWidget extends StatefulWidget {
   ShOrderStatesWidget({
    super.key,
    required this.order_id,
    required this.order_supplier_id,
    required this.order_price,
    required this.order_pricecheck,
    required this.id,
    required this.token,
    required this.order_cost,
    required this.lang,
    required this.order_state,
    required this.api_token ,
    required this.isConfirm ,
    required this.isReceived ,
    required this.isDelviered ,
    required this.username ,
  });

  Lang lang;

  String order_state;

    String? order_id;

  final  String order_supplier_id,order_price, order_pricecheck,id,token;
  String api_token;
  String? username;

  final  String order_cost;

  bool isConfirm;

  bool isReceived;

  bool isDelviered;

  @override
  State<ShOrderStatesWidget> createState() => _ShOrderStatesWidgetState();
}

class _ShOrderStatesWidgetState extends State<ShOrderStatesWidget> {


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Order State: ${widget.order_state}"
                    : (widget.order_state == "new"
                    ? "حالة الطلب : جديد"
                    : (widget.order_state ==
                    "shipper confirmed"
                    ? "حالة الطلب : تاكيد مسئول الشحن  "
                    : (widget.order_state ==
                    "order received"
                    ? "حالة الطلب :   استلام الشحنة   "
                    : (widget.order_state ==
                    "order delivered"
                    ? "حالة الطلب :      اكتمال الطلب    "
                    : "حالة الطلب :   توصيل الشحنة  الشحنة   ")))),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),
        ShOrderIcons(isConfirm: widget.isConfirm,isDelviered: widget.isDelviered,isReceived: widget.isReceived,),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Order ID: ${widget.order_id}"
                    : "كود الطلب :${widget.order_id}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.0.w),

            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Supplier ID: ${widget.order_supplier_id} "
                    : "كود المورد : ${widget.order_supplier_id}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Shipping Cost:"
                    : "تكلفة الشحن ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Package Price:"
                    : "سعر الشحنة ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "${widget.order_cost} L.E."
                    : "${widget.order_cost} جم",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "${widget.order_price} L.E."
                    : "${widget.order_price} جم",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.0.h),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Payment Method : ${widget.order_pricecheck}"
                    : (widget.order_pricecheck == "cash"
                    ? "نظام الدفع  : كاش"
                    : "نظام الدفع  : تحويل"),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        !widget.isConfirm
            ? Row(
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
              child: TextButton.icon(
                onPressed: () async {
                  Location _locationTracker =
                  Location();
                  var location =
                  await _locationTracker
                      .getLocation();
                  if (widget.isConfirm) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        backgroundColor:
                        Colors.redAccent,
                        content: Text(
                          widget.lang.lang == "en"
                              ? 'Please wait to Response your order have sended  ...'
                              : '  الرجاء الانتظار حتى يتم على طلبك الذي أرسلته.  ',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  } else {
                    try {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en"
                                ? 'Confirm'
                                : 'تاكيد ',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Are you sure you want to acquire this order?'
                                : 'هل أنت متأكد أنك تريد الحصول على هذا الطلب؟ ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'Yes'
                                    : 'نعم',
                              ),
                              onPressed: () async {
                                int id = int.parse(
                                  this.widget.order_id ??
                                      '',
                                  radix: 10,
                                );

                                String Url =
                                    "https://www.ordervite.com/api/shippier/orders/$id";

                                var response = await http.put(
                                  Uri.parse(Url),
                                  body: {
                                    "shippier_id": this
                                        .widget.id
                                        .toString(),
                                    "sh_longitude":
                                    location
                                        .longitude
                                        .toString(),
                                    "sh_latitude":
                                    location
                                        .latitude
                                        .toString(),
                                    "order_state":
                                    "shipper confirmed",
                                  },
                                  headers: {
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );

                                var reposnsebody =
                                jsonDecode(
                                  response.body,
                                );
                                int
                                sub_id = int.parse(
                                  reposnsebody["data"]["supplier_id"]
                                      .toString(),
                                  radix: 10,
                                );

                                String Url2 =
                                    "https://www.ordervite.com/api/shippier/supplier/$sub_id";

                                var response2 = await http.get(
                                  Uri.parse(Url2),
                                  headers: {
                                    'Content-Type':
                                    'application/json',
                                    'Accept':
                                    'application/json',
                                    'Authorization':
                                    'Bearer ' +
                                        this.widget.token!,
                                  },
                                );

                                var reposnsebody2 =
                                jsonDecode(
                                  response2
                                      .body,
                                );

                                setState(() {
                                  this.widget.api_token =
                                      reposnsebody2["data"]["name"]["api_token"]
                                          .toString();
                                });

                                setState(() {
                                  widget.isConfirm = true;
                                  widget.order_state =
                                      reposnsebody["data"]["order_state"]
                                          .toString();
                                });

                                Navigator.of(
                                  context,
                                ).pop();

                                if (reposnsebody !=
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Colors
                                          .redAccent,
                                      content: Text(
                                        widget.lang.lang ==
                                            "en"
                                            ? 'You have acquired this order, please head to the supplier to pick up.  '
                                            : 'لقد حصلت على هذا الطلب، يُرجى التوجه إلى المورد لاستلامه.',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          18,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'No'
                                    : 'لا',
                              ),
                              onPressed: () =>
                                  Navigator.of(
                                    context,
                                  ).pop(),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en"
                                ? 'Warning'
                                : 'تحذير',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Please check your network  '
                                : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          actions: [],
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.done_all,
                  size: 20,
                ),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Confirm"
                      : "تاكيد",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),

            SizedBox(width: 15.0),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    widget.isConfirm = false;
                  });
                  showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(
                        widget.lang.lang == "en"
                            ? 'Confirm'
                            : 'تاكيد',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      content: Text(
                        widget.lang.lang == "en"
                            ? 'Are you sure you want to cancel the order (a fine may apply) '
                            : 'هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟ ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'Yes'
                                : 'نعم',
                          ),
                          onPressed: () {
                            Message
                            message = Message(
                              widget.lang.lang == "en"
                                  ? "Order is Canceled"
                                  : "تم اإلغاء الطلب ",
                            );
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              RoutesManager.shHome,
                                  (route) => false,
                              arguments: message,
                            );
                          },
                        ),
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'No'
                                : 'لا',
                          ),
                          onPressed: () =>
                              Navigator.of(
                                context,
                              ).pop(),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.cancel, size: 20),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Cancel"
                      : "إلغاء",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        )
            : !widget.isReceived
            ? Row(
          children: <Widget>[
            SizedBox(width: 10.0.w),

            Expanded(
              child: TextButton.icon(
                onPressed: () async {
                  if ( widget.isReceived) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        backgroundColor:
                        Colors.redAccent,
                        content: Text(
                          widget.lang.lang == "en"
                              ? 'error order not recevied until yet  ...'
                              : ' هناك خطأ، لم يتم استقبال طلبك حتى الآن ',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  } else {
                    try {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en"
                                ? 'Confirm'
                                : 'تاكيد',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Please confirm that you have received the package'
                                : '     ُرجى تأكيد أنك استلمت الطرد ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'Yes'
                                    : 'نعم',
                              ),
                              onPressed: () async {
                                int id = int.parse(
                                  this. widget.order_id!,
                                  radix: 10,
                                );
                                String Url =
                                    "https://www.ordervite.com/api/shippier/order_update/$id";
                                var response = await http.put(
                                  Uri.parse(Url),
                                  body: {
                                    "order_state":
                                    "order received",
                                  },
                                  headers: {
                                    'Authorization':
                                    'Bearer  ' +
                                        this. widget.token!,
                                  },
                                );

                                var reposnsebody =
                                jsonDecode(
                                  response.body,
                                );
                                setState(() {
                                  widget.isReceived = true;
                                  widget.order_state =
                                      reposnsebody["data"]["order_state"]
                                          .toString();
                                });
                                Navigator.of(
                                  context,
                                ).pop();
                                if (reposnsebody !=
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Colors
                                          .redAccent,
                                      content: Text(
                                        widget.lang.lang ==
                                            "en"
                                            ? 'You have confirmed receiving the package, Now head to the destination.  '
                                            : 'لقد أكدت استلام الطرد ، توجه الآن إلى الوجهة.    ',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          14.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'No'
                                    : 'لا ',
                              ),
                              onPressed: () =>
                                  Navigator.of(
                                    context,
                                  ).pop(),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en"
                                ? 'Warning'
                                : 'تحذير',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Please check your network  '
                                : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          actions: [],
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.done_all,
                  size: 20,
                ),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Received PK "
                      : "استلام ",
                  style: TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.0.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    widget.isConfirm = false;
                  });
                  showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(
                        widget.lang.lang == "en"
                            ? 'Confirm'
                            : 'تاكيد',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      content: Text(
                        widget.lang.lang == "en"
                            ? 'Are you sure you want to cancel the order (a fine may apply) '
                            : ' هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟    ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'Yes'
                                : 'نعم ',
                          ),
                          onPressed: () async {
                            try {
                              if (this. widget.order_id !=
                                  null) {
                                String name =
                                    this. widget.id! +
                                        ' ' +
                                        '  shipper  ' +
                                        this.widget.username!;

                                int id = int.parse(
                                  this.widget.order_id!,
                                  radix: 10,
                                );
                                String Url =
                                    "https://www.ordervite.com/api/shippier/order_update/$id";
                                var response = await http.put(
                                  Uri.parse(Url),
                                  body: {
                                    "order_cancel":
                                    "$name cancel order",
                                  },
                                  headers: {
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );
                                var reposnsebody =
                                jsonDecode(
                                  response.body,
                                );
                                String text =
                                widget.lang.lang ==
                                    "en"
                                    ? "your order is canceled by shipper"
                                    : "تم  الغاء الطلب بواسطة مسئول الشحن  ";
                                String
                                supplier_api_token =
                                this.widget.api_token
                                    .toString();
                                String Url3 =
                                    "https://www.ordervite.com/api/notify/page/ordervite/$text/$supplier_api_token/1/ordervite/shipper/order cancel";
                                await http.get(
                                  Uri.parse(Url3),
                                  headers: {
                                    'Content-Type':
                                    'application/json',
                                    'Accept':
                                    'application/json',
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );
                                Navigator.of(
                                  context,
                                ).pop();
                                if (reposnsebody !=
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Colors
                                          .redAccent,
                                      content: Text(
                                        widget.lang.lang ==
                                            "en"
                                            ? 'Order have canceled ...'
                                            : 'تم الغاء الطلب ',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          16.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                Message
                                message = Message(
                                  widget.lang.lang == "en"
                                      ? "you  have canceld order"
                                      : "لقد قمت بالغاء الطلب ",
                                );

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  RoutesManager.shHome,
                                      (route) => false,
                                  arguments:
                                  message,
                                );
                              }
                            } catch (e) {
                              showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(
                                    widget.lang.lang ==
                                        "en"
                                        ? 'Warning'
                                        : 'تحذير',
                                    style: TextStyle(
                                      color: Colors
                                          .red,
                                    ),
                                  ),
                                  content: Text(
                                    widget.lang.lang ==
                                        "en"
                                        ? 'Please check your network  '
                                        : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors
                                          .red,
                                    ),
                                  ),
                                  actions: [],
                                ),
                              );
                            }
                          },
                        ),
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'No'
                                : 'لا ',
                          ),
                          onPressed: () =>
                              Navigator.of(
                                context,
                              ).pop(),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.cancel, size: 20),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Cancel"
                      : "الغاء",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        )
            : !widget.isDelviered
            ? Row(
          children: <Widget>[
            SizedBox(width: 10.0),

            Expanded(
              child: TextButton.icon(
                onPressed: () async {
                  if (widget.isDelviered) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        backgroundColor:
                        Colors.redAccent,
                        content: Text(
                          widget.lang.lang == "en"
                              ? 'error order not delivered until yet  ...'
                              : 'هناك خطأ، لم يتم تسليم طلبك حتى الآن',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    );
                  } else {
                    try {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en"
                                ? 'Confirm'
                                : 'تاكيد',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Please confirm that you have delivered the package'
                                : 'من فضلك قم بتاكيد تسليم الشحنة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'Yes'
                                    : 'نعم',
                              ),
                              onPressed: () async {
                                int id = int.parse(
                                  this.widget.order_id!,
                                  radix: 10,
                                );

                                String Url =
                                    "https://www.ordervite.com/api/shippier/order_update/$id";

                                var response = await http.put(
                                  Uri.parse(Url),
                                  body: {
                                    "order_state":
                                    "order delivered",
                                  },
                                  headers: {
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );

                                var reposnsebody =
                                jsonDecode(
                                  response.body,
                                );

                                String text =
                                widget.lang.lang ==
                                    "en"
                                    ? "your order is delveried by shipper"
                                    : "تم تسليم الشحنة بواسطة مسئول الشحن  ";

                                String
                                supplier_api_token =
                                this.widget.api_token
                                    .toString();

                                String Url3 =
                                    "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order delivered";

                                await http.get(
                                  Uri.parse(Url3),
                                  headers: {
                                    'Content-Type':
                                    'application/json',
                                    'Accept':
                                    'application/json',
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );

                                setState(() {
                                  widget.isDelviered =
                                  true;
                                  widget.order_state =
                                      reposnsebody["data"]["order_state"]
                                          .toString();
                                });

                                Navigator.of(
                                  context,
                                ).pop();

                                if (reposnsebody !=
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Colors
                                          .redAccent,
                                      content: Text(
                                        widget.lang.lang ==
                                            "en"
                                            ? 'Well Done! Now wait for the supplier to confirm the order'
                                            : 'أحسنت! الآن انتظر المورد لتأكيد الطلب. ',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          18.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            TextButton(
                              child: Text(
                                widget.lang.lang == "en"
                                    ? 'No'
                                    : 'لا',
                              ),
                              onPressed: () =>
                                  Navigator.of(
                                    context,
                                  ).pop(),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(
                            widget.lang.lang == "en" ? 'Warning' : 'تحذير',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
                            widget.lang.lang == "en"
                                ? 'Please check your network  '
                                : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                            ),
                          ),
                          actions: [],
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  Icons.done_all,
                  size: 20,
                ),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Delivered PK "
                      : "تسليم",
                  style: TextStyle(
                    fontSize: 12.0.sp,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),

            SizedBox(width: 15.0),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    widget.isConfirm = false;
                  });

                  showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(
                        widget.lang.lang == "en"
                            ? 'Confirm'
                            : 'تاكيد',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      content: Text(
                        widget.lang.lang == "en"
                            ? 'Are you sure you want to cancel the order (a fine may apply) '
                            : '   هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'Yes'
                                : 'نعم',
                          ),
                          onPressed: () async {
                            try {
                              if (this.widget.order_id !=
                                  null) {
                                String name =
                                    this.widget.id! +
                                        ' ' +
                                        '  shipper  ' +
                                        this.widget.username!;

                                int id = int.parse(
                                  this.widget.order_id!,
                                  radix: 10,
                                );

                                String Url =
                                    "https://www.ordervite.com/api/shippier/order_update/$id";

                                var response = await http.put(
                                  Uri.parse(Url),
                                  body: {
                                    "order_cancel":
                                    "$name cancel order",
                                  },
                                  headers: {
                                    'Authorization':
                                    'Bearer  ' +
                                        this.widget.token!,
                                  },
                                );

                                var reposnsebody =
                                jsonDecode(
                                  response.body,
                                );

                                String
                                supplier_api_token =
                                this.widget.api_token
                                    .toString();

                                String text =
                                widget.lang.lang ==
                                    "en"
                                    ? "your order is canceled by shipper"
                                    : " تم  الغاء الطلب بواسطة مسئول الشحن  ";

                                String Url3 =
                                    "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order cancel";

                                await http.get(
                                  Uri.parse(Url3),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json',
                                    'Authorization': 'Bearer  ' + this.widget.token!,
                                  },
                                );

                                Navigator.of(
                                  context,
                                ).pop();

                                if (reposnsebody !=
                                    null) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                      Colors
                                          .redAccent,
                                      content: Text(
                                        widget.lang.lang ==
                                            "en"
                                            ? 'Order have canceled ...'
                                            : '...تم الغاء الطلب',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          18,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                Message
                                message = Message(
                                  widget.lang.lang == "en"
                                      ? "you  have canceld order"
                                      : "تم الغاء الطلب ...",
                                );

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  RoutesManager.shHome,
                                      (route) => false,
                                  arguments:
                                  message,
                                );
                              }
                            } catch (e) {
                              showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(
                                    widget.lang.lang ==
                                        "en"
                                        ? 'Warning'
                                        : 'تحذير',
                                    style: TextStyle(
                                      color: Colors
                                          .red,
                                    ),
                                  ),
                                  content: Text(
                                    widget.lang.lang ==
                                        "en"
                                        ? 'Please check your network  '
                                        : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors
                                          .red,
                                    ),
                                  ),
                                  actions: [],
                                ),
                              );
                            }
                          },
                        ),
                        TextButton(
                          child: Text(
                            widget.lang.lang == "en"
                                ? 'No'
                                : 'لا ',
                          ),
                          onPressed: () =>
                              Navigator.of(
                                context,
                              ).pop(),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.cancel, size: 20),
                label: Text(
                  widget.lang.lang == "en"
                      ? "Cancel"
                      : "الغاء",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        )
            : Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Row(
              children: <Widget>[
                SizedBox(width: 10.0),

                Expanded(
                  child: Text(
                    widget.lang.lang == "en"
                        ? "You have confirmed the package delivery, please wait for the supplier final confirmation "
                        : "لقد أكدت تسليم الطرد، يُرجى انتظار التأكيد النهائي للمورد",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

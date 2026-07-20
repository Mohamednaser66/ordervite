import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/order/presentation/supplier_order__cubit.dart';
//
// class OrderFormWidget extends StatefulWidget {
//   final bool isConfirm;
//   final String? distance;
//   final LatLng sourceLatLong;
//   final LatLng destinationLatLong;
//   final String? token;
//   final String? id;
//
//   const OrderFormWidget({
//     super.key,
//     required this.isConfirm,
//     this.distance,
//     required this.sourceLatLong,
//     required this.destinationLatLong,
//     this.token,
//     this.id,
//   });
//
//   @override
//   State<OrderFormWidget> createState() => _OrderFormWidgetState();
// }
//
// class _OrderFormWidgetState extends State<OrderFormWidget> {
//   final List<String> sizes = ['small', 'medium', 'large'];
//   final List<String> payments = ['cash', 'transfer'];
//
//   int selectedSize = 0;
//   int selectedPayment = 0;
//
//   String get size => sizes[selectedSize];
//   String get payment => payments[selectedPayment];
//
//   void _onSizeChanged(int index) => setState(() => selectedSize = index);
//   void _onPaymentChanged(int index) => setState(() => selectedPayment = index);
//
//   String _sizeLabel(Lang lang, String value) {
//     if (lang.lang == "en") return value;
//     if (value == "small") return "صغير";
//     if (value == "medium") return "وسط";
//     return "كبير";
//   }
//
//   String _paymentLabel(Lang lang, String value) {
//     if (lang.lang == "en") return value;
//     return value == "cash" ? "كاش" : "تحويل";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final lang = Lang.of(context);
//     final cubit = context.read<SupplierOrderCubit>();
//
//     return BlocListener<SupplierOrderCubit, SupplierOrderState>(
//       listener: (context, state) {
//         if (state is SupplierOrderCreated) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 lang.lang == "en"
//                     ? "Order created successfully"
//                     : "تم إنشاء الطلب بنجاح",
//               ),
//             ),
//           );
//         }
//
//         if (state is SupplierOrderError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//           );
//         }
//       },
//       child: Container(
//         height: 350.h,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromRGBO(21, 42, 72, 1),
//               Color.fromRGBO(7, 15, 33, 1),
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: REdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 lang.lang == "en" ? "Choose Package Size" : "اختار حجم الطرد",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               SizedBox(height: 10.h),
//
//               _buildOptions(
//                 items: sizes,
//                 selected: selectedSize,
//                 onChanged: _onSizeChanged,
//                 label: (v) => _sizeLabel(lang, v),
//               ),
//
//               SizedBox(height: 10.h),
//
//               Text(
//                 lang.lang == "en"
//                     ? "Distance: ${widget.distance ?? '0.0'} km"
//                     : "المسافة: ${widget.distance ?? '0.0'} كم",
//                 style: TextStyle(color: Colors.white),
//               ),
//
//               SizedBox(height: 10.h),
//
//               Text(
//                 lang.lang == "en" ? "Payment Method" : "طريقة الدفع",
//                 style: TextStyle(color: Colors.white),
//               ),
//
//               SizedBox(height: 10.h),
//
//               _buildOptions(
//                 items: payments,
//                 selected: selectedPayment,
//                 onChanged: _onPaymentChanged,
//                 label: (v) => _paymentLabel(lang, v),
//               ),
//
//               SizedBox(height: 20.h),
//
//               ElevatedButton(
//                 onPressed: widget.isConfirm
//                     ? () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               lang.lang == "en"
//                                   ? "Please wait..."
//                                   : "الرجاء الانتظار...",
//                             ),
//                           ),
//                         );
//                       }
//                     : () {
//                         cubit.createOrder(
//                           token: widget.token ?? '',
//                           supplierId: widget.id ?? '',
//                           size: size,
//                           price: 'default',
//                           priceCheck: payment,
//                           source: widget.sourceLatLong,
//                           destination: widget.destinationLatLong,
//                           distance: widget.distance ?? '0.0',
//                         );
//                       },
//                 child: Text(lang.lang == "en" ? "Confirm" : "تأكيد"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOptions({
//     required List<String> items,
//     required int selected,
//     required Function(int) onChanged,
//     required String Function(String) label,
//   }) {
//     return Row(
//       children: List.generate(items.length, (index) {
//         final isSelected = selected == index;
//
//         return Expanded(
//           child: Padding(
//             padding: REdgeInsets.symmetric(horizontal: 5),
//             child: ElevatedButton(
//               onPressed: () => onChanged(index),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isSelected ? Colors.blueAccent : Colors.grey,
//               ),
//               child: Text(
//                 label(items[index]),
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

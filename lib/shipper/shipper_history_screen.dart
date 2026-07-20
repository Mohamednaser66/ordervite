import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/shipper/order/presentation/shipper_order_cubit.dart';
import 'package:flutter_maps/shipper/sh_orders_details.dart';
import 'package:flutter_maps/supplier/order_details.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShipperHistoryScreen extends StatefulWidget {
  final String shipperId;

  const ShipperHistoryScreen({
    super.key,
    required this.shipperId,
  });

  @override
  State<ShipperHistoryScreen> createState() => _ShipperHistoryScreenState();
}

class _ShipperHistoryScreenState extends State<ShipperHistoryScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ShipperOrderCubit>().getShipperOrdersList(widget.shipperId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: BlocBuilder<ShipperOrderCubit, ShipperOrderState>(
        builder: (context, state) {
          if (state is ShipperOrderLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorsManager.primaryGreen,
              ),
            );
          }

          if (state is ShipperOrderListError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is ShipperOrderListSuccess) {
            if (state.orders.data == null ||
                state.orders.data!.isEmpty) {
              return const Center(
                child: Text("No Orders"),
              );
            }

            return ListView.builder(
              itemCount: state.orders.data!.length,
              itemBuilder: (context, index) {
                final order = state.orders.data![index];

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShipperOrderDetailsScreen(
                          order: order,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: ColorsManager.primaryGreen,
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    "ID : ${order.id}    ${order.size}",
                  ),
                  subtitle: Text(
                    "Cost : ${order.cost} EGP",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
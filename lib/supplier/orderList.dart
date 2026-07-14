import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/supplier/order/presentation/supplier_order__cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/routes_manager.dart';
import '../../core/colors_manager.dart';
import '../../widgets/style.dart';

class UserOrderList extends StatefulWidget {
  final String supplierId;

  const UserOrderList({
    super.key,
    required this.supplierId,
  });

  @override
  State<UserOrderList> createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  @override
  void initState() {
    super.initState();

    context.read<SupplierOrderCubit>().getUserOrderList(widget.supplierId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: BlocBuilder<SupplierOrderCubit, SupplierOrderState>(
        builder: (context, state) {
          if (state is SupplierOrderListLoading) {
            return  Center(
              child: CircularProgressIndicator( color: ColorsManager.primaryGreen,),
            );
          }

          if (state is SupplierOrderListError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is SupplierOrderListSuccess) {
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
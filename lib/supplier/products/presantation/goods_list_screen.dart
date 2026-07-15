import 'package:flutter/material.dart';
import 'package:flutter_maps/core/product.dart';

class GoodsListScreen extends StatelessWidget {
   GoodsListScreen({super.key});
  final categories = products
      .map((e) => e.category)
      .toSet()
      .toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  title: const Text("قائمة المنتجات"),),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          final categoryProducts = products
              .where((e) => e.category == category)
              .toList();

          return ExpansionTile(
            title: Text(category),
            children: categoryProducts.map((product) {
              return ListTile(
                title: Text(product.name),
                subtitle: Text(product.unit),
                trailing: Text("${product.price} ج.م"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

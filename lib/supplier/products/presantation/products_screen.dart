import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/images_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/products/presantation/widgets/product_item.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesManager.cart);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          ],
          title: Text('Products'),
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 10, left: 10, right: 10),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              return ProductItem(
                image: ProductData.products[index].image,
                name: lang.lang == 'en'
                    ? ProductData.products[index].name
                    : ProductData.products[index].nameAr,
              );
            },
            itemCount: 4,
          ),
        ),
      ),
    );
  }
}

class ProductData {
  String nameAr;
  String name;
  String image;

  ProductData({required this.image, required this.name, required this.nameAr});

  static List<ProductData> products = [
    ProductData(image: ImagesManager.sugar, name: 'Sugar', nameAr: 'سكر'),
    ProductData(image: ImagesManager.pasta, name: 'Pasta', nameAr: 'مكرونه'),
    ProductData(image: ImagesManager.oil, name: 'Oil', nameAr: 'زيت'),
    ProductData(image: ImagesManager.rice, name: 'Rice', nameAr: 'سكر'),
  ];
}

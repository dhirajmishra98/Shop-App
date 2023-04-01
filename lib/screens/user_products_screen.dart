import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/UserProductScreen';
  const UserProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productItem = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProductScreen.routeName);
              },
              icon:const Icon(Icons.add)),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: productItem.items.length,
        itemBuilder: (context, index) => Column(
          children: [
            UserProductItem(
              id:productItem.items[index].id ,
                title: productItem.items[index].title,
                imageUrl: productItem.items[index].imageUrl),
            Divider(),
          ],
        ),
      ),
    );
  }
}

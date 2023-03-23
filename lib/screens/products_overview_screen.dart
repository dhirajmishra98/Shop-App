import 'package:flutter/material.dart';

import '../widgets/product_grid.dart';

class ProductsOverViewScreen extends StatelessWidget {
  ProductsOverViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
      ),
      body: ProductGrid(),
    );
  }
}


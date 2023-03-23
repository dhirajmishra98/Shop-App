import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  ProductItem({super.key, required this.id,required this.title,required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(icon:const Icon(Icons.favorite) , color: Theme.of(context).colorScheme.secondary, onPressed: (){},),
          title: Text(title, textAlign: TextAlign.center,),
          trailing: IconButton(icon: const Icon(Icons.shopping_cart),color: Theme.of(context).colorScheme.secondary ,onPressed: (){},),
        ),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context,ProductDetailsScreen.routeName, arguments: id),
          child: Image.network(imageUrl, fit: BoxFit.cover,),),
        ),
    );
  }
}

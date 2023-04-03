import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  final String authToken;
  ProductsProvider(this.authToken, this._items);

  List<Product> get items {
    return [..._items]; //return copy of orginal _items object
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.https(
        'shop-app-d2062-default-rtdb.firebaseio.com', '/products.json');
    /* /products.json is added in original url, this generates a folder named products in firebase only*/
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavourite': product.isFavourite,
          }));

      Product newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      // _items.insert(0, newProduct); //add product at top (at starting)
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

/*
//Another way of using Futures
  Future<void> addProduct(Product product) {
    var url = Uri.https(
        'shop-app-d2062-default-rtdb.firebaseio.com', '/products.json');
    /* /products.json is added in original url, this generates a folder named products in firebase only*/
    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'isFavourite': product.isFavourite,
            }))
        .then((response) {
      Product newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      // _items.insert(0, newProduct); //add product at top (at starting)
      // ChangeNotifier();
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }
  */

  Future<void> fetchAndSetProducts() async {
    Uri url = Uri.parse(
        'https://shop-app-d2062-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prod) {
        loadedProduct.add(Product(
            id: prodId,
            title: prod['title'],
            description: prod['description'],
            price: prod['price'],
            imageUrl: prod['imageUrl']));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      rethrow; // or throw error
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      Uri url = Uri.parse(
          'https://shop-app-d2062-default-rtdb.firebaseio.com/products/$id.json');

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      //Cand be implemented as need
    }
  }

//optimistic updating approach
  Future<void> removeProduct(String id) async {
    Uri url = Uri.parse(
        'https://shop-app-d2062-default-rtdb.firebaseio.com/products/$id.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];

    _items.removeWhere((element) => element.id == id);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex,
          existingProduct); //rolling back if delete doesnot succedd
      notifyListeners();
      throw const HttpException('Cannot delete product');
    }
    existingProduct = null;
  }
}

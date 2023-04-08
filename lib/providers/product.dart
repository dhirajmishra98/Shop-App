import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  void _setFavValue(bool newFav) {
    isFavourite = newFav;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    bool oldFavourite = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    Uri url = Uri.parse(
        'https://shop-app-d2062-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url, body: json.encode(isFavourite));

      if (response.statusCode >= 400) {
        _setFavValue(oldFavourite);
      }
    } catch (error) {
      _setFavValue(oldFavourite);
    }
  }
}

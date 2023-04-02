import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    Uri url = Uri.parse(
        'https://shop-app-d2062-default-rtdb.firebaseio.com/orders.json');

    List<OrderItem> _loadedOrders = [];
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      extractedData.forEach((orderId, orderData) => {
            _loadedOrders.add(
              OrderItem(
                  id: orderId,
                  amount: orderData['amount'],
                  dateTime: DateTime.parse(orderData['dateTime']),
                  products: (orderData['products'] as List<dynamic>)
                      .map((item) => CartItem(
                          id: item['id'],
                          title: item['title'],
                          quantity: item['quantity'],
                          price: item['price']))
                      .toList()),
            ),
          });

      _orders = _loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    Uri url = Uri.parse(
        'https://shop-app-d2062-default-rtdb.firebaseio.com/orders.json');

    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0, //0 means insert at begining of order list, else by default it insert at end
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp),
    );
    notifyListeners();
  }
}

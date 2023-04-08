import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/orderItem.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/OrdersScreen';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    setState(() {
      _isLoading = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ordersData.orders.isEmpty
              ? const Center(child: Text('No Orders Yet!'))
              : ListView.builder(
                  itemCount: ordersData.orders.length,
                  itemBuilder: (context, index) =>
                      OrderItem(ordersData.orders[index]),
                ),
    );
  }
}

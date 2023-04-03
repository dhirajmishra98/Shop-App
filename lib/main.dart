import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

import '../providers/orders.dart';
import '../screens/cart_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';
import './screens/product_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //when we have multiproviders in app and have to give access to main file use this
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          // ChangeNotifierProvider(create: (ctx) => ProductsProvider()), //i have to access token from Auth (upper provider), so user proxyprovider to get access
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (ctx) => ProductsProvider('', []),
            update: (ctx, auth, prevousProducts) => ProductsProvider(
                auth.token!,
                prevousProducts?.items == null ? [] : prevousProducts!.items),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProvider.value(
              value: Orders()), //this provider doest depends on context
        ],
        // return ChangeNotifierProvider(
        //   create: (ctx) => ProductsProvider(),

        // return ChangeNotifierProvider.value( //if provider doesn't depends on context
        // value: ProductsProvider(),
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop App',
            theme: ThemeData(
              fontFamily: 'Lato',
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.orange),
            ),
            // home: ProductsOverViewScreen(),
            home: auth.isAuth ? ProductsOverViewScreen() : AuthScreen(),
            routes: {
              ProductDetailsScreen.routeName: (ctx) =>
                  const ProductDetailsScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          ),
        ));
  }
}

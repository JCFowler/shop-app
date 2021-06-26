import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/edit_product_screen.dart';
import 'screens/user_products_scree.dart';
import 'screens/orders_screen.dart';
import 'providers/orders.dart';
import 'screens/cart_screen.dart';
import 'providers/cart.dart';
import 'providers/products.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Products(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Orders(),
        ),
      ],
      child: MaterialApp(
        title: 'My Shop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        routes: {
          '/': (ctx) => ProductsOverviewScreen(),
          '/product-detail': (ctx) => ProductDetailScreen(),
          '/cart': (ctx) => CartScreen(),
          '/orders': (ctx) => OrdersScreen(),
          '/user-products': (ctx) => UserProductsScreen(),
          '/edit-product': (ctx) => EditProductScreen(),
        },
      ),
    );
  }
}

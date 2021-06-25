import 'package:flutter/material.dart';

import '../providers/cart.dart';

class OrderModel {
  final String id;
  final int amount;
  final List<CartModel> products;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.amount,
    required this.products,
    required this.date,
  });
}

class Orders with ChangeNotifier {
  List<OrderModel> _orders = [];

  List<OrderModel> get orders {
    return [..._orders];
  }

  void addOrder(List<CartModel> products, int total) {
    _orders.insert(
      0,
      OrderModel(
        id: DateTime.now().toString(),
        amount: total,
        products: products,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}

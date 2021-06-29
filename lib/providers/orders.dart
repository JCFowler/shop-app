import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../keys.dart';

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
  String token;
  String userId;
  List<OrderModel> _orders = [];

  Orders(this.token, this.userId, this._orders);

  List<OrderModel> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(ORDERS_URL(token, userId));
    try {
      final res = await http.get(url);
      if (res.body == 'null') {
        return;
      }
      final data = json.decode(res.body) as Map<String, dynamic>;

      final List<OrderModel> loadedOrders = [];
      data.forEach((id, map) {
        loadedOrders.add(
          OrderModel(
            id: id,
            amount: map['amount'],
            date: DateTime.parse(map['date']),
            products: (map['products'] as List<dynamic>).map((item) {
              return CartModel(
                id: item['id'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price'],
              );
            }).toList(),
          ),
        );
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addOrder(List<CartModel> products, int total) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(ORDERS_URL(token, userId));
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'date': timeStamp.toIso8601String(),
            'products': products
                .map(
                  (product) => {
                    'id': product.id,
                    'title': product.title,
                    'quantity': product.quantity,
                    'price': product.price,
                  },
                )
                .toList(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderModel(
          id: json.decode(res.body)['name'],
          amount: total,
          products: products,
          date: timeStamp,
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}

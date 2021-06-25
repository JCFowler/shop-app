import 'package:flutter/material.dart';

class CartModel {
  final String id;
  final String title;
  final int quantity;
  final int price;

  CartModel({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartModel> _items = {};

  Map<String, CartModel> get items {
    return {..._items};
  }

  void addItem(String productId, int price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (exisitingItem) => CartModel(
          id: exisitingItem.id,
          title: exisitingItem.title,
          quantity: exisitingItem.quantity + 1,
          price: exisitingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartModel(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void deleteItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  int get unquieItemsInCart {
    return _items.length;
  }

  int get itemsInCart {
    if (_items.isEmpty) return 0;
    var itemCount = 0;

    _items.forEach((key, value) {
      itemCount += value.quantity;
    });

    return itemCount;
  }

  int get totalAmount {
    var total = 0;

    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });

    return total;
  }
}

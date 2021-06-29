import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

import '../keys.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String token, String userId) async {
    final url = Uri.parse(FAVORITES_ID_URL(token, id, userId));
    isFavorite = !isFavorite;
    notifyListeners();

    final res = await http.put(
      url,
      body: json.encode(isFavorite),
    );

    if (res.statusCode >= 400) {
      print(res.statusCode);
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Could not favorite the item.');
    }
  }
}

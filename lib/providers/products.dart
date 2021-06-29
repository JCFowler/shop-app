import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../keys.dart';
import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String token;
  final String userId;
  List<Product> _items = [];

  Products(this.token, this.userId, this._items);

  // List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 3000,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 6000,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 2000,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 5000,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    var url = Uri.parse(FETCH_PRODUCTS_URL(token, userId, filterByUser));
    try {
      final res = await http.get(url);
      if (res.body == 'null') {
        return;
      }
      url = Uri.parse(ALL_FAVORITES_URL(token, userId));
      final favoritesRes = await http.get(url);
      final data = json.decode(res.body) as Map<String, dynamic>;
      final favoritesData = json.decode(favoritesRes.body);
      final List<Product> loadedProducts = [];
      data.forEach((id, map) {
        loadedProducts.add(
          Product(
            id: id,
            title: map['title'],
            description: map['description'],
            price: map['price'],
            imageUrl: map['imageUrl'],
            // Checks if its null. If  favoritesData[id] is null, it will become false.
            isFavorite:
                favoritesData == null ? false : favoritesData[id] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // Future<void> addProduct(Product product) {
  // final url = Uri.parse('$PRODUCTS_URL.json');
  //   return http
  //       .post(
  //     url,
  //     body: json.encode(
  //       {
  //         'title': product.title,
  //         'description': product.description,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'isFavorite': product.isFavorite,
  //       },
  //     ),
  //   )
  //       .then((res) {
  //     var newProduct = Product(
  //       id: json.decode(res.body)['name'],
  //       title: product.title,
  //       description: product.description,
  //       price: product.price,
  //       imageUrl: product.imageUrl,
  //     );
  //     _items.insert(0, newProduct);
  //     print(newProduct.id);
  //     notifyListeners();
  //   }).catchError((error) {
  //     print(error);
  //     throw (error);
  //   });
  // }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(PRODUCTS_BASE_URL(token));

    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      var newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> editProduct(Product product) async {
    final url = Uri.parse(PRODUCT_ID_URL(token, product.id));
    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          },
        ),
      );
      final productIndex =
          _items.indexWhere((element) => element.id == product.id);
      _items[productIndex] = product;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(PRODUCT_ID_URL(token, id));
    final productIndex = _items.indexWhere((element) => element.id == id);
    var deletingProduct = _items[productIndex];

    _items.removeWhere((element) => element.id == id);
    notifyListeners();

    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(productIndex, deletingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    deletingProduct.dispose();
  }
}

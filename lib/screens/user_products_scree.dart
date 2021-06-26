import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Products products = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('My Products'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add,
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: products.items.length,
            itemBuilder: (ctx, i) {
              return UserProductItem(
                products.items[i].title,
                products.items[i].imageUrl,
              );
            },
          ),
        ));
  }
}

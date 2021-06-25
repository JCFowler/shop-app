import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final CartModel cart;
  final String productId;

  CartItem(this.cart, this.productId);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cart.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) =>
          Provider.of<Cart>(context, listen: false).deleteItem(productId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 15,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 15,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text(
                    '¥${cart.price}',
                  ),
                ),
              ),
            ),
            title: Text(
              cart.title,
            ),
            subtitle: Text('¥${cart.price * cart.quantity}'),
            trailing: Text('${cart.quantity} x'),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

class CartOrderButton extends StatefulWidget {
  final Cart cart;

  CartOrderButton(this.cart);

  @override
  _CartOrderButtonState createState() => _CartOrderButtonState();
}

class _CartOrderButtonState extends State<CartOrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount == 0 || _isLoading)
          ? null
          : () {
              setState(() {
                _isLoading = true;
              });
              Provider.of<Orders>(context, listen: false)
                  .addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              )
                  .then(
                (value) {
                  setState(
                    () {
                      _isLoading = false;
                    },
                  );
                  widget.cart.clear();
                },
              );
            },
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Text('ORDER NOW'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ****** MAKE SURE YOU DO NOT SET UP A PROVIDER HERE, IT WILL BECOME A INFITY LOOP!!!!!
    // USE A CONSUER IN THE BUILDER FUNCTION.
    // final orders = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(child: Text('An Error happened...'));
            } else {
              return Consumer<Orders>(
                builder: (ctx, orders, child) => ListView.builder(
                  itemCount: orders.orders.length,
                  itemBuilder: (ctx, index) => OrderItem(orders.orders[index]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

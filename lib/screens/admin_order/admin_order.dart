
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:raj_eat/models/order_model.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});


  static Future<List<OrderModel>> getOrders() async {
    List<OrderModel> orders = [];
    QuerySnapshot eventsQuery = await FirebaseFirestore.instance.collection('ReviewCart').get();
    for (var document in eventsQuery.docs) {
      QuerySnapshot yourReviewCartSnap = await document.reference.collection('YourReviewCart').get();
      for (var orderDoc in yourReviewCartSnap.docs) {
        var orderData = orderDoc.data() as Map<String, dynamic>;
        OrderModel order = OrderModel.fromMap(orderData, document.reference.id);
        orders.add(order);
      }
    }
          return orders;
  }

  @override
  Widget build(BuildContext context) {
    print( getOrders());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders Page'),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<OrderModel> orders = snapshot.data ?? [];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              OrderModel order = orders[index];
              return ListTile(
                  title: Text('Order ID: ${order.reference}'),
                  subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('userName: ${order.userId}'),
                    Text('product id: ${order.products.first.productId}'),
                    Text('Selected Options: ${order.selectedOptions}'),
                    Text('Total Price: \$${order.totalPrice}'),
                    ],
                  )
              );
            }
          );
        },
      ),
    );
  }
}
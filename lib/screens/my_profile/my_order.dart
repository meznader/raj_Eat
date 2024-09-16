import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  // Fonction pour récupérer les commandes "En route"
  Future<List<Map<String, dynamic>>> fetchEnRouteOrders() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('LivraisonOrder')
        .where('deliveryStatus', isEqualTo: 'En route') // Filtrer par statut "En route"
        .get();

    return snapshot.docs.map((doc) => {
      'orderId': doc.id,
      ...doc.data(),
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('my order'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEnRouteOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération des commandes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande en route'));
          }

          List<Map<String, dynamic>> enRouteOrders = snapshot.data!;
          return ListView.builder(
            itemCount: enRouteOrders.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> order = enRouteOrders[index];
              String cartName = order['cartName'] ?? 'Nom inconnu'; // Nom de la commande


              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande: $cartName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Client: ${order['firstname']} ${order['lastName']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        'Total: D${order['totalAmount']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Statut de livraison: ${order['deliveryStatus']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

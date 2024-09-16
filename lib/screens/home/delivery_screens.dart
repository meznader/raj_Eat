import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raj_eat/screens/check_out/google_map/map_screen.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  Future<List<Map<String, dynamic>>> fetchDeliveryOrders() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('LivraisonOrder')
        .where('deliveryStatus', isNotEqualTo: 'Livré')
        .get();

    return snapshot.docs
        .map((doc) => {
              'orderId': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('LivraisonOrder')
        .doc(orderId)
        .update({
      'deliveryStatus': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDeliveryOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur lors de la récupération des commandes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande à livrer'));
          }

          List<Map<String, dynamic>> deliveries = snapshot.data!;
          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> delivery = deliveries[index];
              String deliveryStatus =
                  delivery['deliveryStatus'] ?? 'En attente';
              String cartName = delivery['cartName'] ?? 'Nom inconnu';

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: deliveryStatus == 'Livré'
                        ? Colors.green
                        : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande: $cartName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Client: ${delivery['firstname']} ${delivery['lastName']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Adresse: ${delivery['address']}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total: D${delivery['totalAmount']}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Statut de livraison: $deliveryStatus',
                        style: TextStyle(
                          color: deliveryStatus == 'Livré'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusButton(
                              deliveryStatus, delivery['orderId']),
                          IconButton(
                            icon:
                                const Icon(Icons.map, color: Colors.blueAccent),
                            onPressed: () {
                              print(
                                  '->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${delivery}');
                              _navigateToMap(
                                  context,
                                  delivery['latitude'] ??
                                      1.0, // Use real data from Firestore
                                  delivery['longitude'] ?? 1.0,
                                  delivery[
                                      'userId'] // Use real data from Firestore
                                  );
                            },
                          ),
                        ],
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

  Widget _buildStatusButton(String status, String orderId) {
    if (status == 'En route') {
      return ElevatedButton(
        onPressed: () => _markAsDelivered(orderId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: const Text('Marquer comme livré'),
      );
    } else if (status == 'Livré') {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return ElevatedButton(
        onPressed: () => _markAsEnRoute(orderId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        child: const Text('Marquer comme "En route"'),
      );
    }
  }

  void _markAsEnRoute(String orderId) async {
    await updateDeliveryStatus(orderId, 'En route');
    setState(() {});
  }

  void _markAsDelivered(String orderId) async {
    await updateDeliveryStatus(orderId, 'Livré');
    setState(() {});
  }

  // Navigate to map page with latitude and longitude
  void _navigateToMap(
      BuildContext context, double latitude, double longitude, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(latitude: latitude, longitude: longitude, userId: userId),
      ),
    );
  }
}

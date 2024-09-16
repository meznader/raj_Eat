import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  // Fonction pour récupérer les commandes depuis la collection 'order'
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('order').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // Fonction pour mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status, String userId, String cartName) async {
    try {
      // Mettre à jour le statut dans la collection 'order'
      await FirebaseFirestore.instance.collection('order').doc(orderId).update({
        'status': status,
      });

      // Si la commande est acceptée, l'ajouter à la collection 'LivraisonOrder'
      if (status == 'Accepted') {
        DocumentSnapshot<Map<String, dynamic>> orderSnapshot = await FirebaseFirestore.instance.collection('order').doc(orderId).get();

        if (orderSnapshot.exists) {
          Map<String, dynamic> orderData = orderSnapshot.data()!;
          await FirebaseFirestore.instance.collection('LivraisonOrder').doc(orderId).set({
            'orderId': orderId,
            'userId': userId,
            'cartName': cartName,
            'firstname': orderData['firstname'],
            'lastName': orderData['lastName'],
            'address': orderData['address'],
            'totalAmount': orderData['totalAmount'],
            'deliveryStatus': 'En attente', // Statut initial de livraison
            'selectedOptions': orderData['selectedOptions'],
          });
        }
      }

      // Si la commande est refusée, envoyer une notification au client
      if (status == 'Refused') {
        await FirebaseFirestore.instance.collection('Notifications').add({
          'userId': userId,
          'message': "L'admin a refusé la commande pour le plat '$cartName' en raison de stock. Si vous voulez, passez un autre plat ou attendez le stock dans 1 heure.",
          'timestamp': FieldValue.serverTimestamp(),
          'cartName': cartName, // Ajout de cartName à la notification
        });
      }

    } catch (e) {
      print('Erreur lors de la mise à jour du statut de commande : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération des commandes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande trouvée'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> order = orders[index];
              String cartName = order['cartName'] ?? 'Unknown Cart'; // Valeur par défaut si cartName est manquant

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Commande: $cartName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prénom: ${order['firstname']}'),
                      Text('Nom: ${order['lastName']}'),
                      Text('Montant Total: D${order['totalAmount']}'),
                      Text('User ID: ${order['userId']}'),
                      Text('Options sélectionnées: ${order['selectedOptions'].toString()}'),
                      Text('Statut: ${order['status'] ?? 'En attente'}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await updateOrderStatus(order['id'], 'Accepted', order['userId'], cartName);
                            },
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Changement de la couleur de fond
                            ),
                             child: const Text('Accepter'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await updateOrderStatus(order['id'], 'Refused', order['userId'], cartName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Changement de la couleur de fond
                            ),
                            child: const Text('Refuser'),
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
}

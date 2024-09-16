import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raj_eat/providers/product_provider.dart';
import 'package:raj_eat/providers/user_provider.dart';
import 'package:raj_eat/screens/admin_order/ComplaintsListPage.dart';
import 'package:raj_eat/screens/admin_order/admin_order.dart';
import 'package:raj_eat/config/colors.dart';
import 'package:raj_eat/screens/reservation/admin_reservation_page.dart';
import 'package:raj_eat/screens/stock/satistiques_page.dart';
import 'package:raj_eat/singup/sing_up_delivery.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  ProductProvider? productProvider;

  @override
  Widget build(BuildContext context) {
    productProvider = Provider.of<ProductProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    userProvider.getUserData(); // Fetch user data when the screen loads

    // Check if the user data is available
    if (userProvider.currentUserData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Example productId; replace with an actual productId or obtain it dynamically
    String exampleProductId = 'your-product-id-here';

    // Get the userId from the userProvider
    String userId = userProvider.currentUserData!.userUid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SingUpDelivery()),
                );
              },
              child: const Text('Add Delivery'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersPage()),
                );
              },
              child: const Text('Review Orders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminReservationsPage()),
                );
              },
              child: const Text('Reservations'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StatistiquesPage (),
                  ),
                );
              },
              child: const Text("View Statistics"),
            ),
            ElevatedButton(  // New button to view complaints
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintsListPage(userId: userId),  // Pass the userId to ComplaintsListPage
                  ),
                );
              },
              child: const Text('Voir les Réclamations'),
            ),
          ],
        ),
      ),
    );
  }
}

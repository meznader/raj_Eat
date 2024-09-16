import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:raj_eat/models/review_cart_model.dart';
import 'package:flutter/material.dart';

class ReviewCartProvider with ChangeNotifier {
  List<ReviewCartModel> reviewCartDataList = [];

  void addReviewCartData({
    required String cartId,
    required String cartName,
    required String cartImage,
    required int cartPrice,
    required int cartQuantity,
    required List<String> selectedOptions,
    var cartUnit,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("ReviewCart")
          .doc(user.uid)
          .collection("YourReviewCart")
          .doc(cartId)
          .set(
          {
            "cartId": cartId,
            "cartName": cartName,
            "cartImage": cartImage,
            "cartPrice": cartPrice,
            "cartQuantity": cartQuantity,
            "cartUnit": cartUnit,
            "selectedOptions": selectedOptions,
            "isAdd": true,
          }
      );
    }
  }

  void updateReviewCartData({
    required String cartId,
    required String cartName,
    required String cartImage,
    required int cartPrice,
    required int cartQuantity,
  }) async {
    FirebaseFirestore.instance
        .collection("ReviewCart")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("YourReviewCart")
        .doc(cartId)
        .update(
      {
        "cartId": cartId,
        "cartName": cartName,
        "cartImage": cartImage,
        "cartPrice": cartPrice,
        "cartQuantity": cartQuantity,
        "isAdd": true,
      },
    );
  }

  void getReviewCartData() async {
    List<ReviewCartModel> newList = [];

    // Check if currentUser is not null before accessing uid
    if (FirebaseAuth.instance.currentUser != null) {
      QuerySnapshot reviewCartValue = await FirebaseFirestore.instance
          .collection("ReviewCart")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("YourReviewCart")
          .get();
      for (var element in reviewCartValue.docs) {
        ReviewCartModel reviewCartModel = ReviewCartModel(
          cartId: element.get("cartId"),
          cartImage: element.get("cartImage"),
          cartName: element.get("cartName"),
          cartPrice: element.get("cartPrice"),
          cartQuantity: element.get("cartQuantity"),
          cartUnit: element.get("cartUnit"),
          selectedOptions: element.get("selectedOptions").cast<String>(),
        );
        newList.add(reviewCartModel);
      }
    }

    reviewCartDataList = newList;
    notifyListeners();
  }

  List<ReviewCartModel> get getReviewCartDataList {
    return reviewCartDataList;
  }

  getTotalPrice() {
    double total = 0.0;
    for (var element in reviewCartDataList) {
      total += element.cartPrice * element.cartQuantity;
    }
    return total;
  }

  reviewCartDataDelete(cartId) {
    FirebaseFirestore.instance
        .collection("ReviewCart")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("YourReviewCart")
        .doc(cartId)
        .delete();
    notifyListeners();
  }

  Future<QuerySnapshot<Object?>> getAllReviewCartData() async {
    List<ReviewCartModel> cartList = [];

    // Check if currentUser is not null before accessing uid
    QuerySnapshot reviewCartValue = await FirebaseFirestore.instance
        .collection("ReviewCart")
        .get();
    print('QuerySnapshot: ${reviewCartValue.docs}');

    return reviewCartValue;
  }

  // New method to mark order as in progress
  Future<void> markOrderAsInProgress(String cartId) async {
    try {
      // Check if currentUser is not null before accessing uid
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseFirestore.instance
            .collection("ReviewCart")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("YourReviewCart")
            .doc(cartId)
            .update({'status': 'In Progress'});
        notifyListeners(); // Notify listeners to refresh the UI
      }
    } catch (e) {
      print("Error updating order status: $e");
      // Handle the error (e.g., show a toast or dialog)
    }
  }
}

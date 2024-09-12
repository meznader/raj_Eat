import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raj_eat/providers/review_cart_provider.dart';

import '../config/colors.dart';
class Count extends StatefulWidget {
  final String productName;
  final String productImage;
  final String productId;
  final int productPrice;
  var productUnit;

  Count({super.key,
    required  this.productName,
    required  this.productUnit,
    required  this.productId,
    required  this.productImage,
    required  this.productPrice,
  });

  @override
  _CountState createState() => _CountState();
}

class _CountState extends State<Count> {
  int count = 1;
  bool isTrue =false;

  getAddAndQuantity() {
    FirebaseFirestore.instance
        .collection("ReviewCart")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("YourReviewCart")
        .doc(widget.productId)
        .get()
        .then(
          (value) => {
        if (mounted)
          {
            if (value.exists)
              {
                setState(() {
                  count = value.get("cartQuantity");
                  isTrue = value.get("isAdd");
                })
              }
          }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    getAddAndQuantity();
    ReviewCartProvider reviewCartProvider = Provider.of(context);
    return Container(
        height: 30,
        width: 50,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8)
        ),
        child: isTrue == true
            ?Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){


                if (count == 1){
                  setState(() {
                    isTrue = false;
                  });
                  reviewCartProvider.reviewCartDataDelete(widget.productId);
                }

                else if (count > 1){setState(() {
                  count --;
                });
                reviewCartProvider.updateReviewCartData(
                  cartId: widget.productId,
                  cartImage: widget.productImage,
                  cartName: widget.productName,
                  cartPrice: widget.productPrice,
                  cartQuantity: count,

                );
                }
              },
              child:
              const Icon(Icons.remove,size: 15,color: Color(0xffd0b84c)),
            ),
            Text(
              "$count",
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  count ++;
                });
                reviewCartProvider.updateReviewCartData(
                  cartId: widget.productId,
                  cartImage: widget.productImage,
                  cartName: widget.productName,
                  cartPrice: widget.productPrice,
                  cartQuantity: count,
                );
              },
              child:
              const Icon(Icons.add,size: 15,color: Color(0xffd0b84c),
              ),
            ),

          ],
        ):Center(
          child: InkWell(
            onTap: (){
              setState(() {
                isTrue = true;
              });
              reviewCartProvider.addReviewCartData(
                cartId: widget.productId,
                cartName: widget.productName,
                cartImage: widget.productImage,
                cartPrice: widget.productPrice,
                cartQuantity: count,
                cartUnit: widget.productUnit,
                selectedOptions: []
              );
            },
            child: Text(
              "ADD",
              style: TextStyle(color: primaryColor),
            ),
          ),
        )
    );
  }
}
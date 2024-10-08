import 'package:flutter/material.dart';
import 'package:raj_eat/config/colors.dart';
import 'package:raj_eat/models/product_model.dart';
import 'package:raj_eat/widgets/count.dart';
import 'package:raj_eat/widgets/product_unit.dart';

class SingalProduct extends StatefulWidget {
  final String productImage;
  final String productName;
  final int productPrice;
  final VoidCallback onTap;
  final String productId;
  final ProductModel productUnit;

  const SingalProduct({super.key,
    required  this.productId ,
    required this.productImage ,
    required this.productName ,
    required this.productPrice ,
    this.onTap = _defaultOnTap,
    required this.productUnit,
  });

  static void _defaultOnTap() {
    // Default empty function
  }

  @override
  State<SingalProduct> createState() => _SingalProductState();
}

class _SingalProductState extends State<SingalProduct> {
  var unitData;
  var firstValue;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            height: 230,
            width: 165,
            decoration: BoxDecoration(
              color: const Color(0xffd9dad9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    child: Image.network(
                      widget.productImage,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.productPrice}D',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Count(
                              productId: widget.productId,
                              productImage: widget.productImage,
                              productName: widget.productName,
                              productPrice: widget.productPrice,

                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
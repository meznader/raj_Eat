import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:raj_eat/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  ProductModel productModel = ProductModel(
    productImage: "", // Empty string for image
    productName: "",   // Empty string for name
    productPrice: 0,
    productId: "",
    productQuantity:0

  );



  List<ProductModel>search =[];
  productModels(QueryDocumentSnapshot element) {

    productModel = ProductModel(
      productImage: element.get("productImage"),
      productName: element.get("productName"),
      productPrice: element.get("productPrice"),
      productId: element.get("productId"),
      productQuantity: 0,
    );
    search.add(productModel);
  }

  List<ProductModel> pizzaProductList = [];

  fetchPizzaProductData() async {
    List<ProductModel> newList = [];
    QuerySnapshot value =
    await FirebaseFirestore.instance.collection("PizzaProduct").get();

    for (var element in value.docs) {
      productModels(element);
      newList.add(productModel);
    }
    pizzaProductList = newList;
    notifyListeners();
  }

  List<ProductModel> get getPizzaProductDataList{
    return pizzaProductList;
  }
  
  List<ProductModel> SandwichProductList = [];

  fetchSandwichProductData() async {
    List<ProductModel> newList = [];
    QuerySnapshot value =
    await FirebaseFirestore.instance.collection("SandwichProduct").get();

    for (var element in value.docs) {
      productModels(element);

      newList.add(productModel);
    }
    SandwichProductList = newList;
    notifyListeners();
  }

  List<ProductModel> get getSandwichProductDataList{
    return SandwichProductList;
  }
  
  List<ProductModel> MakloubProductList = [];

  fetchMakloubProductData() async {
    List<ProductModel> newList = [];
    QuerySnapshot value =
    await FirebaseFirestore.instance.collection("MakloubProduct").get();

    for (var element in value.docs) {
      productModels(element);

      newList.add(productModel);
    }
    MakloubProductList = newList;
    notifyListeners();
  }

  List<ProductModel> get getMakloubProductDataList{
    return MakloubProductList;
  }

  ProductModel? productById(String productId){
    return search.firstWhere((ProductModel product) => product.productId == productId);
  }
  List<ProductModel> get getAllProductSearch{
    return search;

  }
}
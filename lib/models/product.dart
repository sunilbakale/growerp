// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
    String productId;
    String name;
    double price;
    String productCategoryId;
    String categoryName;
    String image;

    Product({
        this.productId,
        this.name,
        this.price,
        this.productCategoryId,
        this.categoryName,
        this.image,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["productId"],
        name: json["name"],
        price: json["price"],
        productCategoryId: json["productCategoryId"],
        categoryName: json["categoryName"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "productId": productId,
        "name": name,
        "price": price,
        "productCategoryId": productCategoryId,
        "categoryName": categoryName,
        "image": image,
    };
}

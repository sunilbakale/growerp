// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:money/money.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product extends Equatable{
  final String productId;
  final String name;
  final Money price;
  final String productCategoryId;
  final String image;

  Product({
    this.productId,
    this.name,
    this.price,
    this.productCategoryId,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        productId: json["productId"],
        name: json["name"],
        price: Money.fromString(json["price"].toString(), Currency(json["currencyId"])),
        productCategoryId: json["productCategoryId"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "name": name,
        "price": price.amount,
        "currencyId": price.currency,
        "productCategoryId": productCategoryId,
        "image": image,
      };

  @override
  List get props => [productId, name, price.amount, price.currency,
    productCategoryId, image];  
}

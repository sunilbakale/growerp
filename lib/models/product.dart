// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:money/money.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product extends Equatable{
  final String productId;
  final String name;
  final Money price;
  final String productCategoryId;
  final image;

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
        price: json["price"].indexOf('.') != -1 && json["price"].indexOf('.') == json["price"].length - 2?
          Money.fromString(json["price"]+'0', Currency(json["currencyId"])):
          Money.fromString(json["price"], Currency(json["currencyId"])),
        productCategoryId: json["productCategoryId"],
        image: json["image"]!= null && json["image"].indexOf('data:image') == 0?
          MemoryImage(base64.decode(json["image"].substring(22))):
          MemoryImage(base64.decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="))
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "name": name,
        "price": price.amount.toString(),
        "currencyId": price.currency.toString(),
        "productCategoryId": productCategoryId,
        "image": image,
      };

  @override
  List get props => [productId, name, price.amount, price.currency,
    productCategoryId, image];  
}

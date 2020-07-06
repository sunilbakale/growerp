// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product extends Equatable {
  final String productId;
  final String name;
  final double price;
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
      price: double.parse(json["price"]),
      productCategoryId: json["productCategoryId"],
      image: json["image"] != null && json["image"].indexOf('data:image') == 0
          ? MemoryImage(base64.decode(json["image"].substring(22)))
          : MemoryImage(base64.decode(
              "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==")));

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "name": name,
        "price": price,
        "productCategoryId": productCategoryId,
        "image": image,
      };

  @override
  List get props => [productId, name, price, productCategoryId, image];
}

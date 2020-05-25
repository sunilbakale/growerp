// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';
import 'package:equatable/equatable.dart';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category extends Equatable{
    final String productCategoryId;
    final String categoryName;
    final String preparationAreaId;
    final String description;
    final String image;

    Category({
        this.productCategoryId,
        this.categoryName,
        this.preparationAreaId,
        this.description,
        this.image,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        productCategoryId: json["productCategoryId"],
        categoryName: json["categoryName"],
        preparationAreaId: json["preparationAreaId"],
        description: json["description"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "productCategoryId": productCategoryId,
        "categoryName": categoryName,
        "preparationAreaId": preparationAreaId,
        "description": description,
        "image": image,
    };

    @override
    List get props => [productCategoryId, categoryName,
         preparationAreaId, description, image];
}

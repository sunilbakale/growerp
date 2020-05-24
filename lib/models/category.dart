// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
    String productCategoryId;
    String categoryName;
    String preparationAreaId;
    String description;
    String image;

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
}

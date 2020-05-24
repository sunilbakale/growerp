// To parse this JSON data, do
//
//     final productsAndCategories = productsAndCategoriesFromJson(jsonString);

import 'models.dart';
import 'dart:convert';

ProductsAndCategories productsAndCategoriesFromJson(String str) => ProductsAndCategories.fromJson(json.decode(str));

String productsAndCategoriesToJson(ProductsAndCategories data) => json.encode(data.toJson());

class ProductsAndCategories {
    List<Category> categories;
    List<Product> products;

    ProductsAndCategories({
        this.categories,
        this.products,
    });

    factory ProductsAndCategories.fromJson(Map<String, dynamic> json) => ProductsAndCategories(
        categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

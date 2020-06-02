// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';
import 'package:money/money.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    this.orderId,
    this.orderStatusId,
    this.currencyUomId,
    this.placedDate,
    this.placedTime,
    this.partyId,
    this.firstName,
    this.lastName,
    this.statusId,
    this.grandTotal,
    this.table,
    this.accommodationAreaId,
    this.accommodationSpotId,
    this.orderItems,
  });

  String orderId;
  String orderStatusId;
  String currencyUomId;
  String placedDate;
  String placedTime;
  String partyId;
  String firstName;
  String lastName;
  String statusId;
  double grandTotal;
  String table;
  String accommodationAreaId;
  String accommodationSpotId;
  List<OrderItem> orderItems;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["orderId"],
        orderStatusId: json["orderStatusId"],
        currencyUomId: json["currencyUomId"],
        placedDate: json["placedDate"],
        placedTime: json["placedTime"],
        partyId: json["partyId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        statusId: json["statusId"],
        grandTotal: json["grandTotal"].toDouble(),
        accommodationAreaId: json["accommodationAreaId"],
        accommodationSpotId: json["accommodationSpotId"],
        orderItems: List<OrderItem>.from(
            json["items"].map((x) => OrderItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "orderStatusId": orderStatusId,
        "currencyUomId": currencyUomId,
        "placedDate": placedDate,
        "placedTime": placedTime,
        "partyId": partyId,
        "firstName": firstName,
        "lastName": lastName,
        "statusId": statusId,
        "grandTotal": grandTotal,
        "table": table,
        "accommodationAreaId": accommodationAreaId,
        "accommodationSpotId": accommodationSpotId,
        "items": List<dynamic>.from(orderItems.map((x) => x.toJson())),
      };
}

class OrderItem {
  OrderItem({
    this.orderItemSeqId,
    this.productId,
    this.description,
    this.quantity,
    this.price,
  });

  String orderItemSeqId;
  String productId;
  String description;
  int quantity;
  Money price;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        orderItemSeqId: json["orderItemSeqId"],
        productId: json["productId"],
        description: json["description"],
        quantity: json["quantity"],
        price: json["price"].indexOf('.') != -1 && json["price"].indexOf('.') == json["price"].length - 2?
          Money.fromString(json["price"]+'0', Currency(json["currencyId"])):
          Money.fromString(json["price"], Currency(json["currencyId"])),
      );

  Map<String, dynamic> toJson() => {
        "orderItemSeqId": orderItemSeqId,
        "productId": productId,
        "description": description,
        "quantity": quantity,
        "currencyId": price.currency,
        "price": price.amount.toString(),
      };
}

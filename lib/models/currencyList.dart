// To parse this JSON data, do
//
//     final currencyList = currencyListFromJson(jsonString);

import 'dart:convert';
import 'currency.dart';

CurrencyList currencyListFromJson(String str) => CurrencyList.fromJson(json.decode(str));

String currencyListToJson(CurrencyList data) => json.encode(data.toJson());

class CurrencyList {
    List<Currency> currencyList;

    CurrencyList({
        this.currencyList,
    });

    factory CurrencyList.fromJson(Map<String, dynamic> json) => CurrencyList(
        currencyList: List<Currency>.from(json["currencyList"].map((x) => Currency.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "currencyList": List<dynamic>.from(currencyList.map((x) => x.toJson())),
    };
}



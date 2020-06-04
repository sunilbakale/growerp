// To parse this JSON data, do
//
//     final currencyIdList = currencyIdListFromJson(jsonString);

import 'dart:convert';
import 'currencyId.dart';

CurrencyIdList currencyIdListFromJson(String str) =>
    CurrencyIdList.fromJson(json.decode(str));

String currencyIdListToJson(CurrencyIdList data) => json.encode(data.toJson());

class CurrencyIdList {
  List<CurrencyId> currencyIdList;

  CurrencyIdList({
    this.currencyIdList,
  });

  factory CurrencyIdList.fromJson(Map<String, dynamic> json) => CurrencyIdList(
        currencyIdList: List<CurrencyId>.from(
            json["currencyIdList"].map((x) => CurrencyId.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "currencyIdList": List<dynamic>.from(currencyIdList.map((x) => x.toJson())),
      };
}

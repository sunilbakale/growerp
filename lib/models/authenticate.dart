// To parse this JSON data, do
//
//     final authenticate = authenticateFromJson(jsonString);

import 'dart:convert';
import 'user.dart';
import 'company.dart';

Authenticate authenticateFromJson(String str) =>
    Authenticate.fromJson(json.decode(str));

String authenticateToJson(Authenticate data) => json.encode(data.toJson());

class Authenticate {
  String apiKey;
  String moquiSessionToken;
  Company company;
  User user;

  Authenticate({
    this.apiKey,
    this.moquiSessionToken,
    this.company,
    this.user,
  });

  factory Authenticate.fromJson(Map<String, dynamic> json) => Authenticate(
        apiKey: json["apiKey"],
        moquiSessionToken: json["moquiSessionToken"],
        company: Company.fromJson(json["company"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
        "moquiSessionToken": moquiSessionToken,
        "company": company.toJson(),
        "user": user.toJson(),
      };
}

// To parse this JSON data, do
//
//     final authenticate = authenticateFromJson(jsonString);

import 'dart:convert';
import 'user.dart';

Authenticate authenticateFromJson(String str) => Authenticate.fromJson(json.decode(str));

String authenticateToJson(Authenticate data) => json.encode(data.toJson());

class Authenticate {
    String apiKey;
    String moquiSessionToken;
    User user;

    Authenticate({
        this.apiKey,
        this.moquiSessionToken,
        this.user,
    });

    factory Authenticate.fromJson(Map<String, dynamic> json) => Authenticate(
        apiKey: json["apiKey"],
        moquiSessionToken: json["moquiSessionToken"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
        "moquiSessionToken": moquiSessionToken,
        "user": user.toJson(),
    };
}

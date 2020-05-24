// To parse this JSON data, do
//
//     final userAndCompany = userAndCompanyFromJson(jsonString);

import 'models.dart';
import 'dart:convert';

UserAndCompany userAndCompanyFromJson(String str) => UserAndCompany.fromJson(json.decode(str));

String userAndCompanyToJson(UserAndCompany data) => json.encode(data.toJson());

class UserAndCompany {
    Company company;
    User user;

    UserAndCompany({
        this.company,
        this.user,
    });

    factory UserAndCompany.fromJson(Map<String, dynamic> json) => UserAndCompany(
        company: Company.fromJson(json["company"]),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "company": company.toJson(),
        "user": user.toJson(),
    };
}
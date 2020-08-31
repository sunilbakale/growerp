// To parse this JSON data, do
//
//      user = userFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

User userFromJson(String str) => User.fromJson(json.decode(str)["user"]);
String userToJson(User data) => '{"user":' + json.encode(data.toJson()) + "}";

List<User> usersFromJson(String str) =>
    List<User>.from(json.decode(str)["users"].map((x) => User.fromJson(x)));
String usersToJson(List<User> data) =>
    '{"users":' +
    json.encode(List<dynamic>.from(data.map((x) => x.toJson()))) +
    "}";

class User {
  String partyId;
  String userId;
  String firstName;
  String lastName;
  String name;
  String email;
  String groupDescription;
  String userGroupId;
  dynamic locale;
  String externalId; // when customer register they give their telno
  Uint8List image;

  User({
    this.partyId,
    this.userId,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.groupDescription,
    this.userGroupId,
    this.locale,
    this.externalId,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        partyId: json["partyId"],
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        name: json["name"],
        email: json["email"],
        groupDescription: json["groupDescription"],
        userGroupId: json["userGroupId"],
        locale: json["locale"],
        externalId: json["externalId"],
        image: json["image"] != null ? base64.decode(json["image"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "partyId": partyId,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "name": name,
        "email": email,
        "groupDescription": groupDescription,
        "userGroupId": userGroupId,
        "locale": locale,
        "externalId": externalId,
        "image": image != null ? base64.encode(image) : null,
      };

  @override
  List<Object> get props => [
        partyId,
        userId,
        firstName,
        lastName,
        name,
        email,
        groupDescription,
        userGroupId,
        locale,
        externalId,
        image,
      ];

  @override
  String toString() {
    return 'User $firstName $lastName [$partyId] img size: '
        '${image != null ? image.length : 0}';
  }
}

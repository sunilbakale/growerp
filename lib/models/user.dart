class User {
  String partyId;
  String userId;
  String firstName;
  String lastName;
  String name;
  String email;
  String groupDescription;
  String userGroupId;
  String locale;
  dynamic externalId;

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
      };
}

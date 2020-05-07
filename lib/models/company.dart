class Company {
  String partyId;
  String name;
  String email;
  String contactMechId;
  String currencyId;

  Company({
    this.partyId,
    this.name,
    this.email,
    this.contactMechId,
    this.currencyId,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        partyId: json["partyId"],
        name: json["name"],
        email: json["email"],
        currencyId: json["currencyId"],
      );

  Map<String, dynamic> toJson() => {
        "partyId": partyId,
        "name": name,
        "email": email,
        "currencyId": currencyId,
      };
}

class Company {
    String partyId;
    String name;
    String email;
    String contactMechId;
    String currency;

    Company({
        this.partyId,
        this.name,
        this.email,
        this.contactMechId,
        this.currency,
    });

    factory Company.fromJson(Map<String, dynamic> json) => Company(
        partyId: json["partyId"],
        name: json["name"],
        email: json["email"],
        contactMechId: json["contactMechId"],
        currency: json["currency"],
    );

    Map<String, dynamic> toJson() => {
        "partyId": partyId,
        "name": name,
        "email": email,
        "contactMechId": contactMechId,
        "currency": currency,
    };
}
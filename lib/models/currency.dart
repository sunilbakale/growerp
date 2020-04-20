class Currency {
  String value;
  String display;

  Currency({
    this.value,
    this.display,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        value: json["value"],
        display: json["display"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "display": display,
      };
}

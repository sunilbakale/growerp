class CurrencyId {
  String value;
  String display;

  CurrencyId({
    this.value,
    this.display,
  });

  factory CurrencyId.fromJson(Map<String, dynamic> json) => CurrencyId(
        value: json["value"],
        display: json["display"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "display": display,
      };
}

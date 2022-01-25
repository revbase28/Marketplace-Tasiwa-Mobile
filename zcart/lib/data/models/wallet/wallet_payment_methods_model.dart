// To parse this JSON data, do
//
//     final walletPaymentMethods = walletPaymentMethodsFromJson(jsonString);

import 'dart:convert';

WalletPaymentMethods walletPaymentMethodsFromJson(String str) =>
    WalletPaymentMethods.fromJson(json.decode(str));

String walletPaymentMethodsToJson(WalletPaymentMethods data) =>
    json.encode(data.toJson());

class WalletPaymentMethods {
  WalletPaymentMethods({
    required this.data,
  });

  List<Datum> data;

  factory WalletPaymentMethods.fromJson(Map<String, dynamic> json) =>
      WalletPaymentMethods(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.order,
    this.type,
    required this.code,
    required this.name,
  });

  int id;
  int order;
  String? type;
  String code;
  String name;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        order: json["order"],
        type: json["type"],
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order": order,
        "type": type,
        "code": code,
        "name": name,
      };
}

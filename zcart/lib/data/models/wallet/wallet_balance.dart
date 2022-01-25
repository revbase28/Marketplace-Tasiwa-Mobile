// To parse this JSON data, do
//
//     final walletBalanceModel = walletBalanceModelFromJson(jsonString);

import 'dart:convert';

WalletBalanceModel walletBalanceModelFromJson(String str) =>
    WalletBalanceModel.fromJson(json.decode(str));

String walletBalanceModelToJson(WalletBalanceModel data) =>
    json.encode(data.toJson());

class WalletBalanceModel {
  WalletBalanceModel({
    required this.data,
  });

  Data data;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceModel(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.balance,
    required this.balanceRaw,
  });

  String balance;
  String balanceRaw;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        balance: json["balance"],
        balanceRaw: json["balance_raw"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "balance_raw": balanceRaw,
      };
}

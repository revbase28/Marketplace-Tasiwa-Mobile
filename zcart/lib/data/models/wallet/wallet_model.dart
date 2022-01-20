// To parse this JSON data, do
//
//     final walletModel = walletModelFromJson(jsonString);

import 'dart:convert';

WalletModel walletModelFromJson(String str) =>
    WalletModel.fromJson(json.decode(str));

String walletModelToJson(WalletModel data) => json.encode(data.toJson());

class WalletModel {
  WalletModel({
    required this.wallet,
  });

  Wallet wallet;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        wallet: Wallet.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "wallet": wallet.toJson(),
      };
}

class Wallet {
  Wallet({
    required this.id,
    this.holderType,
    this.holderId,
    this.name,
    this.slug,
    this.description,
    this.meta,
    required this.balance,
    this.blocked,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String? holderType;
  int? holderId;
  String? name;
  String? slug;
  dynamic description;
  dynamic meta;
  String balance;
  dynamic blocked;
  DateTime createdAt;
  DateTime updatedAt;

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["id"],
        holderType: json["holder_type"],
        holderId: json["holder_id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        meta: json["meta"],
        balance: json["balance"],
        blocked: json["blocked"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "holder_type": holderType,
        "holder_id": holderId,
        "name": name,
        "slug": slug,
        "description": description,
        "meta": meta,
        "balance": balance,
        "blocked": blocked,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

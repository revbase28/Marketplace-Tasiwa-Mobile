// To parse this JSON data, do
//
//     final walletTransactionsModel = walletTransactionsModelFromJson(jsonString);

import 'dart:convert';

WalletTransactionsModel walletTransactionsModelFromJson(String str) =>
    WalletTransactionsModel.fromJson(json.decode(str));

String walletTransactionsModelToJson(WalletTransactionsModel data) =>
    json.encode(data.toJson());

class WalletTransactionsModel {
  WalletTransactionsModel({
    this.transactions,
  });

  Transactions? transactions;

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionsModel(
        transactions: json["transactions"] == ""
            ? null
            : Transactions.fromJson(json["transactions"]),
      );

  Map<String, dynamic> toJson() => {
        "transactions": transactions?.toJson(),
      };
}

class Transactions {
  Transactions({
    required this.currentPage,
    this.data,
    required this.firstPageUrl,
    required this.from,
    this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  int currentPage;
  List<TransactionData>? data;
  String firstPageUrl;
  int from;
  int? lastPage;
  String? lastPageUrl;
  List<Link> links;
  String? nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        currentPage: json["current_page"],
        data: List<TransactionData>.from(
            json["data"].map((x) => TransactionData.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data != null
            ? List<TransactionData>.from(data!.map((x) => x.toJson()))
            : null,
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class TransactionData {
  TransactionData({
    required this.id,
    required this.payableType,
    required this.payableId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balance,
    this.confirmed,
    this.approved,
    required this.meta,
    this.uuid,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String payableType;
  int payableId;
  int walletId;
  String type;
  int amount;
  String balance;
  bool? confirmed;
  int? approved;
  Meta meta;
  String? uuid;
  DateTime createdAt;
  DateTime updatedAt;

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        id: json["id"],
        payableType: json["payable_type"],
        payableId: json["payable_id"],
        walletId: json["wallet_id"],
        type: json["type"],
        amount: json["amount"],
        balance: json["balance"],
        confirmed: json["confirmed"],
        approved: json["approved"],
        meta: Meta.fromJson(json["meta"]),
        uuid: json["uuid"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "payable_type": payableType,
        "payable_id": payableId,
        "wallet_id": walletId,
        "type": type,
        "amount": amount,
        "balance": balance,
        "confirmed": confirmed,
        "approved": approved,
        "meta": meta.toJson(),
        "uuid": uuid,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta({
    this.type,
    this.description,
  });

  String? type;
  String? description;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        type: json["type"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "description": description,
      };
}

class Link {
  Link({
    this.url,
    this.label,
    this.active,
  });

  String? url;
  String? label;
  bool? active;

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

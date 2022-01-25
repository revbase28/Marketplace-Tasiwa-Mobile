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
    required this.data,
    required this.links,
    required this.meta,
  });

  List<TransactionData> data;
  Links links;
  Meta meta;

  factory WalletTransactionsModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionsModel(
        data: List<TransactionData>.from(
            json["data"].map((x) => TransactionData.fromJson(x))),
        links: Links.fromJson(json["links"]),
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "links": links.toJson(),
        "meta": meta.toJson(),
      };
}

class TransactionData {
  TransactionData({
    required this.id,
    required this.date,
    this.description,
    this.type,
    required this.amount,
    required this.amountRaw,
    required this.balance,
    required this.balanceRaw,
  });

  int id;
  String date;
  String? description;
  String? type;
  String amount;
  int amountRaw;
  String balance;
  String balanceRaw;

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        id: json["id"],
        date: json["date"],
        description: json["description"],
        type: json["type"],
        amount: json["amount"],
        amountRaw: json["amount_raw"],
        balance: json["balance"],
        balanceRaw: json["balance_raw"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "description": description,
        "type": type,
        "amount": amount,
        "amount_raw": amountRaw,
        "balance": balance,
        "balance_raw": balanceRaw,
      };
}

class Links {
  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  String? first;
  String? last;
  dynamic prev;
  String? next;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        first: json["first"],
        last: json["last"],
        prev: json["prev"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "first": first,
        "last": last,
        "prev": prev,
        "next": next,
      };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  List<Link>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "links": links == null
            ? null
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
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

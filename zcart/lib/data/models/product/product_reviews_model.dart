import 'dart:convert';

ProductReviewsModel productReviewsModelFromJson(String str) =>
    ProductReviewsModel.fromJson(json.decode(str));

String productReviewsModelToJson(ProductReviewsModel data) =>
    json.encode(data.toJson());

class ProductReviewsModel {
  ProductReviewsModel({
    this.data,
    this.links,
    this.meta,
  });

  List<ProductReview>? data;
  Links? links;
  Meta? meta;

  factory ProductReviewsModel.fromJson(Map<String, dynamic> json) =>
      ProductReviewsModel(
        data: List<ProductReview>.from(
            json["data"].map((x) => ProductReview.fromJson(x))),
        links: Links.fromJson(json["links"]),
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "links": links == null ? null : links!.toJson(),
        "meta": meta == null ? null : meta!.toJson(),
      };
}

class ProductReview {
  ProductReview({
    required this.id,
    required this.rating,
    required this.comment,
    this.approved,
    this.spam,
    this.updatedAt,
    this.labels,
    required this.customer,
  });

  int id;
  int rating;
  String comment;
  bool? approved;
  bool? spam;
  String? updatedAt;
  List<String>? labels;
  Customer customer;

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        id: json["id"],
        rating: json["rating"],
        comment: json["comment"],
        approved: json["approved"],
        spam: json["spam"],
        updatedAt: json["updated_at"],
        labels: List<String>.from(json["labels"].map((x) => x)),
        customer: Customer.fromJson(json["customer"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "comment": comment,
        "approved": approved,
        "spam": spam,
        "updated_at": updatedAt,
        "labels":
            labels == null ? null : List<dynamic>.from(labels!.map((x) => x)),
        "customer": customer.toJson(),
      };
}

class Customer {
  Customer({
    this.id,
    this.name,
    this.avatar,
  });

  int? id;
  String? name;
  String? avatar;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "avatar": avatar,
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
  dynamic next;

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
    required this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  List<Link> links;
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
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
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

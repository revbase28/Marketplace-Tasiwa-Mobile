import 'dart:convert';

VendorReviewsModel vendorReviewsModelFromJson(String str) =>
    VendorReviewsModel.fromJson(json.decode(str));

String vendorReviewsModelToJson(VendorReviewsModel data) =>
    json.encode(data.toJson());

class VendorReviewsModel {
  VendorReviewsModel({
    this.data,
    this.links,
    this.meta,
  });

  List<VendorReview>? data;
  Links? links;
  Meta? meta;

  factory VendorReviewsModel.fromJson(Map<String, dynamic> json) =>
      VendorReviewsModel(
        data: List<VendorReview>.from(
            json["data"].map((x) => VendorReview.fromJson(x))),
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

class VendorReview {
  VendorReview({
    this.id,
    this.rating,
    this.comment,
    this.approved,
    this.spam,
    this.updatedAt,
  });

  int? id;
  int? rating;
  String? comment;
  bool? approved;
  bool? spam;
  String? updatedAt;

  factory VendorReview.fromJson(Map<String, dynamic> json) => VendorReview(
        id: json["id"],
        rating: json["rating"],
        comment: json["comment"],
        approved: json["approved"],
        spam: json["spam"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "comment": comment,
        "approved": approved,
        "spam": spam,
        "updated_at": updatedAt,
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

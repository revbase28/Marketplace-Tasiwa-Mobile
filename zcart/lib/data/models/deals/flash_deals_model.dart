import 'dart:convert';

FlashDealsModel flashDealsFromJson(String str) =>
    FlashDealsModel.fromJson(json.decode(str));

String flashDealsToJson(FlashDealsModel data) => json.encode(data.toJson());

class FlashDealsModel {
  FlashDealsModel({
    required this.listings,
    required this.featured,
    this.meta,
  });

  List<Featured> listings;
  List<Featured> featured;
  Meta? meta;

  factory FlashDealsModel.fromJson(Map<String, dynamic> json) =>
      FlashDealsModel(
        listings: json["listings"] == null
            ? []
            : List<Featured>.from(
                json["listings"].map((x) => Featured.fromJson(x))),
        featured: json["featured"] == null
            ? []
            : List<Featured>.from(
                json["featured"].map((x) => Featured.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "listings": List<dynamic>.from(listings.map((x) => x.toJson())),
        "featured": List<dynamic>.from(featured.map((x) => x.toJson())),
        "meta": meta?.toJson(),
      };
}

class Featured {
  Featured({
    this.id,
    this.slug,
    this.productId,
    this.title,
    this.condition,
    this.hasOffer,
    this.rawPrice,
    this.currency,
    this.currencySymbol,
    this.price,
    this.offerPrice,
    this.discount,
    this.offerStart,
    this.offerEnd,
    this.rating,
    this.stuffPick,
    this.freeShipping,
    this.hotItem,
    this.labels,
    this.image,
  });

  int? id;
  String? slug;
  int? productId;
  String? title;
  String? condition;
  bool? hasOffer;
  String? rawPrice;
  String? currency;
  String? currencySymbol;
  String? price;
  dynamic offerPrice;
  dynamic discount;
  dynamic offerStart;
  dynamic offerEnd;
  dynamic rating;
  bool? stuffPick;
  bool? freeShipping;
  bool? hotItem;
  List<String>? labels;
  String? image;

  factory Featured.fromJson(Map<String, dynamic> json) => Featured(
        id: json["id"],
        slug: json["slug"],
        productId: json["product_id"],
        title: json["title"],
        condition: json["condition"],
        hasOffer: json["has_offer"],
        rawPrice: json["raw_price"],
        currency: json["currency"],
        currencySymbol: json["currency_symbol"],
        price: json["price"],
        offerPrice: json["offer_price"],
        discount: json["discount"],
        offerStart: json["offer_start"],
        offerEnd: json["offer_end"],
        rating: json["rating"],
        stuffPick: json["stuff_pick"],
        freeShipping: json["free_shipping"],
        hotItem: json["hot_item"],
        labels: List<String>.from(json["labels"].map((x) => x)),
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "product_id": productId,
        "title": title,
        "condition": condition,
        "has_offer": hasOffer,
        "raw_price": rawPrice,
        "currency": currency,
        "currency_symbol": currencySymbol,
        "price": price,
        "offer_price": offerPrice,
        "discount": discount,
        "offer_start": offerStart,
        "offer_end": offerEnd,
        "rating": rating,
        "stuff_pick": stuffPick,
        "free_shipping": freeShipping,
        "hot_item": hotItem,
        "labels": List<dynamic>.from(labels?.map((x) => x) ?? []),
        "image": image,
      };
}

class Meta {
  Meta({
    this.dealTitle,
    this.endTime,
  });

  String? dealTitle;
  DateTime? endTime;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        dealTitle: json["deal_title"],
        endTime: DateTime.parse(json["end_time"]),
      );

  Map<String, dynamic> toJson() => {
        "deal_title": dealTitle,
        "end_time": endTime?.toIso8601String() ?? "",
      };
}

// To parse this JSON data, do
//
//     final dealOfTheDay = dealOfTheDayFromMap(jsonString);

import 'dart:convert';

DealOfTheDay dealOfTheDayFromMap(String str) =>
    DealOfTheDay.fromMap(json.decode(str));

String dealOfTheDayToMap(DealOfTheDay data) => json.encode(data.toMap());

class DealOfTheDay {
  DealOfTheDay({
    this.data,
  });

  Data? data;

  factory DealOfTheDay.fromMap(Map<String, dynamic> json) => DealOfTheDay(
        data: Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "data": data!.toMap(),
      };
}

class Data {
  Data({
    this.id,
    this.slug,
    this.title,
    this.brand,
    this.condition,
    this.description,
    this.keyFeatures,
    this.stockQuantity,
    this.hasOffer,
    this.rawPrice,
    this.currency,
    this.currencySymbol,
    this.price,
    this.offerPrice,
    this.discount,
    this.offerStart,
    this.offerEnd,
    this.images,
    this.feedbacksCount,
    this.rating,
    this.freeShipping,
    this.stuffPick,
    this.labels,
  });

  int? id;
  String? slug;
  String? title;
  String? brand;
  String? condition;
  String? description;
  List<String>? keyFeatures;
  int? stockQuantity;
  bool? hasOffer;
  String? rawPrice;
  String? currency;
  String? currencySymbol;
  String? price;
  dynamic offerPrice;
  dynamic discount;
  dynamic offerStart;
  dynamic offerEnd;
  List<Image>? images;
  dynamic feedbacksCount;
  dynamic rating;
  bool? freeShipping;
  bool? stuffPick;
  List<dynamic>? labels;

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        id: json["id"],
        slug: json["slug"],
        title: json["title"],
        brand: json["brand"],
        condition: json["condition"],
        description: json["description"],
        keyFeatures: List<String>.from(json["key_features"].map((x) => x)),
        stockQuantity: json["stock_quantity"],
        hasOffer: json["has_offer"],
        rawPrice: json["raw_price"],
        currency: json["currency"],
        currencySymbol: json["currency_symbol"],
        price: json["price"],
        offerPrice: json["offer_price"],
        discount: json["discount"],
        offerStart: json["offer_start"],
        offerEnd: json["offer_end"],
        images: List<Image>.from(json["images"].map((x) => Image.fromMap(x))),
        feedbacksCount: json["feedbacks_count"],
        rating: json["rating"],
        freeShipping: json["free_shipping"],
        stuffPick: json["stuff_pick"],
        labels: List<dynamic>.from(json["labels"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "slug": slug,
        "title": title,
        "brand": brand,
        "condition": condition,
        "description": description,
        "key_features": List<dynamic>.from(keyFeatures?.map((x) => x) ?? []),
        "stock_quantity": stockQuantity,
        "has_offer": hasOffer,
        "raw_price": rawPrice,
        "currency": currency,
        "currency_symbol": currencySymbol,
        "price": price,
        "offer_price": offerPrice,
        "discount": discount,
        "offer_start": offerStart,
        "offer_end": offerEnd,
        "images": List<dynamic>.from(images?.map((x) => x.toMap()) ?? []),
        "feedbacks_count": feedbacksCount,
        "rating": rating,
        "free_shipping": freeShipping,
        "stuff_pick": stuffPick,
        "labels": List<dynamic>.from(labels?.map((x) => x) ?? []),
      };
}

class Image {
  Image({
    this.id,
    this.path,
    this.name,
    this.extension,
    this.order,
    this.featured,
  });

  dynamic id;
  String? path;
  dynamic name;
  dynamic extension;
  dynamic order;
  dynamic featured;

  factory Image.fromMap(Map<String, dynamic> json) => Image(
        id: json["id"],
        path: json["path"],
        name: json["name"],
        extension: json["extension"],
        order: json["order"],
        featured: json["featured"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "path": path,
        "name": name,
        "extension": extension,
        "order": order,
        "featured": featured,
      };
}

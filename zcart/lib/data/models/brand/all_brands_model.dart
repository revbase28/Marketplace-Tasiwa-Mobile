// To parse this JSON data, do
//
//     final allBrands = allBrandsFromMap(jsonString);

import 'dart:convert';

AllBrands allBrandsFromMap(String str) => AllBrands.fromMap(json.decode(str));

String allBrandsToMap(AllBrands data) => json.encode(data.toMap());

class AllBrands {
  AllBrands({
    required this.data,
  });

  List<Brands> data;

  factory AllBrands.fromMap(Map<String, dynamic> json) => AllBrands(
        data: List<Brands>.from(json["data"].map((x) => Brands.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class Brands {
  Brands({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.availableFrom,
    this.image,
  });

  int? id;
  String? name;
  String? slug;
  String? description;
  String? availableFrom;
  String? image;

  factory Brands.fromMap(Map<String, dynamic> json) => Brands(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        availableFrom: json["available_from"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "available_from": availableFrom,
        "image": image,
      };
}

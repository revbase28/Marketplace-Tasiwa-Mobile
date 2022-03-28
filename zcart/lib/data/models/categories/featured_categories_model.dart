class FeaturedCategoriesModel {
  FeaturedCategoriesModel({
    this.data,
  });

  List<FeaturedCategories>? data;

  factory FeaturedCategoriesModel.fromMap(Map<String, dynamic> json) =>
      FeaturedCategoriesModel(
        data: json["data"] == null
            ? null
            : List<FeaturedCategories>.from(
                json["data"].map((x) => FeaturedCategories.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class FeaturedCategories {
  FeaturedCategories({
    this.id,
    this.name,
    this.slug,
    this.featureImage,
  });

  int? id;
  String? name;
  String? slug;
  String? featureImage;

  factory FeaturedCategories.fromMap(Map<String, dynamic> json) =>
      FeaturedCategories(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        featureImage: json["feature_image"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "slug": slug,
        "feature_image": featureImage,
      };
}

class PackagingModel {
  PackagingModel({
    this.id,
    this.name,
    this.cost,
    this.costRaw,
    this.height,
    this.width,
    this.depth,
    this.packagingModelDefault,
  });

  int? id;
  String? name;
  String? cost;
  String? costRaw;
  String? height;
  String? width;
  String? depth;
  dynamic packagingModelDefault;

  factory PackagingModel.fromJson(Map<String, dynamic> json) => PackagingModel(
        id: json["id"],
        name: json["name"],
        cost: json["cost"],
        costRaw: json["cost_raw"],
        height: json["height"],
        width: json["width"],
        depth: json["depth"],
        packagingModelDefault: json["default"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "cost": cost,
        "cost_raw": costRaw,
        "height": height,
        "width": width,
        "depth": depth,
        "default": packagingModelDefault,
      };
}

class Items {
  Items({
      this.id, 
      this.slug, 
      this.description, 
      this.quantity, 
      this.unitPrice, 
      this.total, 
      this.image,});

  Items.fromJson(dynamic json) {
    id = json['id'];
    slug = json['slug'];
    description = json['description'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    total = json['total'];
    image = json['image'];
  }
  int? id;
  String? slug;
  String? description;
  int? quantity;
  String? unitPrice;
  String? total;
  String? image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['slug'] = slug;
    map['description'] = description;
    map['quantity'] = quantity;
    map['unit_price'] = unitPrice;
    map['total'] = total;
    map['image'] = image;
    return map;
  }

}
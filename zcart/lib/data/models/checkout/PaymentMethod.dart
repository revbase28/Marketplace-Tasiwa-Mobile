class PaymentMethod {
  PaymentMethod({
      this.id, 
      this.order, 
      this.type, 
      this.code, 
      this.name,});

  PaymentMethod.fromJson(dynamic json) {
    id = json['id'];
    order = json['order'];
    type = json['type'];
    code = json['code'];
    name = json['name'];
  }
  int? id;
  int? order;
  String? type;
  String? code;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['order'] = order;
    map['type'] = type;
    map['code'] = code;
    map['name'] = name;
    return map;
  }

}
class Customer {
  Customer({
      this.id, 
      this.name, 
      this.email, 
      this.phoneNumber, 
      this.active, 
      this.avatar,});

  Customer.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    active = json['active'];
    avatar = json['avatar'];
  }
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  bool? active;
  String? avatar;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone_number'] = phoneNumber;
    map['active'] = active;
    map['avatar'] = avatar;
    return map;
  }

}
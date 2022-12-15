import 'Order.dart';

class CheckoutModel2 {
  CheckoutModel2({
      this.message,
      this.order,});

  CheckoutModel2.fromJson(dynamic json) {
    message = json['message'];
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }
  String? message;
  Order? order;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (order != null) {
      map['order'] = order!.toJson();
    }
    return map;
  }

}
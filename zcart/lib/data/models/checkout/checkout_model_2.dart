class CheckoutModel2 {
  CheckoutModel2({
      this.message, 
      this.snapToken,});

  CheckoutModel2.fromJson(dynamic json) {
    message = json['message'];
    snapToken = json['snap_token'];
  }
  String? message;
  String? snapToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['snap_token'] = snapToken;
    return map;
  }

}
import 'PaymentMethod.dart';
import 'Customer.dart';
import 'Shop.dart';
import 'Items.dart';

class Order {
  Order({
      this.id, 
      this.orderNumber, 
      this.customerId, 
      this.customerPhoneNumber, 
      this.ipAddress, 
      this.email, 
      this.disputeId, 
      this.orderStatus, 
      this.paymentStatus, 
      this.paymentMethod, 
      this.messageToCustomer, 
      this.buyerNote, 
      this.shipTo, 
      this.shippingZoneId, 
      this.shippingRateId, 
      this.shippingAddress, 
      this.billingAddress, 
      this.shippingWeight, 
      this.packagingId, 
      this.couponId, 
      this.total, 
      this.shipping, 
      this.packaging, 
      this.handling, 
      this.taxes, 
      this.discount, 
      this.grandTotal, 
      this.taxrate, 
      this.orderDate, 
      this.shippingDate, 
      this.deliveryDate, 
      this.goodsReceived, 
      this.canEvaluate, 
      this.trackingId, 
      this.trackingUrl, 
      this.customer, 
      this.shop, 
      this.items, 
      this.conversation, 
      this.snapToken,});

  Order.fromJson(dynamic json) {
    id = json['id'];
    orderNumber = json['order_number'];
    customerId = json['customer_id'];
    customerPhoneNumber = json['customer_phone_number'];
    ipAddress = json['ip_address'];
    email = json['email'];
    disputeId = json['dispute_id'];
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'] != null ? PaymentMethod.fromJson(json['payment_method']) : null;
    messageToCustomer = json['message_to_customer'];
    buyerNote = json['buyer_note'];
    shipTo = json['ship_to'];
    shippingZoneId = json['shipping_zone_id'];
    shippingRateId = json['shipping_rate_id'];
    shippingAddress = json['shipping_address'];
    billingAddress = json['billing_address'];
    shippingWeight = json['shipping_weight'];
    packagingId = json['packaging_id'];
    couponId = json['coupon_id'];
    total = json['total'];
    shipping = json['shipping'];
    packaging = json['packaging'];
    handling = json['handling'];
    taxes = json['taxes'];
    discount = json['discount'];
    grandTotal = json['grand_total'];
    taxrate = json['taxrate'];
    orderDate = json['order_date'];
    shippingDate = json['shipping_date'];
    deliveryDate = json['delivery_date'];
    goodsReceived = json['goods_received'];
    canEvaluate = json['can_evaluate'];
    trackingId = json['tracking_id'];
    trackingUrl = json['tracking_url'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    shop = json['shop'] != null ? Shop.fromJson(json['shop']) : null;
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    conversation = json['conversation'];
    snapToken = json['snap_token'];
  }
  int? id;
  String? orderNumber;
  int? customerId;
  String? customerPhoneNumber;
  dynamic ipAddress;
  dynamic email;
  dynamic disputeId;
  String? orderStatus;
  String? paymentStatus;
  PaymentMethod? paymentMethod;
  dynamic messageToCustomer;
  dynamic buyerNote;
  String? shipTo;
  dynamic shippingZoneId;
  dynamic shippingRateId;
  String? shippingAddress;
  String? billingAddress;
  String? shippingWeight;
  dynamic packagingId;
  dynamic couponId;
  String? total;
  String? shipping;
  dynamic packaging;
  String? handling;
  dynamic taxes;
  dynamic discount;
  String? grandTotal;
  dynamic taxrate;
  String? orderDate;
  dynamic shippingDate;
  dynamic deliveryDate;
  dynamic goodsReceived;
  bool? canEvaluate;
  dynamic trackingId;
  dynamic trackingUrl;
  Customer? customer;
  Shop? shop;
  List<Items>? items;
  dynamic conversation;
  String? snapToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['order_number'] = orderNumber;
    map['customer_id'] = customerId;
    map['customer_phone_number'] = customerPhoneNumber;
    map['ip_address'] = ipAddress;
    map['email'] = email;
    map['dispute_id'] = disputeId;
    map['order_status'] = orderStatus;
    map['payment_status'] = paymentStatus;
    if (paymentMethod != null) {
      map['payment_method'] = paymentMethod!.toJson();
    }
    map['message_to_customer'] = messageToCustomer;
    map['buyer_note'] = buyerNote;
    map['ship_to'] = shipTo;
    map['shipping_zone_id'] = shippingZoneId;
    map['shipping_rate_id'] = shippingRateId;
    map['shipping_address'] = shippingAddress;
    map['billing_address'] = billingAddress;
    map['shipping_weight'] = shippingWeight;
    map['packaging_id'] = packagingId;
    map['coupon_id'] = couponId;
    map['total'] = total;
    map['shipping'] = shipping;
    map['packaging'] = packaging;
    map['handling'] = handling;
    map['taxes'] = taxes;
    map['discount'] = discount;
    map['grand_total'] = grandTotal;
    map['taxrate'] = taxrate;
    map['order_date'] = orderDate;
    map['shipping_date'] = shippingDate;
    map['delivery_date'] = deliveryDate;
    map['goods_received'] = goodsReceived;
    map['can_evaluate'] = canEvaluate;
    map['tracking_id'] = trackingId;
    map['tracking_url'] = trackingUrl;
    if (customer != null) {
      map['customer'] = customer!.toJson();
    }
    if (shop != null) {
      map['shop'] = shop!.toJson();
    }
    if (items != null) {
      map['items'] = items!.map((v) => v.toJson()).toList();
    }
    map['conversation'] = conversation;
    map['snap_token'] = snapToken;
    return map;
  }

}
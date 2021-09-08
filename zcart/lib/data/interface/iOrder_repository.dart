import 'package:zcart/data/models/orders/orders_model.dart';

abstract class IOrderRepository {
  Future<List<Orders>> orders();

  int orderCount();

  Future<List<Orders>> moreOrders();

  Future order(orderId);
  Future orderReceived(orderId);
}

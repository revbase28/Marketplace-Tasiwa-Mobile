import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/iOrder_repository.dart';
import 'package:zcart/data/models/orders/order_details_model.dart';
import 'package:zcart/data/models/orders/orders_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderRepository extends IOrderRepository {
  late OrdersModel ordersModel;
  List<Orders> items = [];

  @override
  Future<List<Orders>> orders() async {
    items.clear();
    var responseBody;
    try {
      responseBody =
          await handleResponse(await getRequest(API.orders, bearerToken: true));
      if (responseBody.runtimeType == int) if (responseBody > 206)
        throw NetworkException();
      ordersModel = OrdersModel.fromJson(responseBody);
      items.addAll(ordersModel.data!);

      return items;
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  int orderCount() {
    return ordersModel.meta != null ? ordersModel.meta!.total ?? 0 : 0;
  }

  Future<List<Orders>> moreOrders() async {
    var responseBody;
    print("Fetch More Orders (before): ${items.length}");

    if (ordersModel.links!.next != null) {
      toast(LocaleKeys.loading.tr());
      responseBody = await handleResponse(await getRequest(
          ordersModel.links!.next.split('api/').last,
          bearerToken: true));

      ordersModel = OrdersModel.fromJson(responseBody);
      items.addAll(ordersModel.data!);
      print("Fetch More Orders (after): ${items.length}");
      return items;
    } else {
      toast(LocaleKeys.reached_to_the_end.tr());
      return items;
    }
  }

  @override
  Future order(orderId) async {
    var responseBody;
    try {
      responseBody = await handleResponse(
          await getRequest(API.order(orderId), bearerToken: true));
      if (responseBody.runtimeType == int) if (responseBody > 206)
        throw NetworkException();
      OrderModel orderDetailsModel = OrderModel.fromJson(responseBody);
      return orderDetailsModel.data;
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  Future orderReceived(orderId) async {
    var responseBody;
    var requestBody = {'goods_received': true.toString()};
    try {
      responseBody = await handleResponse(await postRequest(
          API.orderReceived(orderId), requestBody,
          bearerToken: true));
      if (responseBody.runtimeType == int) if (responseBody > 206)
        throw NetworkException();
      /*OrderDetailsModel orderDetailsModel = OrderDetailsModel.fromJson(responseBody);
      return orderDetailsModel.data;*/
    } catch (e) {
      throw NetworkException();
    }
  }
}

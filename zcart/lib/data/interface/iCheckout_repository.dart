import 'package:zcart/data/models/checkout/checkout_model.dart';
import 'package:zcart/data/models/user/user_model.dart';

abstract class ICheckoutRepository {
  Future checkout(int cartId, requestBody);
  Future guestCheckout(int cartId, requestBody);
}

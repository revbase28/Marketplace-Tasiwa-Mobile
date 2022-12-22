
import 'package:zcart/data/models/checkout/checkout_model_2.dart';

abstract class ICheckoutRepository {
  Future<CheckoutModel2> checkout(int cartId, requestBody);
  Future<String?> guestCheckout(int cartId, requestBody);

  Future<CheckoutModel2> checkoutAll(requestBody);
  Future<String?> guestCheckoutAll(requestBody);
}

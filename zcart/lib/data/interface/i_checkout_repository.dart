import '../models/checkout/Checkout_model2.dart';

abstract class ICheckoutRepository {
  Future<CheckoutModel2> checkout(int cartId, requestBody);
  Future<String?> guestCheckout(int cartId, requestBody);

  Future checkoutAll(requestBody);
  Future<String?> guestCheckoutAll(requestBody);
}

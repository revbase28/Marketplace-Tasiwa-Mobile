abstract class ICheckoutRepository {
  Future checkout(int cartId, requestBody);
  Future<String?> guestCheckout(int cartId, requestBody);

  Future checkoutAll(requestBody);
  Future<String?> guestCheckoutAll(requestBody);
}

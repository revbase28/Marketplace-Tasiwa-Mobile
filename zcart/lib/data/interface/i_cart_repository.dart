import 'package:flutter/material.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/models/cart/cart_model.dart';

abstract class ICartRepository {
  Future addToCart(
    BuildContext context, {
    required String? slug,
    int? quantity = 1,
    int? shipTo,
    int? countryId,
    int? stateId,
    int? shippingOptionId,
    int? shippingZoneId,
  });

  Future updateCart({
    required int item,
    int? listingID,
    int? quantity,
    int? shipTo,
    int? countryId,
    int? stateId,
    int? shippingZoneId,
    int? shippingOptionId,
    int? packagingId,
  });

  Future removeCart({
    required int? cartID,
    required int? listingID,
  });

  Future<List<CartItem>?> fetchCarts();

  Future<CartItemDetailsModel?> fetchCartItemDetails(cartId);
}

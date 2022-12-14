import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_cart_repository.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/models/cart/cart_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/views/shared_widgets/cart_bottom_sheet.dart';

class CartRepository implements ICartRepository {
  @override
  Future<List<CartItem>?> fetchCarts() async {
    var responseBody = await handleResponse(await getRequest(API.carts, bearerToken:true));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
    CartModel cartModel = CartModel.fromJson(responseBody);
    return cartModel.data;
  }

  @override
  Future updateCart({
    int? item,
    int? listingID,
    int? quantity = 1,
    int? shipTo,
    int? countryId,
    int? stateId,
    int? shippingZoneId,
    int? shippingOptionId,
    int? packagingId,
    String? shippingCarrier,
    String? shippingCarrierType,
    String? shippingCost
  }) async {
    var requestBody = {
      if (listingID != null) 'item': listingID.toString(),
      if (quantity != null) 'quantity': quantity.toString(),
      if (shipTo != null) 'ship_to': shipTo.toString(),
      if (countryId != null) 'ship_to_country_id': countryId.toString(),
      if (stateId != null) 'ship_to_state_id': stateId.toString(),
      if (shippingZoneId != null) 'shipping_zone_id': shippingZoneId.toString(),
      if (shippingOptionId != null)
        'shipping_option_id': shippingOptionId.toString(),
      if (packagingId != null) 'packaging_id': packagingId.toString(),
      if (shippingCarrier != null) 'shipping_carrier': shippingCarrier.toString(),
      if (shippingCarrierType != null) 'shipping_carrier_type': shippingCarrierType.toString(),
      if (shippingCost != null) 'shipping_cost' : shippingCost.toString()
    };
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await putRequest(
          API.updateCart(item), requestBody,
          bearerToken: true));
      if (responseBody.runtimeType != int) {
        toast(responseBody['message']);
      }
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
  }

  @override
  Future removeCart({int? cartID, int? listingID}) async {
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await deleteRequest(
          API.removeCart(cartID, listingID),
          bearerToken: true));
      if (responseBody.runtimeType != int) {
        toast(responseBody['message']);
      }
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
  }

  @override
  Future<CartItemDetailsModel?> fetchCartItemDetails(cartId) async {
    var responseBody = await handleResponse(
        await getRequest(API.cartItemDetails(cartId), bearerToken: true));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
    CartItemDetailsModel cartItemDetailsModel =
        CartItemDetailsModel.fromJson(responseBody);
    return cartItemDetailsModel;
  }

  @override
  Future addToCart(
    BuildContext context, {
    required String? slug,
    int? quantity = 1,
    int? shipTo,
    int? countryId,
    int? stateId,
    int? shippingOptionId,
    int? shippingZoneId,
  }) async {
    var requestBody = {
      'quantity': quantity.toString(),
      if (shipTo != null) 'ship_to': shipTo.toString(),
      if (countryId != null) 'ship_to_country_id': countryId.toString(),
      if (stateId != null) 'ship_to_state_id': stateId.toString(),
      if (shippingOptionId != null)
        'shipping_option_id': shippingOptionId.toString(),
      if (shippingZoneId != null) 'shipping_zone_id': shippingZoneId.toString()
    };
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
          API.addToCart(slug), requestBody,
          bearerToken: true));

      if (responseBody.runtimeType != int) {
        addToCartBottomSheet(context, responseBody);
      }
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
  }
}

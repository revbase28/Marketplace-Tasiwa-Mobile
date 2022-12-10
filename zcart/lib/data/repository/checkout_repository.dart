import 'package:flutter/material.dart';
import 'package:zcart/data/interface/i_checkout_repository.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

import '../models/checkout/Checkout_model2.dart';

class CheckoutRepository implements ICheckoutRepository {

  @override
  Future<String?> guestCheckout(cartId, requestBody) async {
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
        API.checkout(cartId),
        requestBody,
        bearerToken: false,
      ));
      if (responseBody.runtimeType == int && responseBody > 206) {
        throw NetworkException();
      }

      debugPrint(
          "Response Data : ${responseBody["order"]?["customer"]?["api_token"]}");

      return responseBody["order"]?["customer"]?["api_token"];
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  Future checkoutAll(requestBody) async {
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
        API.checkoutAll,
        requestBody,
        bearerToken: true,
      ));
      if (responseBody.runtimeType == int && responseBody > 206) {
        throw NetworkException();
      }
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  Future<String?> guestCheckoutAll(requestBody) async {
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
        API.checkoutAll,
        requestBody,
        bearerToken: false,
      ));
      if (responseBody.runtimeType == int && responseBody > 206) {
        throw NetworkException();
      }

      debugPrint(
          "Response Data : ${responseBody["order"]?["customer"]?["api_token"]}");

      return responseBody["order"]?["customer"]?["api_token"];
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  Future<CheckoutModel2> checkout(int cartId, requestBody) async {
      dynamic responseBody;
      try {
        responseBody = await handleResponse(await postRequest(
          API.checkout(cartId),
          requestBody,
          bearerToken: true,
        ));
        if (responseBody.runtimeType == int && responseBody > 206) {
          throw NetworkException();
        }
      } catch (e) {
        throw NetworkException();
      }

      return CheckoutModel2.fromJson(responseBody);
  }
}

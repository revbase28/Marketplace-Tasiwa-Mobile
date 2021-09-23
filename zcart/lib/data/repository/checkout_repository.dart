import 'package:flutter/material.dart';
import 'package:zcart/data/interface/iCheckout_repository.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

class CheckoutRepository implements ICheckoutRepository {
  @override
  Future checkout(cartId, requestBody) async {
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
  }

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
          "Response Data : \n${responseBody["order"]["customer"]["api_token"]}");

      return responseBody["order"]["customer"]["api_token"];
    } catch (e) {
      throw NetworkException();
    }
  }
}

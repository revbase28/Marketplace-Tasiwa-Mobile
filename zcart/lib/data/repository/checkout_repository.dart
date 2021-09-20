import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/iCheckout_repository.dart';
import 'package:zcart/data/models/user/user_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

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
  Future guestCheckout(cartId, requestBody) async {
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
      // User userModel = User.fromJson(responseBody["data"]["customer"]);

      // if (userModel.id != null) {
      //   toast(LocaleKeys.register_successful.tr());
      //   await setValue(loggedIn, true);
      //   await setValue(access, userModel.apiToken);
      // }
    } catch (e) {
      throw NetworkException();
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/models/deals/flash_deals_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';

final flashDealPluginProvider = FutureProvider<FlashDealsModel?>((ref) async {
  var _responseBody =
      await handleResponse(await getRequest(API.flashDealPlugin));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return FlashDealsModel.fromJson(_responseBody);
});

final checkAppleLoginPluginProvider = FutureProvider<bool>((ref) async {
  return await _pluginCheck("apple-login");
});

Future<bool> _pluginCheck(String pluginlsug) async {
  var _responseBody = await handleResponse(
      await getRequest(API.checkPluginAvailability(pluginlsug)));
  if (_responseBody == 1) {
    return true;
  }
  return false;
}

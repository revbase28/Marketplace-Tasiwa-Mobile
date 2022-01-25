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
  final _res = await _pluginCheck("apple-login");
  return _res;
});

final checkPharmacyPluginProvider = FutureProvider<bool>((ref) async {
  final _result = await _pluginCheck("pharmacy");
  return _result;
});

final checkWalletPluginProvider = FutureProvider<bool>((ref) async {
  final _result = await _pluginCheck("wallet");
  return _result;
});

final checkOneCheckoutPluginProvider = FutureProvider<bool>((ref) async {
  final _result = await _pluginCheck("checkout");
  return _result;
});

Future<bool> _pluginCheck(String pluginlsug) async {
  var _responseBody = await handleResponse(
      await getRequest(API.checkPluginAvailability(pluginlsug)));

  if (_responseBody.isEmpty) {
    return false;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return false;
  }

  return _responseBody["data"] is bool ? _responseBody["data"] : false;
}

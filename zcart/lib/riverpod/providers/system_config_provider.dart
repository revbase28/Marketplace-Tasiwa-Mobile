import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/models/system_config_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';

final systemConfigFutureProvider = FutureProvider<SystemConfig?>((ref) async {
  var _responseBody = await handleResponse(await getRequest(API.systemConfig));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return SystemConfig.fromJson(_responseBody);
});

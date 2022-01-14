import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

Future<dynamic> getPaymentMethodCreds(String paymentMethodCode,
    {Map<String, String>? requestBody}) async {
  final String _code = paymentMethodCode;

  Map<String, String>? _headers = {
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    "APPKEY": MyConfig.zcartApiKey,
  };
  final _uri = Uri.parse(API.base + API.paymentMethodCredential(_code));

  try {
    var _responseBody = await handleResponse(await post(
      _uri,
      body: requestBody,
      headers: _headers,
    ));

    if (_responseBody is int && _responseBody > 206) {
      return null;
    }
    if (_responseBody is String) {
      toast(LocaleKeys.something_went_wrong.tr());
      return null;
    }

    return jsonDecode(getDecryptedData(_responseBody["data"]))?["config"];

//    print("getPaymentMethodCreds: ${_data}");
  } catch (e) {
    rethrow;
  }
}

String getDecryptedData(String encryptedData) {
  try {
    final _key = Key.fromUtf8(MyConfig.zcartSecretKey);
    final _iv = IV.fromUtf8(MyConfig.zcartIV);
    final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final _encrypted = Encrypted.fromBase64(encryptedData);
    final decrypted = _encrypter.decrypt(_encrypted, iv: _iv);
    return decrypted.toString();
  } catch (e) {
    rethrow;
  }
}

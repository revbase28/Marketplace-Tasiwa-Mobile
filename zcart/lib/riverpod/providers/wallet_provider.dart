import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_wallet_repository.dart';
import 'package:zcart/data/models/wallet/wallet_balance.dart';
import 'package:zcart/data/models/wallet/wallet_payment_methods_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/data/repository/wallet_repository.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/notifier/wallet_state_notifier.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';

final walletBalanceProvider = FutureProvider<WalletBalanceModel?>((ref) async {
  var _responseBody = await handleResponse(
      await getRequest(API.walletBalance, bearerToken: true));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return WalletBalanceModel.fromJson(_responseBody);
});

final walletTransactionFutureProvider = FutureProvider((ref) async {
  await ref.read(walletNotifierProvider.notifier).getWalletTransaction();
});

final walletDepositPaymentMethodsProvider =
    FutureProvider.autoDispose<WalletPaymentMethods?>((ref) async {
  var _responseBody = await handleResponse(
      await getRequest(API.walletPaymentMethods, bearerToken: true));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return WalletPaymentMethods.fromJson(_responseBody);
});

final walletRepositoryProvider =
    Provider<IWalletRepository>((ref) => WalletRepository());

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>(
        (ref) => WalletNotifier(ref.watch(walletRepositoryProvider)));

class WalletTransfer {
  static Future<bool> transfer(String to, String amount) async {
    var _responseBody = await handleResponse(await postRequest(
        API.walletTransfer, {'email': to, 'amount': amount},
        bearerToken: true));

    if (_responseBody is String ? _responseBody.isEmpty : false) {
      return false;
    }

    if (_responseBody.runtimeType == int && _responseBody > 206) {
      return false;
    }
    toast(_responseBody['message']);
    return true;
  }
}

// amount:1000
// payment_method:{{payment_method_code}}
// card_number:4242424242424242
// exp_month:12
// exp_year:2030
// cvc:123
// payment_meta:
// payment_status:

final walletDepositProvider =
    ChangeNotifierProvider<WalletDepositProvider>((ref) {
  return WalletDepositProvider();
});

class WalletDepositProvider extends ChangeNotifier {
  String amount = "";
  String paymentMethod = "";
  String? cardNumber;
  String? expMonth;
  String? expYear;
  String? cvc;
  Map<String, String>? paymentMeta;
  String? paymentStatus;

  Future pay() async {
    var _requestBody = {
      'amount': amount,
      'payment_method': paymentMethod,
      if (paymentMethod == paypal ||
          paymentMethod == paystack ||
          paymentMethod == razorpay)
        "payment_meta": json.encode(paymentMeta),
      if (paymentMethod == paypal ||
          paymentMethod == paystack ||
          paymentMethod == razorpay)
        "payment_status": paymentStatus.toString(),
      if (cardNumber != null && paymentMethod == stripe)
        "card_number": cardNumber,
      if (expMonth != null && paymentMethod == stripe) "exp_month": expMonth,
      if (expYear != null && paymentMethod == stripe) "exp_year": expYear,
      if (cvc != null && paymentMethod == stripe) "cvc": cvc,
    };

    dynamic _responseBody;
    try {
      _responseBody = await handleResponse(await postRequest(
        API.walletDeposit,
        _requestBody,
        bearerToken: true,
      ));
      if (_responseBody.runtimeType == int && _responseBody > 206) {
        throw NetworkException();
      }
      toast(_responseBody['message']);
    } catch (e) {
      throw NetworkException();
    }
  }
}

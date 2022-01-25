import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';

class PayStackPayment {
  BuildContext context;
  String publicKey;
  String currency;
  String email;
  int price;
  bool isWalletPayement;
  PayStackPayment({
    required this.context,
    required this.email,
    required this.price,
    required this.currency,
    required this.publicKey,
    required this.isWalletPayement,
  });

  final PaystackPlugin _payStackPlugin = PaystackPlugin();

  //initialize
  Future<void> _initialize() async {
    await _payStackPlugin.initialize(publicKey: publicKey);
  }

  //get reference
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  //get payment UI
  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: "",
      cvc: "",
      expiryMonth: 0,
      expiryYear: 0,
    );
  }

  Future<bool> chargeCardAndMakePayment() async {
    return _initialize().then((_) async {
      Charge _charge = Charge()
        ..email = email
        ..currency = currency
        ..amount = isWalletPayement ? price * 100 : price
        ..reference = _getReference()
        ..card = _getCardFromUI();

      CheckoutResponse _response = await _payStackPlugin.checkout(context,
          charge: _charge,
          fullscreen: false,
          method: CheckoutMethod.card,
          logo: Image.asset(
            AppImages.logo,
            width: 30,
          ));

      if (_response.status) {
        debugPrint("Payment Successful");
        debugPrint(_response.reference);
        debugPrint(_response.toString());

        Map<String, String> _paymentMeta = {
          "reference": _response.reference!.toString(),
          "status": _response.status.toString(),
          "method": _response.method.toString(),
          "verify": _response.verify.toString(),
        };

        String _status = "paid";

        var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

        if (isWalletPayement) {
          context.read(walletDepositProvider).paymentMeta = _paymentMeta;
          context.read(walletDepositProvider).paymentStatus = _status;
        } else {
          _checkoutNotifier.paymentMeta = _paymentMeta;
          _checkoutNotifier.paymentStatus = _status;
        }

        return true;
      } else {
        debugPrint("Payment Failed");
        debugPrint(_response.message);
        return false;
      }
    });
  }
}

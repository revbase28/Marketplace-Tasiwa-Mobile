import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/images.dart';
import 'package:zcart/riverpod/providers/provider.dart';

class PayStackPayment {
  BuildContext context;
  String email;
  int price;
  PayStackPayment({
    required this.context,
    required this.email,
    required this.price,
  });

  final PaystackPlugin _payStackPlugin = PaystackPlugin();

  //initialize
  Future<void> _initialize() async {
    await _payStackPlugin.initialize(publicKey: API.paystackKey);
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
        ..currency = API.paystackCurrency
        ..amount = price
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
        print("Payment Successful");
        print(_response.reference);
        print(_response);

        Map<String, String> _paymentMeta = {
          "reference": _response.reference!,
        };

        String _status = "paid";

        var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

        _checkoutNotifier.paymentMeta = _paymentMeta;
        _checkoutNotifier.paymentStatus = _status;
        return true;
      } else {
        print("Payment Failed");
        print(_response.message);
        return false;
      }
    });
  }
}

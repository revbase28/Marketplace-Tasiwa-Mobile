import 'package:flutter/material.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/custom_payment_card_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paystack_payment.dart';

class PaymentMethods {
  PaymentMethods._();

  static Future<bool> pay(BuildContext context, String code,
      {required String email, required double price}) async {
    var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

    if (code == stripe) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CustomPaymentCardScreen(
                    cardHolderName: _checkoutNotifier.cardHolderName ?? "",
                    cardNumber: _checkoutNotifier.cardNumber ?? "",
                    expiryDate: _checkoutNotifier.expMonth == null
                        ? ""
                        : "${_checkoutNotifier.expMonth}/${_checkoutNotifier.expYear}",
                    cvvCode: _checkoutNotifier.cvc ?? "",
                  ))).then((value) {
        if (value != null && value is CreditCardResult) {
          _checkoutNotifier.cardHolderName = value.cardHolderName;
          _checkoutNotifier.cardNumber = value.cardNumber;
          _checkoutNotifier.expMonth = value.expMonth;
          _checkoutNotifier.expYear = value.expYear;
          _checkoutNotifier.cvc = value.cvc;

          return true;
        } else {
          return false;
        }
      });
    } else if (code == paystack) {
      return await PayStackPayment(context: context, email: email, price: price)
          .chargeCardAndMakePayment()
          .then((value) => value);
    } else if (code == cod || code == wire) {
      return true;
    }
    return false;
  }
}

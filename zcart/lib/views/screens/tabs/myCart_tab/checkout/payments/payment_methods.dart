import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/custom_payment_card_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paypal_payment.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paystack_payment.dart';

class PaymentMethods {
  PaymentMethods._();

  static Future<bool> pay(
    BuildContext context,
    String code, {
    required String email,
    required int price,
    CartItemDetails? cartItemDetails,
    required int shippingId,
    List<Addresses>? addresses,
  }) async {
    var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

    if (code == stripe) {
      return await Navigator.push(
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

          print("Card Details: ${value.cardNumber}");

          return true;
        } else {
          return false;
        }
      });
    } else if (code == paystack) {
      return await PayStackPayment(context: context, email: email, price: price)
          .chargeCardAndMakePayment()
          .then((value) => value);
    } else if (code == paypal) {
      if (cartItemDetails != null && addresses != null) {
        /// TODO: Implement Paypal Payment
        ///
        ///
        ///
        ///

        Map<String, dynamic> _result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PayPalPayment(
                cartItemDetails: cartItemDetails,
                address: addresses[shippingId]),
          ),
        );

        _checkoutNotifier.paymentStatus = _result["status"];
        _checkoutNotifier.paymentMeta = _result["paymentMeta"];

        print("Payment Result: $_result");

        return _result["success"];
      } else {
        return false;
      }
    } else if (code == cod || code == wire) {
      return true;
    }
    return false;
  }
}

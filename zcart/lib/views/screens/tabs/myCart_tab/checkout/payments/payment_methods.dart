import 'package:flutter/material.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/get_payment_method_creds.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/custom_payment_card_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paypal_payment.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paystack_payment.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/razorpay_payment.dart';

class PaymentMethods {
  PaymentMethods._();

  static Future<bool> pay(
    BuildContext context,
    String code, {
    required String email,
    required int price,
    CartItemDetails? cartItemDetails,
    CartMeta? cartMeta,
    required int shippingId,
    List<Addresses>? addresses,
  }) async {
    var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

    if (code == stripe) {
      return await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CustomPaymentCardScreen(
                    amount: cartItemDetails!.grandTotal!,
                    payMentMethod: stripe,
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

          debugPrint("Card Details: ${value.cardNumber}");

          return true;
        } else {
          return false;
        }
      });
    } else if (code == paystack) {
      final _result = await getPaymentMethodCreds(
        paystack,
        requestBody: cartItemDetails != null
            ? {"cart_id": cartItemDetails.id!.toString()}
            : null,
      );

      if (_result == null || _result["public_key"] == null) {
        return false;
      } else {
        return await PayStackPayment(
          context: context,
          email: email,
          price: price,
          currency: cartMeta?.currency ?? "ZAR",
          publicKey: _result["public_key"],
        ).chargeCardAndMakePayment().then((value) => value);
      }
    } else if (code == paypal) {
      final _paymentGatewayResult = await getPaymentMethodCreds(
        paypal,
        requestBody: cartItemDetails != null
            ? {"cart_id": cartItemDetails.id!.toString()}
            : null,
      );
      if (_paymentGatewayResult == null ||
          (_paymentGatewayResult!["client_id"] == null ||
              _paymentGatewayResult!["secret"] == null)) {
        return false;
      } else {
        if (cartItemDetails != null && addresses != null) {
          Map<String, dynamic>? _result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PayPalPayment(
                cartItemDetails: cartItemDetails,
                address: addresses[shippingId],
                cartMeta: cartMeta,
                clientId: _paymentGatewayResult!["client_id"],
                clientSecret: _paymentGatewayResult!["secret"],
                isSandbox: _paymentGatewayResult!["sandbox"],
              ),
            ),
          );

          _checkoutNotifier.paymentStatus = _result?["status"];
          _checkoutNotifier.paymentMeta = _result?["paymentMeta"];

          debugPrint("Payment Result: $_result");

          return _result?["success"] ?? false;
        } else {
          return false;
        }
      }
    } else if (code == razorpay) {
      final _paymentResult = await getPaymentMethodCreds(
        razorpay,
        requestBody: cartItemDetails != null
            ? {"cart_id": cartItemDetails.id!.toString()}
            : null,
      );
      if (_paymentResult == null ||
          (_paymentResult["api_key"] || _paymentResult["secret"])) {
        return false;
      } else {
        if (cartItemDetails != null && addresses != null) {
          Map<String, dynamic>? _result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => RazorpayPayment(
                email: email,
                cartItemDetails: cartItemDetails,
                address: addresses[shippingId],
                currency: cartMeta?.currency ?? "",
                apiKey: _paymentResult["api_key"],
                secretKey: _paymentResult["secret"],
              ),
            ),
          );

          _checkoutNotifier.paymentStatus = _result?["status"];
          _checkoutNotifier.paymentMeta = _result?["paymentMeta"];

          debugPrint("Payment Result: $_result");
          return _result?["success"] ?? false;
        } else {
          return false;
        }
      }
    } else if (code == cod || code == wire || code == zcartWallet) {
      return true;
    }
    return false;
  }
}

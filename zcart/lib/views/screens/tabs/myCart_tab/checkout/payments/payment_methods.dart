import 'package:flutter/material.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/get_payment_method_creds.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/custom_payment_card_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paypal_payment.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/paystack_payment.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/razorpay_payment.dart';

class PaymentMethods {
  PaymentMethods._();

  static Future<bool> pay(
    BuildContext context,
    String paymentMethodCode, {
    required String email,
    required int price,
    CartItemDetails? cartItemDetails,
    CartMeta? cartMeta,
    int? shippingId,
    List<Addresses>? addresses,
    bool isWalletDeposit = false,
  }) async {
    var _checkoutNotifier = context.read(checkoutNotifierProvider.notifier);

    if (paymentMethodCode == stripe) {
      return await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CustomPaymentCardScreen(
                    amount: cartItemDetails?.grandTotal ?? price.toString(),
                    payMentMethod: stripe,
                    cardHolderName: _checkoutNotifier.cardHolderName ?? "",
                    cardNumber: _checkoutNotifier.cardNumber ?? "",
                    expiryDate: _checkoutNotifier.expMonth == null
                        ? ""
                        : "${_checkoutNotifier.expMonth}/${_checkoutNotifier.expYear}",
                    cvvCode: _checkoutNotifier.cvc ?? "",
                  ))).then((value) {
        if (value != null && value is CreditCardResult) {
          if (isWalletDeposit) {
            context.read(walletDepositProvider).cardNumber = value.cardNumber;
            context.read(walletDepositProvider).expMonth = value.expMonth;
            context.read(walletDepositProvider).expYear = value.expYear;
            context.read(walletDepositProvider).cvc = value.cvc;
          } else {
            _checkoutNotifier.cardHolderName = value.cardHolderName;
            _checkoutNotifier.cardNumber = value.cardNumber;
            _checkoutNotifier.expMonth = value.expMonth;
            _checkoutNotifier.expYear = value.expYear;
            _checkoutNotifier.cvc = value.cvc;
          }

          debugPrint("Card Details: ${value.cardNumber}");

          return true;
        } else {
          return false;
        }
      });
    } else if (paymentMethodCode == paystack) {
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
          isWalletPayement: isWalletDeposit,
          email: email,
          price: price,
          currency: cartMeta?.currency ?? "ZAR",
          publicKey: _result["public_key"],
        ).chargeCardAndMakePayment().then((value) => value);
      }
    } else if (paymentMethodCode == paypal) {
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
        Map<String, dynamic>? _result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PayPalPayment(
              cartItemDetails: cartItemDetails,
              address: addresses != null ? addresses[shippingId ?? 0] : null,
              cartMeta: cartMeta,
              isWalletPayment: isWalletDeposit,
              price: price,
              clientId: _paymentGatewayResult!["client_id"],
              clientSecret: _paymentGatewayResult!["secret"],
              isSandbox: _paymentGatewayResult!["sandbox"],
            ),
          ),
        );

        if (isWalletDeposit) {
          context.read(walletDepositProvider).paymentStatus =
              _result?["status"];
          context.read(walletDepositProvider).paymentMeta =
              _result?["paymentMeta"];
        } else {
          _checkoutNotifier.paymentStatus = _result?["status"];
          _checkoutNotifier.paymentMeta = _result?["paymentMeta"];
        }

        debugPrint("Payment Result: $_result");

        return _result?["success"] ?? false;
      }
    } else if (paymentMethodCode == razorpay) {
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
                address: addresses[shippingId!],
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
    } else if (paymentMethodCode == cod ||
        paymentMethodCode == wire ||
        paymentMethodCode == zcartWallet) {
      return true;
    }
    return false;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/currency_widget.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class RazorpayPayment extends StatefulWidget {
  final Addresses address;
  final String email;
  final String? cartId;
  final String apiKey;
  final String secretKey;
  final String currency;
  final int grandTotal;
  final List<CartItemForPayment> cartItems;
  const RazorpayPayment({
    Key? key,
    required this.address,
    required this.email,
    this.cartId,
    required this.apiKey,
    required this.secretKey,
    required this.currency,
    required this.grandTotal,
    required this.cartItems,
  }) : super(key: key);

  @override
  _RazorpayPaymentState createState() => _RazorpayPaymentState();
}

class _RazorpayPaymentState extends State<RazorpayPayment> {
  late Razorpay _razorpay;
  bool? _result;
  Map<String, String>? _paymentMeta;
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RazorPay Checkout"),
        leading: BackButton(
          onPressed: () {
            if (_result != null && _result!) {
              Navigator.pop(context, {
                "success": _result,
                "paymentMeta": _paymentMeta,
                "status": _status,
              });
            } else {
              Navigator.pop(context, null);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _result == null
                            ? "⌛ ${LocaleKeys.pending_payment.tr()}"
                            : _result!
                                ? "✅  ${LocaleKeys.payment_success.tr()}"
                                : "❌  ${LocaleKeys.payment_failed.tr()}",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(height: 20),
                      CurrencySymbolWidget(
                          builder: (context, symbol) => symbol == null
                              ? Text(
                                  widget.grandTotal.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              : Text(
                                  symbol + widget.grandTotal.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ))
                    ],
                  ),
                ),
                Image.asset(
                  AppImages.razorpay,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onTap: _result == null
                      ? _openCheckout
                      : _result!
                          ? () {
                              Navigator.pop(context, {
                                "success": _result,
                                "paymentMeta": _paymentMeta,
                                "status": _status,
                              });
                            }
                          : _openCheckout,
                  buttonText: _result == null
                      ? LocaleKeys.make_payment.tr()
                      : _result!
                          ? LocaleKeys.continue_text.tr()
                          : LocaleKeys.try_again.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _openCheckout() async {
    String _basicAuth = 'Basic ' +
        base64Encode(utf8.encode('${widget.apiKey}:${widget.secretKey}'));

    final _response = await post(
      Uri.parse("https://api.razorpay.com/v1/orders"),
      body: json.encode({
        "amount": widget.grandTotal,
        "currency": widget.currency,
        "receipt": widget.cartId.toString(),
      }),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        HttpHeaders.authorizationHeader: _basicAuth,
      },
    );

    final _result = json.decode(_response.body);

    var options = {
      'key': widget.apiKey,
      'amount': widget.grandTotal, //in the smallest currency sub-unit.
      'name': widget.address.addressTitle!,
      'order_id': _result['id'],
      'description': widget.cartItems.first.description,
      'timeout': 240, // in seconds
      'prefill': {'contact': widget.address.phone!, 'email': widget.email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Razorpay Responseeeeeeeeeeeee : ${response.toString()}");
    debugPrint("Razorpay Responseeeeeeeeeeeee Order ID : ${response.orderId}");
    debugPrint(
        "Razorpay Responseeeeeeeeeeeee Payment ID : ${response.paymentId}");
    debugPrint(
        "Razorpay Responseeeeeeeeeeeee Signature: ${response.signature}");

    _paymentMeta = {
      'order_id': response.orderId!,
      'payment_id': response.paymentId!,
      'signature': response.signature!,
    };
    _status = "paid";
    setState(() {
      _result = true;
    });

    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _result = false;
    });
    debugPrint(
        "ERROR: " + response.code.toString() + " - " + response.message!);

    Fluttertoast.showToast(
        msg: LocaleKeys.something_went_wrong.tr(),
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }
}

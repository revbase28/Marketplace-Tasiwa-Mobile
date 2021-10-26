import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_amount_from_string.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class RazorpayPayment extends StatefulWidget {
  final CartItemDetails cartItemDetails;
  final Addresses address;
  final String email;
  const RazorpayPayment({
    Key? key,
    required this.cartItemDetails,
    required this.address,
    required this.email,
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
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _result == null
                          ? "⌛ Pending Payment"
                          : _result!
                              ? "✅ Payment Successful "
                              : "❌ Payment Failed",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.cartItemDetails.grandTotal!.toString(),
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                    ? "Make Payment"
                    : _result!
                        ? "Continue"
                        : "Try Again",
              ),
            ],
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
        base64Encode(
            utf8.encode('${API.razorPayApiKey}:${API.razorPaySecretKey}'));

    final _response = await post(
      Uri.parse("https://api.razorpay.com/v1/orders"),
      body: json.encode({
        "amount": getAmountFromString(widget.cartItemDetails.grandTotal!),
        "currency": API.razorPayCurrency,
        "receipt": widget.cartItemDetails.id.toString(),
      }),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        HttpHeaders.authorizationHeader: _basicAuth,
      },
    );

    final _result = json.decode(_response.body);

    print(getAmountFromString(widget.cartItemDetails.grandTotal!));

    var options = {
      'key': API.razorPayApiKey,
      'amount': getAmountFromString(widget
          .cartItemDetails.grandTotal!), //in the smallest currency sub-unit.
      'name': widget.address.addressTitle!,
      'order_id': _result['id'],
      'description': widget.cartItemDetails.items!.first.description,
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
    print("Razorpay Responseeeeeeeeeeeee : ${response.toString()}");
    print("Razorpay Responseeeeeeeeeeeee Order ID : ${response.orderId}");
    print("Razorpay Responseeeeeeeeeeeee Payment ID : ${response.paymentId}");
    print("Razorpay Responseeeeeeeeeeeee Signature: ${response.signature}");

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
    print("ERROR: " + response.code.toString() + " - " + response.message!);

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

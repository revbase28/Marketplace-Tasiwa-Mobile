import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_amount_from_string.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/currency_widget.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class PayPalPayment extends StatefulWidget {
  final bool isSandbox;
  final String currency;
  final String clientId;
  final String clientSecret;
  final Addresses? address;
  final bool isWalletPayment;
  final int? cartId;

  final String email;
  final double grandTotal;
  final String subtotal;
  final String taxes;
  final String shipping;
  final String handling;
  final String discount;
  final String packaging;
  final List<CartItemForPayment> cartItems;
  final String invoiceNumber;

  const PayPalPayment({
    Key? key,
    required this.isSandbox,
    required this.clientId,
    required this.currency,
    required this.clientSecret,
    required this.address,
    required this.isWalletPayment,
    this.cartId,
    required this.email,
    required this.grandTotal,
    required this.subtotal,
    required this.taxes,
    required this.shipping,
    required this.handling,
    required this.discount,
    required this.packaging,
    required this.cartItems,
    required this.invoiceNumber,
  }) : super(key: key);

  @override
  State<PayPalPayment> createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPalPayment> {
  bool? _result;
  Map<String, String>? _paymentMeta;
  String? _status;

  void _pay({
    required bool sandboxMode,
    required String clientId,
    required String clientSecret,
    required String currency,
    required List<dynamic> transaction,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: sandboxMode,
            clientId: clientId,
            secretKey: clientSecret,
            returnURL: "${API.appUrl}/return",
            cancelURL: "${API.appUrl}/cancel",
            transactions: transaction,
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              debugPrint("onSuccess: $params");

              _paymentMeta = {
                "payerID": params["payerID"],
                "paymentId": params["paymentId"],
                "token": params["token"],
              };

              _status = "paid";

              setState(() {
                _result = true;
              });
            },
            onError: (error) {
              debugPrint("onError: $error");
              toast(error.toString());
              setState(() {
                _result = false;
              });
            },
            onCancel: (params) {
              debugPrint('cancelled: $params');
              toast(params.toString());
              setState(() {
                _result = false;
              });
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _transaction = [
      {
        "amount": {
          "total": widget.grandTotal.toString(),
          "currency": widget.currency,
          "details": {
            "subtotal": widget.isWalletPayment
                ? widget.grandTotal.toString()
                : widget.subtotal,
            "tax": widget.taxes,
            "shipping": widget.shipping,
            "handling_fee":
                (double.parse(widget.handling) + double.parse(widget.packaging))
                    .toString(),
            "shipping_discount": widget.discount,
          }
        },
        "description": widget.isWalletPayment
            ? "Wallet Top Up"
            : "Payment for order ${widget.cartId ?? ""}",
        // "custom": "EBAY_EMS_90048630045645624435",
        "invoice_number": widget.invoiceNumber.toString(),
        // "soft_descriptor": "ECHI5456456766",
        "item_list": widget.isWalletPayment
            ? {
                "items": [
                  {
                    "name": "Wallet Top Up",
                    "description": "Wallet Top Up",
                    "quantity": "1",
                    "price": widget.grandTotal.toString(),
                    "currency": widget.currency,
                    "sku": "wallet_top_up",
                  }
                ]
              }
            : {
                "items": widget.cartItems
                    .map((e) => {
                          "name": e.name.toString(),
                          "description": e.description.toString(),
                          "quantity": e.quantity.toString(),
                          "price": (getDoubleAmountFromString(e.price) / 100)
                              .toString(),
                          "sku": e.sku.toString(),
                          "currency": widget.currency,
                        })
                    .toList(),
                "shipping_address": {
                  "recipient_name": widget.address?.addressTitle!.toString(),
                  "line1": widget.address?.addressLine1!.toString(),
                  "line2": widget.address?.addressLine2!.toString(),
                  "city": widget.address?.city!.toString(),
                  "country_code": "US",
                  "postal_code": widget.address?.zipCode!.toString(),
                  "phone": widget.address?.phone!.toString(),
                }
              }
      }
    ];

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text("Paypal Express Checkout"),
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
                CachedNetworkImage(
                  imageUrl:
                      "https://www.paypalobjects.com/webstatic/en_US/i/buttons/PP_logo_h_200x51.png",
                  errorWidget: (context, url, error) => const SizedBox(),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onTap: _result == null
                      ? () {
                          _pay(
                              sandboxMode: widget.isSandbox,
                              clientId: widget.clientId,
                              clientSecret: widget.clientSecret,
                              currency: widget.currency,
                              transaction: _transaction);
                        }
                      : _result!
                          ? () {
                              Navigator.pop(context, {
                                "success": _result,
                                "paymentMeta": _paymentMeta,
                                "status": _status,
                              });
                            }
                          : () {
                              _pay(
                                  sandboxMode: widget.isSandbox,
                                  clientId: widget.clientId,
                                  clientSecret: widget.clientSecret,
                                  currency: widget.currency,
                                  transaction: _transaction);
                            },
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
}

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_amount_from_string.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayPalPayment extends StatefulWidget {
  final CartItemDetails cartItemDetails;
  final Addresses address;

  const PayPalPayment({
    Key? key,
    required this.cartItemDetails,
    required this.address,
  }) : super(key: key);

  @override
  State<PayPalPayment> createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPalPayment> {
  bool? _result;
  Map<String, String>? _paymentMeta;
  String? _status;

  void _pay() => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => UsePaypal(
                sandboxMode: API.paypalSandboxMode,
                clientId: API.paypalClientId,
                secretKey: API.paypalClientSecret,
                returnURL: "${API.appUrl}/return",
                cancelURL: "${API.appUrl}/cancel",
                transactions: [
                  {
                    "amount": {
                      "total": getDoubleAmountFromString(
                              widget.cartItemDetails.grandTotal!)
                          .toString(),
                      "currency": API.payPalCurrency,
                      "details": {
                        "subtotal": getDoubleAmountFromString(
                                widget.cartItemDetails.total!)
                            .toString(),
                        "tax": getDoubleAmountFromString(
                                widget.cartItemDetails.taxes!)
                            .toString(),
                        "shipping": getDoubleAmountFromString(
                                widget.cartItemDetails.shipping!)
                            .toString(),
                        "handling_fee": (getDoubleAmountFromString(
                                    widget.cartItemDetails.handling!) +
                                getDoubleAmountFromString(
                                    widget.cartItemDetails.packaging!))
                            .toString(),
                        "shipping_discount":
                            "-${getDoubleAmountFromString(widget.cartItemDetails.discount!)}",
                      }
                    },
                    "description": API.paypalTransactionDescription,
                    // "custom": "EBAY_EMS_90048630045645624435",
                    "invoice_number": widget.cartItemDetails.id.toString(),
                    // "soft_descriptor": "ECHI5456456766",
                    "item_list": {
                      "items": widget.cartItemDetails.items!
                          .map((e) => {
                                "name": e.slug.toString(),
                                "description": e.description.toString(),
                                "quantity": e.quantity.toString(),
                                "price": getDoubleAmountFromString(e.unitPrice!)
                                    .toString(),
                                "sku": e.id.toString(),
                                "currency": API.payPalCurrency,
                              })
                          .toList(),
                      "shipping_address": {
                        "recipient_name":
                            widget.address.addressTitle!.toString(),
                        "line1": "4thFloor",
                        "line2": "unit#34",
                        "city": "SAn Jose",
                        "country_code": "US",
                        "postal_code": "95131",
                        "phone": "011862212345678",
                        "state": "CA"
                      }
                    }
                  }
                ],
                note: "Contact us for any questions on your order.",
                onSuccess: (Map params) async {
                  print("onSuccess: $params");

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
                  print("onError: $error");
                  setState(() {
                    _result = false;
                  });
                },
                onCancel: (params) {
                  print('cancelled: $params');
                  setState(() {
                    _result = false;
                  });
                }),
          ),
        )
      };
  @override
  Widget build(BuildContext context) {
    print(getDoubleAmountFromString(widget.cartItemDetails.total!));
    return Scaffold(
        appBar: AppBar(
          title: Text("Paypal Express Checkout"),
          leading: BackButton(
            onPressed: () {
              if (_result!) {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _result == null
                    ? "Click here to pay!"
                    : _result!
                        ? "Payment Successful"
                        : "Payment Failed",
              ),
              _result == null
                  ? ElevatedButton(
                      onPressed: _result == null ? _pay : () {},
                      child: const Text("Make payment"))
                  : ElevatedButton(
                      onPressed: () {
                        if (_result!) {
                          Navigator.pop(context, {
                            "success": _result,
                            "paymentMeta": _paymentMeta,
                            "status": _status,
                          });
                        } else {
                          _pay();
                        }
                      },
                      child:
                          Text(_result! ? "Continue to Order" : "Try Again")),
            ],
          ),
        ));
  }
}

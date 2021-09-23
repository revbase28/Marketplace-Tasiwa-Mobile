import 'dart:convert';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:zcart/Theme/styles/colors.dart';

class StripePaymentCardScreen extends StatefulWidget {
  const StripePaymentCardScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StripePaymentCardScreenState();
  }
}

class StripePaymentCardScreenState extends State<StripePaymentCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: kFadeColor,
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stripe Payment"),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              cardBgColor: kPrimaryColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor: kPrimaryColor,
                      textColor: EasyDynamicTheme.of(context).themeMode ==
                              ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                        hintStyle: Theme.of(context).textTheme.subtitle2,
                        labelStyle: Theme.of(context).textTheme.subtitle2,
                        focusedBorder: border,
                        enabledBorder: border,
                      ),
                      expiryDateDecoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.subtitle2,
                        labelStyle: Theme.of(context).textTheme.subtitle2,
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.subtitle2,
                        labelStyle: Theme.of(context).textTheme.subtitle2,
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.subtitle2,
                        labelStyle: Theme.of(context).textTheme.subtitle2,
                        focusedBorder: border,
                        enabledBorder: border,
                        labelText: 'Card Holder',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary: kPrimaryColor,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        child: const Text(
                          'Validate',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          print('valid!');
                          Navigator.of(context).pop(
                            CreditCardResult(
                              cardNumber: cardNumber,
                              expMonth: expiryDate.split('/')[0],
                              expYear: expiryDate.split('/')[1],
                              cvc: cvvCode,
                            ),
                          );
                        } else {
                          print('invalid!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

class CreditCardResult {
  String cardNumber;
  String expMonth;
  String expYear;
  String cvc;
  CreditCardResult({
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
  });
}

import 'package:awesome_card/awesome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'dart:math' as math;

class CustomPaymentCardScreen extends StatefulWidget {
  final String payMentMethod;
  final String amount;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  const CustomPaymentCardScreen({
    Key? key,
    required this.payMentMethod,
    required this.amount,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
  }) : super(key: key);

  @override
  _CustomPaymentCardScreenState createState() =>
      _CustomPaymentCardScreenState();
}

class _CustomPaymentCardScreenState extends State<CustomPaymentCardScreen> {
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBack = false;

  late FocusNode _focusNode;
  TextEditingController cardNumberCtrl = TextEditingController();
  TextEditingController expiryFieldCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });

    cardNumberCtrl.text = widget.cardNumber.removeAllWhiteSpace();
    expiryFieldCtrl.text = widget.expiryDate;

    setState(() {
      cardNumber = cardNumberCtrl.text;
      expiryDate = expiryFieldCtrl.text;
      cvv = widget.cvvCode;
      cardHolderName = widget.cardHolderName;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
            widget.payMentMethod == stripe ? 'Stripe Checkout' : 'Checkout'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 32,
              ),
              CreditCard(
                cardNumber: cardNumber,
                cardExpiry: expiryDate,
                cardHolderName: cardHolderName,
                cvv: cvv,
                bankName: '',
                showBackSide: showBack,
                frontBackground: CardBackgrounds.black,
                backBackground: CardBackgrounds.white,
                showShadow: true,
              ),
              const SizedBox(
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CustomTextField(
                      controller: cardNumberCtrl,
                      hintText: 'Card Number',
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter card number';
                        } else if (value.length < 16) {
                          return 'Card number must be 16 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final newCardNumber = value.trim();
                        var newStr = '';
                        const _step = 4;

                        for (var i = 0; i < newCardNumber.length; i += _step) {
                          newStr += newCardNumber.substring(
                              i, math.min(i + _step, newCardNumber.length));
                          if (i + _step < newCardNumber.length) newStr += ' ';
                        }

                        setState(() {
                          cardNumber = newStr;
                        });
                      },
                    ),
                    CustomTextField(
                      controller: expiryFieldCtrl,
                      hintText: 'Card Expiry',
                      maxLength: 5,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter card expiry';
                        } else if (value.length < 5) {
                          return 'Card expiry must be 5 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        var newDateValue = value.trim();
                        final isPressingBackspace =
                            expiryDate.length > newDateValue.length;
                        final containsSlash = newDateValue.contains('/');

                        if (newDateValue.length >= 2 &&
                            !containsSlash &&
                            !isPressingBackspace) {
                          newDateValue = newDateValue.substring(0, 2) +
                              '/' +
                              newDateValue.substring(2);
                        }
                        setState(() {
                          expiryFieldCtrl.text = newDateValue;
                          expiryFieldCtrl.selection =
                              TextSelection.fromPosition(
                                  TextPosition(offset: newDateValue.length));
                          expiryDate = newDateValue;
                        });
                      },
                    ),
                    CustomTextField(
                      hintText: 'CVV',
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter CVV';
                        } else if (value.length < 3) {
                          return 'CVV must be 3 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          cvv = value;
                        });
                      },
                    ),
                    CustomTextField(
                      hintText: 'Card Holder Name (Optional)',
                      onChanged: (value) {
                        setState(() {
                          cardHolderName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Total Amount: ${widget.amount}',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      AppImages.stripe,
                      width: MediaQuery.of(context).size.width / 4,
                    ),
                    CustomButton(
                      buttonText: "Continue",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop(
                            CreditCardResult(
                              cardNumber: cardNumber,
                              expMonth: expiryDate.split('/')[0],
                              expYear: expiryDate.split('/')[1],
                              cvc: cvv,
                              cardHolderName: cardHolderName,
                            ),
                          );
                        } else {
                          toast("Please fill all the details!");
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CreditCardResult {
  String cardNumber;
  String cardHolderName;
  String expMonth;
  String expYear;
  String cvc;

  CreditCardResult({
    required this.cardNumber,
    required this.cardHolderName,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
  });
}

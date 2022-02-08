import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

OutlineInputBorder _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(
    color: kFadeColor,
    width: 2.0,
  ),
);

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
  State<StatefulWidget> createState() {
    return CustomPaymentCardScreenState();
  }
}

class CustomPaymentCardScreenState extends State<CustomPaymentCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;
    super.initState();
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            CreditCardWidget(
              onCreditCardWidgetChange: (p0) {},
              glassmorphismConfig: Glassmorphism.defaultConfig(),
              backgroundImage: AppImages.cardBg,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              cardBgColor: kPrimaryColor,
            ),
            CreditCardForm(
              formKey: _formKey,
              obscureCvv: true,
              obscureNumber: true,
              cardNumber: cardNumber,
              cvvCode: cvvCode,
              cardHolderName: cardHolderName,
              expiryDate: expiryDate,
              themeColor: kPrimaryColor,
              textColor:
                  getColorBasedOnTheme(context, Colors.black, Colors.white),
              cardNumberDecoration: InputDecoration(
                labelText: 'Number',
                hintText: 'XXXX XXXX XXXX XXXX',
                hintStyle: Theme.of(context).textTheme.subtitle2,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                focusedBorder: _border,
                enabledBorder: _border,
              ),
              expiryDateDecoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.subtitle2,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                focusedBorder: _border,
                enabledBorder: _border,
                labelText: 'Expired Date',
                hintText: 'XX/XX',
              ),
              cvvCodeDecoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.subtitle2,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                focusedBorder: _border,
                enabledBorder: _border,
                labelText: 'CVV',
                hintText: 'XXX',
              ),
              cardHolderDecoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.subtitle2,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                focusedBorder: _border,
                enabledBorder: _border,
                labelText: 'Card Holder',
              ),
              onCreditCardModelChange: onCreditCardModelChange,
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
                      cvc: cvvCode,
                      cardHolderName: cardHolderName,
                    ),
                  );
                }
              },
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class WalletDepositPage extends StatefulWidget {
  final String customerEmail;
  const WalletDepositPage({
    Key? key,
    required this.customerEmail,
  }) : super(key: key);

  @override
  _WalletDepositPageState createState() => _WalletDepositPageState();
}

class _WalletDepositPageState extends State<WalletDepositPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedpaymentMethod = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Wallet Deposit"),
          systemOverlayStyle: SystemUiOverlayStyle.light),
      body: _isLoading
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingWidget(),
                  const SizedBox(height: 16),
                  Text(LocaleKeys.please_wait.tr()),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextField(
                    hintText: "Amount",
                    title: "Amount",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _amountController,
                    onChanged: (value) {
                      context.read(walletDepositProvider).amount = value.trim();
                    },
                    validator: (value) =>
                        value!.isEmpty ? LocaleKeys.field_required.tr() : null,
                  ),
                  const SizedBox(height: 4),
                  Consumer(
                    builder: (context, watch, child) {
                      final _paymentMethodsProvider =
                          watch(walletDepositPaymentMethodsProvider);

                      return _paymentMethodsProvider.when(
                        data: (value) {
                          return value == null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 32),
                                  child: Text(
                                      LocaleKeys.something_went_wrong.tr()),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      LocaleKeys.payment_method.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    ...[
                                      for (var method in value.data.where(
                                          (element) => paymentMethods
                                              .contains(element.code)))
                                        RadioListTile<String>(
                                          controlAffinity:
                                              ListTileControlAffinity.trailing,
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .color,
                                          title: Text(method.name),
                                          value: method.code,
                                          groupValue: _selectedpaymentMethod,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedpaymentMethod = value!;
                                              context
                                                  .read(walletDepositProvider)
                                                  .paymentMethod = value;
                                            });
                                          },
                                        )
                                    ],
                                  ],
                                );
                        },
                        loading: () {
                          return const SizedBox(
                            height: 64,
                            child: Center(
                              child: LoadingWidget(),
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 32),
                            child: Text(LocaleKeys.something_went_wrong.tr()),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedpaymentMethod.isEmpty) {
                          toast("Please select payment method!");
                        } else {
                          await PaymentMethods.pay(
                            context,
                            _selectedpaymentMethod,
                            isWalletDeposit: true,
                            email: widget.customerEmail,
                            price: int.parse(_amountController.text.trim()),
                          ).then((value) async {
                            if (value) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await context.read(walletDepositProvider).pay();

                                context.refresh(walletBalanceProvider);
                                context
                                    .refresh(walletTransactionFutureProvider);
                                Navigator.of(context).pop();
                              } catch (e) {
                                toast(e.toString());
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            } else {
                              toast("Payment Failed");
                            }
                          });
                        }

                        // if (_result) {
                        //   context.refresh(walletTransactionFutureProvider);
                        //   context.refresh(walletBalanceProvider);
                        //   Navigator.pop(context);
                        // }
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ],
              )),
    );
  }
}

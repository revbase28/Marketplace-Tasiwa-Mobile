import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';

class WalletDepositPage extends StatefulWidget {
  const WalletDepositPage({Key? key}) : super(key: key);

  @override
  _WalletDepositPageState createState() => _WalletDepositPageState();
}

class _WalletDepositPageState extends State<WalletDepositPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    controller: _amountController,
                    validator: (value) =>
                        value!.isEmpty ? LocaleKeys.field_required.tr() : null,
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        final _result = await Future.delayed(
                            const Duration(seconds: 2), () => true);

                        setState(() {
                          _isLoading = false;
                        });

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

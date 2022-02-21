import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/currency_widget.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';

class WalletTransferPage extends StatefulWidget {
  const WalletTransferPage({Key? key}) : super(key: key);

  @override
  _WalletTransferState createState() => _WalletTransferState();
}

class _WalletTransferState extends State<WalletTransferPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.wallet_transfer.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          child: _isLoading
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
                        hintText: LocaleKeys.amount.tr(),
                        title: LocaleKeys.amount.tr(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        controller: _amountController,
                        prefixIcon: CurrencySymbolWidget(
                            builder: (context, symbol) => symbol == null
                                ? const SizedBox()
                                : Text(symbol)),
                        validator: (value) => value!.isEmpty
                            ? LocaleKeys.field_required.tr()
                            : null,
                      ),
                      const SizedBox(height: 4),
                      CustomTextField(
                        hintText: LocaleKeys.transfer_to.tr(),
                        title: LocaleKeys.email.tr(),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) => value!.isEmpty
                            ? LocaleKeys.field_required.tr()
                            : !value.contains('@') || !value.contains('.')
                                ? LocaleKeys.invalid_email.tr()
                                : null,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            final _result = await WalletTransfer.transfer(
                                _emailController.text.trim(),
                                _amountController.text.trim());

                            setState(() {
                              _isLoading = false;
                            });

                            if (_result) {
                              context.refresh(walletTransactionFutureProvider);
                              context.refresh(walletBalanceProvider);
                              Navigator.pop(context);
                            }
                          }
                        },
                        buttonText: LocaleKeys.transfer.tr(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

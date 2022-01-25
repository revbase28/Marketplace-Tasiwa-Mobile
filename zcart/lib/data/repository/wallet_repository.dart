import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_wallet_repository.dart';
import 'package:zcart/data/models/wallet/wallet_transactions_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletRepository implements IWalletRepository {
  late WalletTransactionsModel walletTransactionsModel;
  List<TransactionData> transactionData = [];

  @override
  Future<WalletTransactionsModel> fetchWalletTransactions() async {
    transactionData.clear();

    var responseBody = await handleResponse(
        await getRequest(API.walletTransactions, bearerToken: true),
        showToast: false);
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
    walletTransactionsModel = WalletTransactionsModel.fromJson(responseBody);
    transactionData.addAll(walletTransactionsModel.data);
    return walletTransactionsModel;
  }

  @override
  Future<List<TransactionData>> fetchMoreWalletTransactions() async {
    dynamic responseBody;
    debugPrint(
        "Fetch More WalletTransactions (before): ${transactionData.length}");

    if (walletTransactionsModel.links.next != null) {
      toast(LocaleKeys.loading.tr());
      responseBody = await handleResponse(await getRequest(
          walletTransactionsModel.links.next!.split('api/').last,
          bearerToken: true));

      walletTransactionsModel = WalletTransactionsModel.fromJson(responseBody);

      transactionData.addAll(walletTransactionsModel.data);
      debugPrint(
          "Fetch More WalletTransactions (after): ${transactionData.length}");
      return transactionData;
    } else {
      toast(LocaleKeys.reached_to_the_end.tr());
      return transactionData;
    }
  }

  @override
  int walletTransactionsCount() {
    return walletTransactionsModel.meta.total ?? 0;
  }
}

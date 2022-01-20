import 'package:zcart/data/models/wallet/wallet_transactions_mode.dart';

abstract class IWalletRepository {
  Future<WalletTransactionsModel> fetchWalletTransactions();
  int walletTransactionsCount();
  Future<List<TransactionData>> fetchMoreWalletTransactions();
}

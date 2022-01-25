import 'package:zcart/data/models/wallet/wallet_transactions_model.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitialState extends WalletState {
  const WalletInitialState();
}

class WalletLoadingState extends WalletState {
  const WalletLoadingState();
}

class WalletLoadedState extends WalletState {
  final List<TransactionData> transactions;
  final int total;

  const WalletLoadedState(
    this.transactions,
    this.total,
  );
}

class WalletErrorState extends WalletState {
  final String message;

  const WalletErrorState(this.message);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_wallet_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final IWalletRepository _iWalletRepository;

  WalletNotifier(this._iWalletRepository) : super(const WalletInitialState());

  Future getWalletTransaction() async {
    try {
      final walletTransactionsModel =
          await _iWalletRepository.fetchWalletTransactions();
      final _count = _iWalletRepository.walletTransactionsCount();
      state = WalletLoadedState(walletTransactionsModel.data, _count);
    } on NetworkException {
      state = WalletErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future getMoreTransactions() async {
    try {
      final walletTransactions =
          await _iWalletRepository.fetchMoreWalletTransactions();

      final _count = _iWalletRepository.walletTransactionsCount();
      state = WalletLoadedState(walletTransactions, _count);
    } on NetworkException {
      state = WalletErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

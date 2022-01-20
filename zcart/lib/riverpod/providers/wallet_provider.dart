import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_wallet_repository.dart';
import 'package:zcart/data/models/wallet/wallet_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/data/repository/wallet_repository.dart';
import 'package:zcart/riverpod/notifier/wallet_state_notifier.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';

final walletBalanceProvider = FutureProvider<WalletModel?>((ref) async {
  var _responseBody = await handleResponse(
      await getRequest(API.walletBalance, bearerToken: true));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return WalletModel.fromJson(_responseBody);
});

final walletTransactionFutureProvider = FutureProvider((ref) async {
  await ref.read(walletNotifierProvider.notifier).getWalletTransaction();
});

final walletRepositoryProvider =
    Provider<IWalletRepository>((ref) => WalletRepository());

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>(
        (ref) => WalletNotifier(ref.watch(walletRepositoryProvider)));

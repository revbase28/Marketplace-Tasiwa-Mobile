import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_wallet_repository.dart';
import 'package:zcart/data/models/wallet/wallet_balance.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/data/repository/wallet_repository.dart';
import 'package:zcart/riverpod/notifier/wallet_state_notifier.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';

final walletBalanceProvider = FutureProvider<WalletBalance?>((ref) async {
  var _responseBody = await handleResponse(
      await getRequest(API.walletBalance, bearerToken: true));

  if (_responseBody.isEmpty) {
    return null;
  }

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  return WalletBalance.fromMap(_responseBody);
});

final walletTransactionFutureProvider = FutureProvider((ref) async {
  await ref.read(walletNotifierProvider.notifier).getWalletTransaction();
});

final walletRepositoryProvider =
    Provider<IWalletRepository>((ref) => WalletRepository());

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>(
        (ref) => WalletNotifier(ref.watch(walletRepositoryProvider)));

class WalletTransfer {
  static Future<bool> transfer(String to, String amount) async {
    var _responseBody = await handleResponse(await postRequest(
        API.walletTransfer, {'email': to, 'amount': amount},
        bearerToken: true));

    if (_responseBody.isEmpty) {
      return false;
    }

    if (_responseBody.runtimeType == int && _responseBody > 206) {
      return false;
    }
    toast(_responseBody['message']);
    return _responseBody["isSuccess"] is bool
        ? _responseBody["isSuccess"]
        : false;
  }
}

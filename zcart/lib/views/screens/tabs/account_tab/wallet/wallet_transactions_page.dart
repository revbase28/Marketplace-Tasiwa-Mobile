import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/tabs/tabs.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class WalletTransactionsPage extends ConsumerWidget {
  const WalletTransactionsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, watch) {
    final _walletNotifireProvider = watch(walletNotifierProvider);

    final _scrollControllerProvider =
        watch(walletScrollNotifierProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.wallet_transactions.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
                onPressed: () {
                  context
                      .read(walletNotifierProvider.notifier)
                      .getMoreTransactions();
                },
                icon: const Icon(Icons.sync)),
          ],
        ),
        body: _walletNotifireProvider is WalletLoadedState
            ? _walletNotifireProvider.transactions.isEmpty
                ? Center(
                    child: Text(LocaleKeys.no_item_found.tr()),
                  )
                : ProviderListener<ScrollState>(
                    onChange: (context, state) {
                      if (state is ScrollReachedBottomState) {
                        context
                            .read(walletNotifierProvider.notifier)
                            .getMoreTransactions();
                      }
                    },
                    provider: walletScrollNotifierProvider,
                    child: ListView.builder(
                        controller: _scrollControllerProvider.controller,
                        itemCount: _walletNotifireProvider.transactions.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          return WalletTransactionTile(
                              transaction:
                                  _walletNotifireProvider.transactions[index]);
                        }),
                  )
            : const Center(child: LoadingWidget()));
  }
}

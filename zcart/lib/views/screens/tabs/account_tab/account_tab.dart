import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/controller/cart/coupon_state.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/models/wallet/wallet_transactions_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/dispute/disputes_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/riverpod/state/wallet_state.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/featured_brands.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/account_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/address_list.dart';
import 'package:zcart/views/screens/tabs/account_tab/blogs/blogs_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/coupons/my_coupons_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/disputes_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/messages_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/orders/my_order_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/settings/settings_page.dart';
import 'package:zcart/views/screens/tabs/account_tab/wallet/wallet_deposit_page.dart';
import 'package:zcart/views/screens/tabs/account_tab/wallet/wallet_transactions_page.dart';
import 'package:zcart/views/screens/tabs/account_tab/wallet/wallet_transfer_page.dart';
import 'package:zcart/views/screens/tabs/tabs.dart';
import 'package:zcart/views/shared_widgets/pdf_screen.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(LocaleKeys.account_text.tr()),
          actions: [
            IconButton(
              onPressed: () {
                context.nextPage(const SettingsPage());
              },
              icon: const Icon(Icons.settings),
              tooltip: LocaleKeys.settings.tr(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccountDashboard(),
              const UserActivityCard(),
              const ActionCard(),
              Consumer(
                builder: (context, watch, child) {
                  final _checkWalletPluginProvider =
                      watch(checkWalletPluginProvider);
                  return _checkWalletPluginProvider.when(
                    data: (value) {
                      if (value) {
                        return const WalletCard();
                      } else {
                        return const SizedBox();
                      }
                    },
                    loading: () => const SizedBox(),
                    error: (error, stackTrace) => const SizedBox(),
                  );
                },
              ),

              /// Recently viewed
              const RecentlyViewed()
                  .pOnly(bottom: 0, top: 10, right: 10, left: 10),
              const FeaturedBrands()
                  .pOnly(bottom: 10, top: 0, right: 10, left: 10),
            ],
          ),
        ));
  }
}

class AccountDashboard extends StatelessWidget {
  const AccountDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final userState = watch(userNotifierProvider);

      return userState is UserLoadedState
          ? Container(
              padding: const EdgeInsets.all(16),
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        backgroundImage: NetworkImage(userState.user!.avatar!),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.your_full_name.tr(),
                              style: context.textTheme.caption!.copyWith(
                                  color: kPrimaryFadeTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${userState.user!.name}",
                              style: context.textTheme.subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ).pOnly(bottom: 10).px(10),
                  const Divider(
                    height: 16,
                    thickness: 1,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.your_email.tr(),
                        style: context.textTheme.caption!.copyWith(
                            color: kPrimaryFadeTextColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${userState.user!.email}",
                        style: context.textTheme.subtitle2!
                            .copyWith(fontWeight: FontWeight.bold),
                      )
                    ],
                  ).p(10),
                  userState.user!.dob != null || userState.user!.sex != null
                      ? const Divider(
                          height: 16,
                          thickness: 1,
                        )
                      : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      userState.user!.sex == null
                          ? const SizedBox()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.sex.tr(),
                                    style: context.textTheme.caption!.copyWith(
                                        color: kPrimaryFadeTextColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${userState.user!.sex}",
                                    style: context.textTheme.subtitle2!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                      userState.user!.dob == null
                          ? const SizedBox()
                          : Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.dob.tr(),
                                    style: context.textTheme.caption!.copyWith(
                                        color: kPrimaryFadeTextColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${userState.user!.dob}",
                                    style: context.textTheme.subtitle2!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ).p(10),
                ],
              ),
            ).cornerRadius(10).p(10)
          : const SizedBox();
    });
  }
}

class UserActivityCard extends StatelessWidget {
  const UserActivityCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kLightCardBgColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(builder: (context, watch, _) {
                  final orderListState = watch(ordersProvider);

                  return Text(
                    orderListState is OrdersLoadedState
                        ? orderListState.totalOrder.toString()
                        : "0",
                    maxLines: 1,
                    style: context.textTheme.headline4!.copyWith(
                        color: getColorBasedOnTheme(
                            context, kPrimaryColor, kDarkPriceColor),
                        fontWeight: FontWeight.bold),
                  );
                }),
                Text(
                  LocaleKeys.orders.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ).onInkTap(() {
              context.nextPage(const MyOrderScreen());
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kLightCardBgColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, watch, _) {
                    final couponState = watch(couponsProvider);
                    return Text(
                      couponState is CouponLoadedState
                          ? "${couponState.coupon!.length}"
                          : "0",
                      maxLines: 1,
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.coupons.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ).onInkTap(() {
              context.nextPage(const MyCouponsScreen());
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kLightCardBgColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, watch, _) {
                    final disputesState = watch(disputesProvider);
                    return Text(
                      disputesState is DisputesLoadedState
                          ? disputesState.disputes.length.toString()
                          : "0",
                      maxLines: 1,
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.disputes.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ).onInkTap(() {
              context.nextPage(const DisputeScreen());
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kLightCardBgColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (ctx, watch, _) {
                    final wishListState = watch(wishListNotifierProvider);
                    return Text(
                      wishListState is WishListLoadedState
                          ? wishListState.wishList.length.toString()
                          : '0',
                      maxLines: 1,
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.wishlist_text.tr(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ).onInkTap(() {
              context.nextPage(const WishListTab());
            }),
          ),
        ),
      ],
    ).cornerRadius(10).p(10);
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bubble_left_bubble_right,
                  ).pOnly(bottom: 10),
                  Text(
                    LocaleKeys.messages.tr(),
                    style: context.textTheme.caption!
                        .copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ).onInkTap(() {
                context.read(conversationProvider.notifier).conversation();
                context.nextPage(const MessagesScreen());
              }),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.location).pOnly(bottom: 10),
                  Text(
                    LocaleKeys.addresses.tr(),
                    style: context.textTheme.caption!
                        .copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ).onInkTap(() {
                // context.read(addressNotifierProvider.notifier).fetchAddress();
                context.nextPage(const AddressList());
              }),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.person,
                  ).pOnly(bottom: 10),
                  Text(
                    LocaleKeys.account_text.tr(),
                    style: context.textTheme.caption!
                        .copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ).onInkTap(() {
                // context.read(userNotifierProvider.notifier).getUserInfo();
                context.nextPage(const AccountDetailsScreen());
              }),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.doc_append,
                  ).pOnly(bottom: 10),
                  Text(
                    LocaleKeys.blogs.tr(),
                    style: context.textTheme.caption!
                        .copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ).onInkTap(() {
                context.nextPage(const BlogsScreen());
              }),
            ),
          ],
        )).cornerRadius(10).p(10);
  }
}

class WalletCard extends ConsumerWidget {
  const WalletCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _walletBalanceProvider = watch(walletBalanceProvider);
    final _walletTransactionProvider = watch(walletTransactionFutureProvider);
    final _userState = watch(userNotifierProvider);
    Widget _zeroBalanceText = Text(
      "0.00",
      style: context.textTheme.headline4!.copyWith(
          color: getColorBasedOnTheme(context, kDarkColor, kDarkPriceColor),
          fontWeight: FontWeight.bold),
    );
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Wallet",
                style: context.textTheme.bodyText1!.copyWith(
                    color: kPrimaryFadeTextColor, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.refresh(walletBalanceProvider);
                  context.refresh(walletTransactionFutureProvider);
                },
                child: Icon(
                  Icons.sync,
                  color: kPrimaryColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          _walletBalanceProvider.when(
            data: (value) {
              if (value != null) {
                return Text(
                  value.data.balance,
                  style: context.textTheme.headline4!.copyWith(
                      color: getColorBasedOnTheme(
                          context, kDarkColor, kDarkPriceColor),
                      fontWeight: FontWeight.bold),
                );
              } else {
                return _zeroBalanceText;
              }
            },
            loading: () {
              return _zeroBalanceText;
            },
            error: (error, stackTrace) {
              return _zeroBalanceText;
            },
          ),
          const SizedBox(height: 16),
          _userState is UserLoadedState
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.nextPage(WalletDepositPage(
                              customerEmail: _userState.user?.email ?? ""));
                        },
                        label: const Text("Add Funds"),
                        icon: const Icon(CupertinoIcons.plus_circle),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.nextPage(const WalletTransferPage());
                        },
                        label: const Text("Transfer"),
                        icon: const Icon(CupertinoIcons.minus_circle),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          const Divider(height: 16),
          _walletTransactionProvider.when(
            data: (value) {
              final _walletNotifierProvider = watch(walletNotifierProvider);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions (${_walletNotifierProvider is WalletLoadedState ? _walletNotifierProvider.total : 0})",
                        style: context.textTheme.subtitle2!.copyWith(
                            color: kPrimaryFadeTextColor,
                            fontWeight: FontWeight.bold),
                      ),
                      _walletNotifierProvider is WalletLoadedState
                          ? _walletNotifierProvider.total > 2
                              ? TextButton(
                                  onPressed: () {
                                    context.nextPage(
                                        const WalletTransactionsPage());
                                  },
                                  child: Text(LocaleKeys.view_all.tr()),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                    ],
                  ),
                  Column(
                    children: _walletNotifierProvider is WalletLoadingState
                        ? []
                        : _walletNotifierProvider is WalletErrorState
                            ? []
                            : _walletNotifierProvider is WalletLoadedState
                                ? _walletNotifierProvider.transactions.length >
                                        2
                                    ? _walletNotifierProvider.transactions
                                        .sublist(0, 2)
                                        .map((transaction) {
                                        return WalletTransactionTile(
                                            transaction: transaction);
                                      }).toList()
                                    : _walletNotifierProvider
                                            .transactions.isEmpty
                                        ? [
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                LocaleKeys.no_item_found.tr(),
                                                style: context
                                                    .textTheme.subtitle2!
                                                    .copyWith(
                                                        color:
                                                            kPrimaryFadeTextColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            )
                                          ]
                                        : _walletNotifierProvider.transactions
                                            .map((transaction) {
                                            return WalletTransactionTile(
                                                transaction: transaction);
                                          }).toList()
                                : [],
                  ),
                ],
              );
            },
            loading: () {
              return const SizedBox(height: 16);
            },
            error: (error, stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    LocaleKeys.something_went_wrong.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).cornerRadius(10).p(10);
  }
}

class WalletTransactionTile extends StatelessWidget {
  final TransactionData transaction;
  const WalletTransactionTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: kLightCardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        dense: true,
        title: Text(
          transaction.description ?? LocaleKeys.not_available.tr(),
          style: context.textTheme.subtitle2!.copyWith(
              color: getColorBasedOnTheme(
                  context, kPrimaryDarkTextColor, kPrimaryLightTextColor),
              fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          transaction.amount,
          style: context.textTheme.subtitle2!.copyWith(
              color: getColorBasedOnTheme(
                  context,
                  transaction.amountRaw.isNegative ? kPriceColor : kGreenColor,
                  transaction.amountRaw.isNegative
                      ? kDarkPriceColor
                      : kGreenColor),
              fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.date),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                toast("Generating Invoice...");
                final _result = await generateInvoice(
                    API.walletInvoice(transaction.id),
                    transaction.type ?? "wallet_invoice");

                if (_result != null) {
                  toast("Invoice Generated");
                  context.nextPage(PDFScreen(path: _result));
                } else {
                  toast("Error Generating Invoice");
                }
              },
              child: Text(
                "Generate Invoice",
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

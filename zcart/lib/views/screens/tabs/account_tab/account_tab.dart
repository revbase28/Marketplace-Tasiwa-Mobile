import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/blog/blog_controller.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/controller/cart/coupon_state.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/dispute/disputes_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/brand/featured_brands.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/account_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/address_list.dart';
import 'package:zcart/views/screens/tabs/account_tab/blogs/blogs_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/coupons/my_coupons_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/disputes_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/messages_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/orders/my_order_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/tabs/account_tab/settings/settings_page.dart';

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
              tooltip: "Settings",
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
                    style: context.textTheme.headline4!.copyWith(
                        color: getColorBasedOnTheme(
                            context, kPrimaryColor, kDarkPriceColor),
                        fontWeight: FontWeight.bold),
                  );
                }),
                Text(
                  LocaleKeys.orders.tr(),
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
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.coupons.tr(),
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
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.disputes.tr(),
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
                      style: context.textTheme.headline4!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPrimaryColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Text(
                  LocaleKeys.wishlist_text.tr(),
                  style: context.textTheme.caption!
                      .copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ).onInkTap(() {
              context.nextReplacementPage(const BottomNavBar(selectedIndex: 3));
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
                context.read(countryNotifierProvider.notifier).getCountries();
                context.read(addressNotifierProvider.notifier).fetchAddress();
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
                context.read(userNotifierProvider.notifier).getUserInfo();
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
                context.read(blogsProvider.notifier).blogs();
                context.nextPage(const BlogsScreen());
              }),
            ),
          ],
        )).cornerRadius(10).p(10);
  }
}

class WalletCard extends StatelessWidget {
  const WalletCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Wallet",
            style: context.textTheme.bodyText1!.copyWith(
                color: kPrimaryFadeTextColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "\$81265",
            style: context.textTheme.headline4!.copyWith(
                color:
                    getColorBasedOnTheme(context, kDarkColor, kDarkPriceColor),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("Add Funds"),
                  icon: const Icon(CupertinoIcons.plus_circle),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text("Transfer"),
                  icon: const Icon(CupertinoIcons.minus_circle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transactions (17)",
                style: context.textTheme.subtitle2!.copyWith(
                    color: kPrimaryFadeTextColor, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(LocaleKeys.view_all.tr()),
              ),
            ],
          ),
          Column(
            children: [
              Card(
                elevation: 0,
                color: kLightCardBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  title: Text("Deposited"),
                  trailing: Text(
                    "\$81265",
                    style: context.textTheme.subtitle2!.copyWith(
                        color: getColorBasedOnTheme(
                            context, kPriceColor, kDarkPriceColor),
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Jan 1, 2020"),
                ),
              ),
              Card(
                elevation: 0,
                color: kLightCardBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text("Withdrawn"),
                  dense: true,
                  trailing: Text(
                    "-\$234",
                    style: context.textTheme.subtitle2!.copyWith(
                        color: getColorBasedOnTheme(
                            context, kPriceColor, kDarkPriceColor),
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Jan 1, 2020"),
                ),
              ),
            ],
          ),
        ],
      ),
    ).cornerRadius(10).p(10);
  }
}

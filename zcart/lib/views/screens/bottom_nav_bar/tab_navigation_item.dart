import 'package:flutter/material.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/tabs/brands_tab/brands_tab.dart';
import 'package:zcart/views/screens/tabs/tabs.dart';
import 'package:easy_localization/easy_localization.dart';

class TabNavigationItem {
  final Widget page;
  final Widget title;
  final Icon icon;
  final Icon selectedIcon;
  final String label;

  TabNavigationItem(
      {required this.page,
      required this.title,
      required this.icon,
      required this.selectedIcon,
      required this.label});

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: const HomeTab(),
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          title: Text(LocaleKeys.home_text.tr()),
          label: LocaleKeys.home_text.tr(),
        ),
        TabNavigationItem(
          page: const VendorsTab(),
          icon: const Icon(Icons.store_outlined),
          selectedIcon: const Icon(Icons.store),
          title: Text(LocaleKeys.vendor_text.tr()),
          label: LocaleKeys.vendor_text.tr(),
        ),
        TabNavigationItem(
          page: const BrandsTab(),
          icon: const Icon(Icons.local_mall_outlined),
          selectedIcon: const Icon(Icons.local_mall),
          title: Text(LocaleKeys.brands.tr()),
          label: LocaleKeys.brands.tr(),
        ),
        TabNavigationItem(
          page: accessAllowed
              ? const WishListTab()
              : const LoginScreen(needBackButton: false, nextScreenIndex: 3),
          icon: const Icon(Icons.favorite_border),
          selectedIcon: const Icon(Icons.favorite),
          title: Text(LocaleKeys.wishlist_text.tr()),
          label: LocaleKeys.wishlist_text.tr(),
        ),
        TabNavigationItem(
          page: const MyCartTab(),
          icon: const Icon(Icons.shopping_cart_outlined),
          selectedIcon: const Icon(Icons.shopping_cart),
          title: Text(LocaleKeys.cart_text.tr()),
          label: LocaleKeys.cart_text.tr(),
        ),
        TabNavigationItem(
          page: accessAllowed
              ? const AccountTab()
              : const LoginScreen(needBackButton: false),
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          title: Text(LocaleKeys.account_text.tr()),
          label: LocaleKeys.account_text.tr(),
        ),
      ];
}

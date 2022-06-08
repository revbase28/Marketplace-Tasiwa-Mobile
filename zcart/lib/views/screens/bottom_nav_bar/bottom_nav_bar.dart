import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/riverpod/providers/cart_provider.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'tab_navigation_item.dart';

class BottomNavBar extends StatefulWidget {
  final String selectedTabId;

  const BottomNavBar({
    Key? key,
    this.selectedTabId = homeTabId,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late String _selectedTabId;

  @override
  void initState() {
    super.initState();

    getLoginState();

    _selectedTabId = widget.selectedTabId;

    final _systemConfigFutureProvider =
        context.read(systemConfigFutureProvider);

    Future.delayed(const Duration(seconds: 5), () {
      _systemConfigFutureProvider.whenData((value) {
        if (value?.data?.installVerion != apiVersion) {
          showCustomConfirmDialog(
            context,
            dialogType: DialogType.RETRY,
            primaryColor: kPriceColor,
            positiveText: "Contact",
            title: "WARNING!",
            subTitle:
                "The API is not fully compatible, please ask site admin to upgrade the API",
            onAccept: () {
              launchURL(MyConfig.appUrl + "/page/contact-us/");
            },
          );
        }
      });
    });
  }

  getLoginState() async {
    accessAllowed = getBoolAsync(loggedIn, defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final cartState = watch(cartNotifierProvider);
      final wishlistPluginCheck = watch(checkWishlistPluginProvider);
      int cartItems = 0;

      if (cartState is CartLoadedState) {
        for (var item in cartState.cartList!) {
          cartItems += item.items!.length;
        }
      }

      return WillPopScope(
        onWillPop: () async {
          if (_selectedTabId == homeTabId) {
            return true;
          } else {
            setState(() {
              _selectedTabId = homeTabId;
            });
            return false;
          }
        },
        child: wishlistPluginCheck.when(
            data: (data) {
              final List<TabNavigationItem> _navItems = [];
              if (data) {
                _navItems.addAll(TabNavigationItem.items);
              } else {
                final _tempItems = TabNavigationItem.items;
                _tempItems.removeAt(3);
                _navItems.addAll(_tempItems);
              }

              return Scaffold(
                body: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) =>
                          FadeThroughTransition(
                    fillColor: Colors.transparent,
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
                  child: _navItems
                      .firstWhere((element) => element.id == _selectedTabId)
                      .page,
                ),
                bottomNavigationBar: Stack(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: BottomNavigationBar(
                        currentIndex: _navItems.indexWhere((item) {
                          return item.id == _selectedTabId;
                        }),
                        onTap: (int index) {
                          setState(() {
                            _selectedTabId = _navItems[index].id;
                          });
                        },
                        backgroundColor: kPrimaryColor,
                        type: BottomNavigationBarType.fixed,
                        unselectedItemColor: kBottomBarUnselectedColor,
                        selectedItemColor: kLightColor,
                        selectedFontSize: 11,
                        elevation: 0,
                        showUnselectedLabels: false,
                        selectedLabelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        items: [
                          for (final item in _navItems)
                            BottomNavigationBarItem(
                              icon: item.icon,
                              label: item.label,
                              activeIcon: item.selectedIcon,
                            )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: (context.width() / _navItems.length) +
                          (10 + _navItems.length / 2),
                      child: CircleAvatar(
                        backgroundColor: kLightColor,
                        radius: 10,
                        child: Text(
                          cartItems.toString(),
                          style: context.theme.textTheme.caption!.copyWith(
                              color: kPrimaryDarkTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Scaffold(
                    body: Center(
                  child: LoadingWidget(),
                )),
            error: (_, __) => const Scaffold(body: ProductLoadingWidget())),
      );
    });
  }
}

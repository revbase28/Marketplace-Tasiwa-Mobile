import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/cart/cart_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';

class MyCartTab extends StatefulWidget {
  const MyCartTab({Key? key}) : super(key: key);

  @override
  _MyCartTabState createState() => _MyCartTabState();
}

class _MyCartTabState extends State<MyCartTab> {
  @override
  Widget build(BuildContext context) {
    return ProviderListener<CheckoutState>(
        provider: checkoutNotifierProvider,
        onChange: (context, state) {
          if (state is CheckoutLoadedState) {
            context.read(cartNotifierProvider.notifier).getCartList();
            if (accessAllowed) context.read(ordersProvider.notifier).orders();
          }
        },
        child: Consumer(builder: (context, watch, _) {
          final cartState = watch(cartNotifierProvider);
          final randomItemState = watch(randomItemNotifierProvider);
          final scrollControllerProvider =
              watch(randomItemScrollNotifierProvider.notifier);

          return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.cart_text.tr()),
                actions: [
                  (cartState is CartErrorState || cartState is CartLoadingState)
                      ? const Icon(Icons.refresh).pOnly(right: 10).onInkTap(() {
                          context
                              .read(cartNotifierProvider.notifier)
                              .getCartList();
                        })
                      : Container(),
                ],
              ),
              body: cartState is CartLoadedState
                  ? cartState.cartList!.isEmpty
                      ? ProviderListener(
                          provider: randomItemScrollNotifierProvider,
                          onChange: (context, state) {
                            if (state is ScrollReachedBottomState) {
                              context
                                  .read(randomItemNotifierProvider.notifier)
                                  .getMoreRandomItems();
                            }
                          },
                          child: SingleChildScrollView(
                            controller: scrollControllerProvider.controller,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 100),
                                const Icon(Icons.info_outline),
                                Text(LocaleKeys.no_item_found.tr()),
                                TextButton(
                                    onPressed: () {
                                      context.nextReplacementPage(
                                          const BottomNavBar(selectedIndex: 0));
                                    },
                                    child: Text(LocaleKeys.go_shopping.tr())),
                                const SizedBox(height: 100),

                                const RecentlyViewed().p(10),

                                /// Popular Items
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: randomItemState
                                          is RandomItemLoadedState
                                      ? ProductDetailsCard(
                                              title: LocaleKeys.additional_items
                                                  .tr(),
                                              isTitleCentered: true,
                                              productList: randomItemState
                                                  .randomItemList)
                                          .py(15)
                                      : randomItemState is RandomItemErrorState
                                          ? ErrorMessageWidget(
                                              randomItemState.message)
                                          : ProductLoadingWidget(),
                                )
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartState.cartList!.length,
                          padding: const EdgeInsets.only(top: 5),
                          itemBuilder: (context, index) {
                            return CartItemCard(
                                cartItem: cartState.cartList![index]);
                          })
                  : ProductLoadingWidget().px(10));
        }));
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
              ? kDarkCardBgColor
              : kLightColor,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cartItem.shop!.name!,
                  style: context.textTheme.headline6!
                      .copyWith(color: kPrimaryColor))
              .pOnly(bottom: 10),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItem.items!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ItemCard(
                            cartID: cartItem.id,
                            cartItem: cartItem.items![index])
                        .onInkTap(() {
                      context
                          .read(productNotifierProvider.notifier)
                          .getProductDetails(cartItem.items![index].slug)
                          .then((value) {
                        getRecentlyViewedItems(context);
                      });
                      context
                          .read(productSlugListProvider.notifier)
                          .addProductSlug(cartItem.items![index].slug);
                      context.nextPage(const ProductDetailsScreen());
                    }),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kLightCardBgColor),
                    )
                        .pOnly(bottom: 8)
                        .visible(cartItem.items!.length != 1)
                        .visible(index != cartItem.items!.length - 1),
                  ],
                );
              }).pOnly(bottom: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.grandTotal!,
                      style: context.textTheme.bodyText2!.copyWith(
                          color: EasyDynamicTheme.of(context).themeMode ==
                                  ThemeMode.dark
                              ? kDarkPriceColor
                              : kPriceColor,
                          fontWeight: FontWeight.bold)),
                  Text(LocaleKeys.grand_total.tr(),
                      style: context.textTheme.bodyText2),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    if (accessAllowed) {
                      context
                          .read(addressNotifierProvider.notifier)
                          .fetchAddress();
                    }
                    context
                        .read(shippingNotifierProvider.notifier)
                        .fetchShippingInfo(
                            cartItem.shop!.id, cartItem.shippingZoneId);
                    context
                        .read(packagingNotifierProvider.notifier)
                        .fetchPackagingInfo(cartItem.shop!.slug);
                    context
                        .read(paymentOptionsNotifierProvider.notifier)
                        .fetchPaymentMethod(cartItem.shop!.slug);
                    context
                        .read(cartItemDetailsNotifierProvider.notifier)
                        .getCartItemDetails(cartItem.id);
                    context
                        .read(countryNotifierProvider.notifier)
                        .getCountries();
                    context.nextPage(const CheckoutScreen());
                  },
                  child: Text(LocaleKeys.checkout.tr()))
            ],
          )
        ],
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  const ItemCard({
    Key? key,
    this.cartID,
    required this.cartItem,
  }) : super(key: key);

  final int? cartID;
  final Item cartItem;

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableStrechActionPane(),
      actionExtentRatio: 0.25,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            widget.cartItem.image!,
            height: 50,
            width: 50,
            errorBuilder: (BuildContext _, Object error, StackTrace? stack) {
              return Container();
            },
          ).px(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(widget.cartItem.description!,
                              maxLines: null,
                              softWrap: true,
                              style: context.textTheme.subtitle2!)
                          .pOnly(right: 10),
                    ),
                    Text(
                      widget.cartItem.unitPrice!,
                      style: context.textTheme.bodyText2!.copyWith(
                          color: EasyDynamicTheme.of(context).themeMode ==
                                  ThemeMode.dark
                              ? kDarkPriceColor
                              : kPriceColor,
                          fontWeight: FontWeight.bold),
                    ).pOnly(right: 5),
                  ],
                ),
                ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  buttonPadding: const EdgeInsets.symmetric(horizontal: 5),
                  buttonMinWidth:
                      30, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    OutlinedButton(
                        child: const Icon(Icons.remove),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              EasyDynamicTheme.of(context).themeMode ==
                                      ThemeMode.dark
                                  ? kDarkBgColor
                                  : kLightBgColor),
                          foregroundColor: MaterialStateProperty.all(
                              EasyDynamicTheme.of(context).themeMode ==
                                      ThemeMode.dark
                                  ? kPrimaryLightTextColor
                                  : kPrimaryDarkTextColor),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                        onPressed: widget.cartItem.quantity == 1
                            ? () {
                                showConfirmDialog(context,
                                    LocaleKeys.want_delete_item_from_cart.tr(),
                                    buttonColor: kPrimaryColor, onAccept: () {
                                  context
                                      .read(cartNotifierProvider.notifier)
                                      .removeFromCart(
                                        widget.cartID,
                                        widget.cartItem.id,
                                      );
                                });
                              }
                            : () {
                                toast(LocaleKeys.please_wait.tr());
                                setState(() {
                                  widget.cartItem.quantity =
                                      widget.cartItem.quantity! - 1;
                                });
                                context
                                    .read(cartNotifierProvider.notifier)
                                    .updateCart(widget.cartID,
                                        listingID: widget.cartItem.id,
                                        quantity: widget.cartItem.quantity);
                              }),
                    OutlinedButton(
                      onPressed: null,
                      child: Text(
                        widget.cartItem.quantity.toString(),
                        style: context.textTheme.subtitle2,
                      ),
                    ),
                    OutlinedButton(
                        child: const Icon(Icons.add),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                EasyDynamicTheme.of(context).themeMode ==
                                        ThemeMode.dark
                                    ? kDarkBgColor
                                    : kLightBgColor),
                            foregroundColor: MaterialStateProperty.all(
                                EasyDynamicTheme.of(context).themeMode ==
                                        ThemeMode.dark
                                    ? kPrimaryLightTextColor
                                    : kPrimaryDarkTextColor),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: () {
                          toast(LocaleKeys.please_wait.tr());
                          setState(() {
                            widget.cartItem.quantity =
                                widget.cartItem.quantity! + 1;
                          });
                          context
                              .read(cartNotifierProvider.notifier)
                              .updateCart(
                                widget.cartID,
                                listingID: widget.cartItem.id,
                                quantity: widget.cartItem.quantity,
                              );
                        }),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: LocaleKeys.delete.tr(),
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            toast(LocaleKeys.please_wait.tr());
            context.read(cartNotifierProvider.notifier).removeFromCart(
                  widget.cartID,
                  widget.cartItem.id,
                );
          },
        ),
      ],
    );
  }
}

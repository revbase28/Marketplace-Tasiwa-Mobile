import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/cart/cart_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_details.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
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
      child: Consumer(
        builder: (context, watch, _) {
          final _cartState = watch(cartNotifierProvider);
          final _randomItemState = watch(randomItemNotifierProvider);
          final _scrollControllerProvider =
              watch(randomItemScrollNotifierProvider.notifier);
          final _oneCheckoutPluginCheckProvider =
              watch(checkOneCheckoutPluginProvider);

          return Scaffold(
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                title: Text(LocaleKeys.cart_text.tr()),
                actions: [
                  (_cartState is CartErrorState ||
                          _cartState is CartLoadingState)
                      ? const Icon(Icons.sync).pOnly(right: 10).onInkTap(() {
                          context
                              .read(cartNotifierProvider.notifier)
                              .getCartList();
                        })
                      : const SizedBox(),
                ],
              ),
              body: _cartState is CartLoadedState
                  ? _cartState.cartList == null || _cartState.cartList!.isEmpty
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
                            controller: _scrollControllerProvider.controller,
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 100),
                                  const Icon(Icons.info_outline),
                                  Text(LocaleKeys.no_item_found.tr()),
                                  TextButton(
                                      onPressed: () {
                                        context.nextReplacementPage(
                                            const BottomNavBar(
                                                selectedIndex: 0));
                                      },
                                      child: Text(LocaleKeys.go_shopping.tr())),
                                  const SizedBox(height: 100),

                                  const RecentlyViewed().p(10),

                                  /// Popular Items
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: _randomItemState
                                            is RandomItemLoadedState
                                        ? ProductDetailsCardGridView(
                                                title: LocaleKeys
                                                    .additional_items
                                                    .tr(),
                                                isTitleCentered: true,
                                                productList: _randomItemState
                                                    .randomItemList)
                                            .py(15)
                                        : _randomItemState
                                                is RandomItemErrorState
                                            ? ErrorMessageWidget(
                                                _randomItemState.message)
                                            : const ProductLoadingWidget(),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 16),
                                children: _cartState.cartList!
                                    .map((e) => CartItemCard(cartItem: e))
                                    .toList(),
                              ),
                            ),
                            // Builder(
                            //   builder: (context) {
                            //     double _total = 0;
                            //     _cartState.cartList!.forEach((e) {
                            //       _total += e.items!.fold(
                            //           0,
                            //           (previousValue, element) =>
                            //               previousValue +
                            //               double.parse(element.total ?? "0") *
                            //                   element.quantity!);
                            //     });

                            //     return Text(
                            //       LocaleKeys.total.tr() +
                            //           " " +
                            //           _total.toStringAsFixed(2),
                            //       style: Theme.of(context).textTheme.headline6,
                            //     );
                            //   },
                            // ),
                            _oneCheckoutPluginCheckProvider.when(
                              data: (value) {
                                if (value) {
                                  //TODO: Checkout with onecheckout
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child:
                                        Text("OneCheckout Plugin is enabled"),
                                  );
                                }
                                return const SizedBox();
                              },
                              loading: () => const SizedBox(),
                              error: (error, stackTrace) =>
                                  Text(error.toString()),
                            ),
                          ],
                        )
                  : const ProductLoadingWidget().px(10));
        },
      ),
    );
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
          color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context
                  .read(vendorDetailsNotifierProvider.notifier)
                  .getVendorDetails(cartItem.shop!.slug!);
              context
                  .read(vendorItemsNotifierProvider.notifier)
                  .getVendorItems(cartItem.shop!.slug!);
              context.nextPage(const VendorsDetailsScreen());
            },
            child: Text(cartItem.shop!.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headline6!.copyWith(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1)),
          ),
          const Divider(height: 16),
          const SizedBox(height: 8),
          Column(
            children: cartItem.items!.map((e) {
              return Column(
                children: [
                  ItemCard(cartID: cartItem.id, cartItem: e).onInkTap(() {
                    context
                        .read(productNotifierProvider.notifier)
                        .getProductDetails(e.slug)
                        .then((value) {
                      getRecentlyViewedItems(context);
                    });
                    context
                        .read(productSlugListProvider.notifier)
                        .addProductSlug(e.slug);
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
                      .visible(cartItem.items!.indexOf(e) !=
                          cartItem.items!.length - 1),
                ],
              );
            }).toList(),
          ).pOnly(bottom: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.grand_total.tr(),
                    style: context.textTheme.subtitle2!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(cartItem.grandTotal!,
                      style: context.textTheme.bodyText2!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPriceColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Consumer(
                builder: (context, watch, child) {
                  final userState = watch(userNotifierProvider);

                  return ElevatedButton(
                      onPressed: () async {
                        String? customerEmail;

                        if (accessAllowed) {
                          context
                              .read(addressNotifierProvider.notifier)
                              .fetchAddress();
                          if (userState is UserLoadedState) {
                            customerEmail = userState.user!.email!;
                          }
                        }

                        context
                            .read(packagingNotifierProvider.notifier)
                            .fetchPackagingInfo(cartItem.shop!.slug);
                        context
                            .read(paymentOptionsNotifierProvider.notifier)
                            .fetchPaymentMethod(
                                cartId: cartItem.id!.toString());
                        context
                            .read(cartItemDetailsNotifierProvider.notifier)
                            .getCartItemDetails(cartItem.id);
                        context
                            .read(countryNotifierProvider.notifier)
                            .getCountries();
                        context
                            .read(shippingNotifierProvider.notifier)
                            .fetchShippingInfo(
                                shopId: cartItem.shop!.id.toString(),
                                zoneId: cartItem.shippingZoneId.toString());

                        context.nextPage(
                            CheckoutScreen(customerEmail: customerEmail));
                      },
                      child: Text(LocaleKeys.checkout.tr()));
                },
              )
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.cartItem.image!,
                height: 50,
                width: 50,
                errorWidget: (context, url, error) => const SizedBox(),
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(value: progress.progress),
                ),
              ).px(10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(widget.cartItem.description!,
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.subtitle2!)
                          .pOnly(right: 10),
                    ),
                    Text(
                      widget.cartItem.unitPrice!,
                      style: context.textTheme.bodyText2!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPriceColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    ).pOnly(right: 5),
                  ],
                ),
              ),
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
                      getColorBasedOnTheme(
                          context, kLightBgColor, kDarkBgColor),
                    ),
                    foregroundColor: MaterialStateProperty.all(
                        getColorBasedOnTheme(context, kPrimaryDarkTextColor,
                            kPrimaryLightTextColor)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                  ),
                  onPressed: widget.cartItem.quantity == 1
                      ? () {
                          showCustomConfirmDialog(
                            context,
                            dialogAnimation: DialogAnimation.SLIDE_RIGHT_LEFT,
                            dialogType: DialogType.DELETE,
                            title: LocaleKeys.want_delete_item_from_cart.tr(),
                            onAccept: () {
                              context
                                  .read(cartNotifierProvider.notifier)
                                  .removeFromCart(
                                    widget.cartID,
                                    widget.cartItem.id,
                                  );
                            },
                          );
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
                        getColorBasedOnTheme(
                            context, kLightBgColor, kDarkBgColor),
                      ),
                      foregroundColor: MaterialStateProperty.all(
                          getColorBasedOnTheme(context, kPrimaryDarkTextColor,
                              kPrimaryLightTextColor)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: () {
                    toast(LocaleKeys.please_wait.tr());
                    setState(() {
                      widget.cartItem.quantity = widget.cartItem.quantity! + 1;
                    });
                    context.read(cartNotifierProvider.notifier).updateCart(
                          widget.cartID,
                          listingID: widget.cartItem.id,
                          quantity: widget.cartItem.quantity,
                        );
                  }),
            ],
          )
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

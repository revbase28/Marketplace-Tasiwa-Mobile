import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/address/country_model.dart';
import 'package:zcart/data/models/address/packaging_model.dart';
import 'package:zcart/data/models/address/states_model.dart';
import 'package:zcart/data/models/cart/cart_model.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_details.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';

class MyCartTab extends StatefulWidget {
  const MyCartTab({Key? key}) : super(key: key);

  @override
  _MyCartTabState createState() => _MyCartTabState();
}

class _MyCartTabState extends State<MyCartTab> {
  // late Timer _timer;
  @override
  void initState() {
    // _isAllCartCheckout.add(false);
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   setState(() {});
    // });

    super.initState();
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  final List<bool> _isAllCartCheckout = [];

  void _onOneCheckOut(int cartId, String? userEmail) {
    setState(() {});
    if (_isAllCartCheckout.any((element) => element == false)) {
      toast(LocaleKeys.onecheckout_warning.tr(), length: Toast.LENGTH_LONG);
    } else {
      final _systemConfigProvider = context.read(systemConfigFutureProvider);
      _systemConfigProvider.whenData((value) {
        if (value?.data?.allowGuestCheckout == true) {
          context
              .read(paymentOptionsNotifierProvider.notifier)
              .fetchPaymentMethod(cartId: cartId.toString());

          context
              .read(cartItemDetailsNotifierProvider.notifier)
              .getCartItemDetails(cartId);

          context.nextPage(
              CheckoutScreen(customerEmail: userEmail, isOneCheckout: true));
        } else {
          if (accessAllowed == false) {
            context.nextPage(
                const LoginScreen(needBackButton: true, nextScreenIndex: 4));
          } else {
            context
                .read(paymentOptionsNotifierProvider.notifier)
                .fetchPaymentMethod(cartId: cartId.toString());

            context
                .read(cartItemDetailsNotifierProvider.notifier)
                .getCartItemDetails(cartId);

            context.nextPage(
                CheckoutScreen(customerEmail: userEmail, isOneCheckout: true));
          }
        }
      });
    }
  }

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
          final _userState = watch(userNotifierProvider);

          return Scaffold(
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
                title: Text(LocaleKeys.cart_text.tr()),
                actions: [
                  IconButton(
                    onPressed: () {
                      context.read(cartNotifierProvider.notifier).getCartList();
                    },
                    icon: const Icon(Icons.sync),
                  )
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: _oneCheckoutPluginCheckProvider.when(
                data: (value) {
                  if (value) {
                    bool _canOneCheckout = false;
                    debugPrint("_isAllCartCheckout: $_isAllCartCheckout");

                    if (_cartState is CartLoadedState) {
                      if (_cartState.cartList != null &&
                          _cartState.cartList!.isNotEmpty &&
                          _cartState.cartList!.length > 1) {
                        if (_cartState.cartList!.every((element) =>
                            element.shipToCountryId ==
                                _cartState.cartList!.first.shipToCountryId &&
                            element.shipToStateId ==
                                _cartState.cartList!.first.shipToStateId)) {
                          _canOneCheckout = true;
                        }
                      }
                    }

                    if (_canOneCheckout) {
                      return FloatingActionButton.extended(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          String? _customerEmail;

                          if (accessAllowed) {
                            if (_userState is UserLoadedState) {
                              _customerEmail = _userState.user!.email!;
                            }
                          }
                          if (_cartState is CartLoadedState) {
                            _onOneCheckOut(
                                _cartState.cartList!.first.id!, _customerEmail);
                          }
                        },
                        icon: const Icon(Icons.double_arrow),
                        label: Text(
                          LocaleKeys.checkout_all.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: kLightColor),
                        ),
                        elevation: 20,
                        heroTag: "checkout_all",
                        foregroundColor: kLightColor,
                        tooltip: LocaleKeys.checkout_all.tr(),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                  return const SizedBox();
                },
                loading: () => const SizedBox(),
                error: (error, stackTrace) => Text(error.toString()),
              ),
              // floatingActionButton: ,
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
                                  const SizedBox(height: 60),

                                  Text(
                                    LocaleKeys.empty_cart.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                      onPressed: () {
                                        context.nextReplacementPage(
                                            const BottomNavBar(
                                                selectedIndex: 0));
                                      },
                                      child: Text(LocaleKeys.go_shopping.tr())),
                                  const SizedBox(height: 50),

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
                      : ListView(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          children: _cartState.cartList!.map((e) {
                            _isAllCartCheckout.clear();
                            return CartItemCard(
                                cartItem: e,
                                canCheckout: (value) {
                                  _isAllCartCheckout.add(value);
                                });
                          }).toList(),
                        )
                  : const ProductLoadingWidget().px(10));
        },
      ),
    );
  }
}

class CartItemCard extends ConsumerWidget {
  final CartItem cartItem;
  final Function(bool isCheckout) canCheckout;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.canCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _countryState = watch(countryNotifierProvider);

    Future<int?> _getCountry(List<Countries> coutries) async {
      final int? _result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return _SelectSippingCountryPage(
            title: LocaleKeys.select_shipping_country.tr(),
            items: coutries,
            selected: cartItem.shipToCountryId,
            onCountrySelected: (p0) {
              Navigator.pop(context, p0.id);
            },
          );
        },
      );

      return _result;
    }

    Future<int?> _selectShippingState(List<States> states) async {
      final int? _state = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return _SelectSippingStatePage(
            title: LocaleKeys.select_shipping_state.tr(),
            items: states,
            selected: cartItem.shipToStateId,
            onCountrySelected: (p0) {
              Navigator.pop(context, p0.id);
            },
          );
        },
      );

      return _state;
    }

    return Container(
      decoration: BoxDecoration(
          color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:
                  getColorBasedOnTheme(context, Colors.black12, Colors.black54),
              blurRadius: 10,
              offset: const Offset(0, 0),
              spreadRadius: 2,
            ),
          ]),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read(vendorDetailsNotifierProvider.notifier)
                          .getVendorDetails(cartItem.shop!.slug!);
                      context
                          .read(vendorItemsNotifierProvider.notifier)
                          .getVendorItems(cartItem.shop!.slug!);
                      context.nextPage(const VendorsDetailsScreen());
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined),
                        const SizedBox(width: 4),
                        Text(cartItem.shop!.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.headline6!.copyWith(
                              color: getColorBasedOnTheme(
                                  context, kDarkColor, kLightColor),
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ).pOnly(right: 4),
                ),
                _countryState is CountryLoadedState &&
                        _countryState.countryList != null &&
                        _countryState.countryList!.isNotEmpty
                    ? Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final int? _selectedCountry =
                                await _getCountry(_countryState.countryList!);

                            if (_selectedCountry != null) {
                              final _getStatesForCurrentCountry = await context
                                  .read(getProductDetailsModelProvider)
                                  .getStatesFromSelectedCountry(
                                      _selectedCountry);

                              int? _selectedStateId;

                              if (_getStatesForCurrentCountry != null &&
                                  _getStatesForCurrentCountry.isNotEmpty) {
                                _selectedStateId = await _selectShippingState(
                                    _getStatesForCurrentCountry);
                              }

                              String _url = cartUrl(cartItem.id!,
                                  _selectedCountry, _selectedStateId);

                              final _shipOptions = await GetProductDetailsModel
                                  .getCartShippingOptions(_url);

                              await context
                                  .read(cartNotifierProvider.notifier)
                                  .updateCart(
                                    cartItem.id!,
                                    countryId: _selectedCountry,
                                    stateId: _selectedStateId,
                                    shippingOptionId: _shipOptions != null &&
                                            _shipOptions.isNotEmpty
                                        ? _shipOptions.first.id
                                        : null,
                                    shippingZoneId: _shipOptions != null &&
                                            _shipOptions.isNotEmpty
                                        ? _shipOptions.first.shippingZoneId
                                        : null,
                                  );

                              // context.refresh(
                              //     cartShippingOptionsFutureProvider(_url));
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  _countryState.countryList!.any((element) =>
                                          element.id ==
                                          cartItem.shipToCountryId)
                                      ? _countryState.countryList!
                                          .firstWhere((e) =>
                                              e.id == cartItem.shipToCountryId)
                                          .name!
                                      : LocaleKeys.unknown.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.headline6!.copyWith(
                                    color: getColorBasedOnTheme(
                                        context, kDarkColor, kLightColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.location_on),
                            ],
                          ),
                        ).pOnly(left: 4),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: cartItem.items!.map((e) {
                return Column(
                  children: [
                    ItemCard(cartID: cartItem.id!, item: e).onInkTap(() {
                      context
                          .nextPage(ProductDetailsScreen(productSlug: e.slug!));
                    }),
                    const Divider(
                      height: 32,
                    ).visible(cartItem.items!.length != 1).visible(
                        cartItem.items!.indexOf(e) !=
                            cartItem.items!.length - 1),
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: getColorBasedOnTheme(context, kLightBgColor, kDarkBgColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PackagingDetails(cartItem: cartItem),
                const Divider(height: 0),
                ShippingDetails(cartItem: cartItem, onChecked: canCheckout),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  const ItemCard({
    Key? key,
    required this.cartID,
    required this.item,
  }) : super(key: key);

  final int cartID;
  final Item item;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: widget.item.image!,
              width: 80,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox(),
              progressIndicatorBuilder: (context, url, progress) => Center(
                child: CircularProgressIndicator(value: progress.progress),
              ),
            ),
          ).pOnly(right: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.item.description!,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.subtitle2!.copyWith())
                    .pOnly(right: 10),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.unitPrice!,
                      style: context.textTheme.bodyText2!.copyWith(
                          color: getColorBasedOnTheme(
                              context, kPriceColor, kDarkPriceColor),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " x " + widget.item.quantity.toString(),
                      style: context.textTheme.bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductDetailsPageIconButton(
                    isNoWidth: true,
                    isNoHeight: true,
                    backgroundColor: getColorBasedOnTheme(
                        context, kLightColor, kDarkBgColor),
                    icon: Icon(
                      Icons.add,
                      color: getColorBasedOnTheme(
                          context, kDarkColor, kLightColor),
                    ),
                    onPressed: () {
                      toast(LocaleKeys.please_wait.tr());
                      setState(() {
                        widget.item.quantity = widget.item.quantity! + 1;
                      });
                      context.read(cartNotifierProvider.notifier).updateCart(
                            widget.cartID,
                            listingID: widget.item.id,
                            quantity: widget.item.quantity,
                          );
                    }),
                const SizedBox(height: 4),
                Text(widget.item.quantity.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ProductDetailsPageIconButton(
                  isNoWidth: true,
                  isNoHeight: true,
                  backgroundColor:
                      getColorBasedOnTheme(context, kLightColor, kDarkBgColor),
                  icon: Icon(
                    Icons.remove,
                    color:
                        getColorBasedOnTheme(context, kDarkColor, kLightColor),
                  ),
                  onPressed: widget.item.quantity == 1
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
                                    widget.item.id,
                                  );
                            },
                          );
                        }
                      : () {
                          toast(LocaleKeys.please_wait.tr());
                          setState(() {
                            widget.item.quantity = widget.item.quantity! - 1;
                          });
                          context
                              .read(cartNotifierProvider.notifier)
                              .updateCart(widget.cartID,
                                  listingID: widget.item.id,
                                  quantity: widget.item.quantity);
                        },
                ),
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
                  widget.item.id,
                );
          },
        ),
      ],
    );
  }
}

class PackagingDetails extends ConsumerWidget {
  final CartItem cartItem;
  const PackagingDetails({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _shopPackage =
        watch(shopPackagingFutureProvider(cartItem.shop!.slug!));
    // final _shippingOptions = watch(cartShippingOptionsFutureProvider(
    //     [cartItem.id!, cartItem.countryId, cartItem.stateId]));

    return _shopPackage.when(
      data: (value) {
        if (value == null || value.isEmpty) {
          return const SizedBox();
        } else {
          PackagingModel? packagingModel;
          if (value.any((element) => element.id == cartItem.packagingId)) {
            packagingModel = value.firstWhere(
              (element) => element.id == cartItem.packagingId,
            );
          }
          return value.length == 1
              ? const SizedBox()
              : ListTile(
                  onTap: () {
                    _onTapSelectPackaging(context, value, packagingModel);
                  },
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.packaging.tr() + ':',
                        style: context.textTheme.caption!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryFadeTextColor),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        alignment: Alignment.centerRight,
                        onPressed: () {
                          _onTapSelectPackaging(context, value, packagingModel);
                        },
                        child: Text(
                          LocaleKeys.change.tr(),
                          style: context.textTheme.caption!.copyWith(
                              fontWeight: FontWeight.bold, color: kFadeColor),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          packagingModel?.name ?? '',
                          style: context.textTheme.subtitle2!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        double.parse(packagingModel?.costRaw ?? "0") <= 0.0
                            ? ""
                            : (packagingModel?.cost ?? "0"),
                        style: context.textTheme.subtitle2!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getColorBasedOnTheme(
                                context, kPriceColor, kDarkPriceColor)),
                      )
                    ],
                  ).pOnly(top: 8),
                );
        }
      },
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }

  Future<dynamic> _onTapSelectPackaging(BuildContext context,
      List<PackagingModel> value, PackagingModel? packagingModel) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: context.screenHeight * 0.7,
          child: ProductPageDefaultContainer(
            isFullPadding: true,
            padding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.select_packaging.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: value
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e.name ?? LocaleKeys.unknown.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              e.cost ?? "0",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: getColorBasedOnTheme(
                                        context, kPriceColor, kDarkPriceColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              context
                                  .read(cartNotifierProvider.notifier)
                                  .updateCart(cartItem.id!, packagingId: e.id);
                            },
                            minLeadingWidth: 0,
                            leading: packagingModel?.id == e.id
                                ? const Icon(Icons.check_circle)
                                : const Icon(Icons.circle_outlined),
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShippingDetails extends ConsumerWidget {
  final CartItem cartItem;
  final Function(bool isChecked) onChecked;

  const ShippingDetails({
    Key? key,
    required this.cartItem,
    required this.onChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _userState = watch(userNotifierProvider);

    String _url =
        cartUrl(cartItem.id!, cartItem.shipToCountryId, cartItem.shipToStateId);
    final _shippingOptions = watch(cartShippingOptionsFutureProvider(_url));

    return _shippingOptions.when(
      data: (value) {
        if (value == null || value.isEmpty) {
          onChecked(false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: Text(
                  LocaleKeys.shipping.tr() + ':',
                  style: context.textTheme.caption!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryFadeTextColor),
                ),
                subtitle: Text(
                  LocaleKeys.seller_doesnt_ship_this_area.tr(),
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: CartGrandTotalPart(cartItem: cartItem),
              ),
              const SizedBox(height: 8),
            ],
          );
        } else {
          onChecked(true);
          ShippingOption? _shippingOption;
          if (value.any((element) => element.id == cartItem.shippingOptionId)) {
            _shippingOption = value.firstWhere(
              (element) => element.id == cartItem.shippingOptionId,
            );
          } else {
            _shippingOption = value.first;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                onTap: () {
                  _onTapSelectShippingOption(context, value, _shippingOption);
                },
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.shipping.tr() + ':',
                      style: context.textTheme.caption!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryFadeTextColor),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      alignment: Alignment.centerRight,
                      onPressed: () {
                        _onTapSelectShippingOption(
                            context, value, _shippingOption);
                      },
                      child: Text(
                        LocaleKeys.change.tr(),
                        style: context.textTheme.caption!.copyWith(
                            fontWeight: FontWeight.bold, color: kFadeColor),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (_shippingOption.name ?? LocaleKeys.unknown.tr()) +
                            " by " +
                            (_shippingOption.carrierName ??
                                LocaleKeys.unknown.tr()),
                        style: context.textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      double.parse(_shippingOption.costRaw ?? "0") <= 0.0
                          ? ""
                          : (_shippingOption.cost ?? "0"),
                      style: context.textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getColorBasedOnTheme(
                              context, kPriceColor, kDarkPriceColor)),
                    ),
                  ],
                ).pOnly(top: 8),
              ),
              const Divider(height: 0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CartGrandTotalPart(cartItem: cartItem),
                    ElevatedButton(
                        onPressed: () async {
                          String? _customerEmail;

                          final _systemConfigProvider =
                              context.read(systemConfigFutureProvider);
                          _systemConfigProvider.whenData((value) {
                            if (value?.data?.allowGuestCheckout == true) {
                              if (accessAllowed) {
                                if (_userState is UserLoadedState) {
                                  _customerEmail = _userState.user!.email!;
                                }
                              }

                              context
                                  .read(paymentOptionsNotifierProvider.notifier)
                                  .fetchPaymentMethod(
                                      cartId: cartItem.id!.toString());

                              context
                                  .read(
                                      cartItemDetailsNotifierProvider.notifier)
                                  .getCartItemDetails(cartItem.id);

                              context.nextPage(CheckoutScreen(
                                  customerEmail: _customerEmail));
                            } else {
                              if (accessAllowed == false) {
                                context.nextPage(const LoginScreen(
                                    needBackButton: true, nextScreenIndex: 4));
                              } else {
                                if (accessAllowed) {
                                  if (_userState is UserLoadedState) {
                                    _customerEmail = _userState.user!.email!;
                                  }
                                }

                                context
                                    .read(
                                        paymentOptionsNotifierProvider.notifier)
                                    .fetchPaymentMethod(
                                        cartId: cartItem.id!.toString());

                                context
                                    .read(cartItemDetailsNotifierProvider
                                        .notifier)
                                    .getCartItemDetails(cartItem.id);

                                context.nextPage(CheckoutScreen(
                                    customerEmail: _customerEmail));
                              }
                            }
                          });
                        },
                        child: Text(LocaleKeys.checkout.tr()))
                  ],
                ),
              ),
            ],
          );
        }
      },
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }

  Future<dynamic> _onTapSelectShippingOption(BuildContext context,
      List<ShippingOption> value, ShippingOption? _shippingOption) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: context.screenHeight * 0.7,
          child: ProductPageDefaultContainer(
            isFullPadding: true,
            padding: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LocaleKeys.select_shipping.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: value
                        .map(
                          (e) => ListTile(
                            title: Text(
                              (e.name ?? LocaleKeys.unknown.tr()) +
                                  " by " +
                                  (e.carrierName ?? LocaleKeys.unknown.tr()),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              e.deliveryTakes ?? "",
                              style: Theme.of(context).textTheme.caption!,
                            ),
                            trailing: Text(
                              e.cost ?? "0",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: getColorBasedOnTheme(
                                        context, kPriceColor, kDarkPriceColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              context
                                  .read(cartNotifierProvider.notifier)
                                  .updateCart(
                                    cartItem.id!,
                                    shippingOptionId: e.id,
                                    shippingZoneId: e.shippingZoneId,
                                  );
                            },
                            leading: _shippingOption?.id == e.id
                                ? const Icon(Icons.check_circle)
                                : const Icon(Icons.circle_outlined),
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 0,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartGrandTotalPart extends StatelessWidget {
  const CartGrandTotalPart({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.grand_total.tr(),
          style: context.textTheme.caption!.copyWith(
              fontWeight: FontWeight.bold, color: kPrimaryFadeTextColor),
        ),
        Row(
          children: [
            Text(cartItem.grandTotal!,
                style: context.textTheme.bodyText2!.copyWith(
                    color: getColorBasedOnTheme(
                        context, kPriceColor, kDarkPriceColor),
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            // GestureDetector(
            //   onTap: (){},
            //   child: Text(
            //     "[${LocaleKeys.apply_coupon.tr()}]",
            //     style: context.textTheme.caption!.copyWith(
            //         fontWeight: FontWeight.bold,
            //         color: getColorBasedOnTheme(
            //             context, kPrimaryColor, kLightColor)),
            //   ),
            // )
          ],
        ),
      ],
    );
  }
}

class _SelectSippingCountryPage extends StatefulWidget {
  final String title;
  final List<Countries> items;
  final int? selected;
  final Function(Countries) onCountrySelected;
  const _SelectSippingCountryPage({
    Key? key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  _SelectSippingCountryPageState createState() =>
      _SelectSippingCountryPageState();
}

class _SelectSippingCountryPageState extends State<_SelectSippingCountryPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final List<Countries> _filteredItems = [];

  @override
  void initState() {
    _filteredItems.addAll(widget.items);
    super.initState();
  }

  @override
  void dispose() {
    _filteredItems.clear();
    _searchController.dispose();
    _scrollController.dispose();
    debugPrint("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.85,
      child: ProductPageDefaultContainer(
        isFullPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _searchController,
              hintText: LocaleKeys.search.tr(),
              onChanged: (value) {
                setState(() {
                  _filteredItems.clear();
                  _filteredItems.addAll(widget.items.where((element) =>
                      (element.name ?? LocaleKeys.unknown.tr())
                          .toLowerCase()
                          .contains(value.toLowerCase())));
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: _filteredItems.map(
                  (e) {
                    return ListTile(
                      onTap: () {
                        widget.onCountrySelected(e);
                      },
                      title: Text(
                        e.name ?? LocaleKeys.unknown.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      trailing: e.id == widget.selected
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.circle_outlined),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectSippingStatePage extends StatefulWidget {
  final String title;
  final List<States> items;
  final int? selected;
  final Function(States) onCountrySelected;
  const _SelectSippingStatePage({
    Key? key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  _SelectSippingStatePageState createState() => _SelectSippingStatePageState();
}

class _SelectSippingStatePageState extends State<_SelectSippingStatePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final List<States> _filteredItems = [];

  @override
  void initState() {
    _filteredItems.addAll(widget.items);
    super.initState();
  }

  @override
  void dispose() {
    _filteredItems.clear();
    _searchController.dispose();
    _scrollController.dispose();
    debugPrint("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.85,
      child: ProductPageDefaultContainer(
        isFullPadding: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _searchController,
              hintText: LocaleKeys.search.tr(),
              onChanged: (value) {
                setState(() {
                  _filteredItems.clear();
                  _filteredItems.addAll(widget.items.where((element) =>
                      (element.name ?? LocaleKeys.unknown.tr())
                          .toLowerCase()
                          .contains(value.toLowerCase())));
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: _filteredItems.map(
                  (e) {
                    return ListTile(
                      onTap: () {
                        widget.onCountrySelected(e);
                      },
                      title: Text(
                        e.name ?? LocaleKeys.unknown.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      trailing: e.id == widget.selected
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.circle_outlined),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

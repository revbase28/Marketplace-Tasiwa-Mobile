import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
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

class CartItemCard extends ConsumerWidget {
  final CartItem cartItem;

  const CartItemCard({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _countryState = watch(countryNotifierProvider);

    Future<int?> _getCountry(List<Countries> coutries) async {
      final _result = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            height: context.screenHeight * 0.7,
            child: ProductPageDefaultContainer(
              isFullPadding: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Select Shipping Country",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: coutries.map(
                        (e) {
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context, e.id);
                            },
                            title: Text(
                              e.name ?? "Unknown",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: e.id! == cartItem.countryId
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
          return SizedBox(
            height: context.screenHeight * 0.7,
            child: ProductPageDefaultContainer(
              isFullPadding: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Select State",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: states.map(
                        (e) {
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context, e.id);
                            },
                            title: Text(
                              e.name ?? "Unknown",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: e.id == cartItem.stateId
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

                              await context
                                  .read(cartNotifierProvider.notifier)
                                  .updateCart(
                                    cartItem.id!,
                                    countryId: _selectedCountry,
                                    stateId: _selectedStateId,
                                  );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  _countryState.countryList!.any((element) =>
                                          element.id == cartItem.countryId)
                                      ? _countryState.countryList!
                                          .firstWhere(
                                              (e) => e.id == cartItem.countryId)
                                          .name!
                                      : "Unknown",
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
                ShippingDetails(cartItem: cartItem),
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
                Text(
                  widget.item.total!,
                  style: context.textTheme.bodyText2!.copyWith(
                      color: getColorBasedOnTheme(
                          context, kPriceColor, kDarkPriceColor),
                      fontWeight: FontWeight.bold),
                ).pOnly(right: 5),
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
                const SizedBox(height: 8),
                Text(
                  widget.item.quantity.toString(),
                  style: context.textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
          return ListTile(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return SizedBox(
                    height: context.screenHeight * 0.7,
                    child: ProductPageDefaultContainer(
                      isFullPadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Select Packaging",
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
                                    (e) => RadioListTile<int?>(
                                        value: e.id,
                                        groupValue: packagingModel?.id,
                                        title: Text(
                                          e.name ?? "Unknown",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        secondary: Text(
                                          e.cost ?? "0",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                color: getColorBasedOnTheme(
                                                    context,
                                                    kPriceColor,
                                                    kDarkPriceColor),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        onChanged: (value) async {
                                          Navigator.of(context).pop();
                                          context
                                              .read(
                                                  cartNotifierProvider.notifier)
                                              .updateCart(cartItem.id!,
                                                  packagingId: e.id);
                                        }),
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
            },
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            title: Text(
              LocaleKeys.packaging.tr() + ':',
              style: context.textTheme.caption!.copyWith(
                  fontWeight: FontWeight.bold, color: kPrimaryFadeTextColor),
            ),
            trailing: Text(
              double.parse(packagingModel?.costRaw ?? "0") <= 0.0
                  ? ""
                  : (packagingModel?.cost ?? "0"),
              style: context.textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getColorBasedOnTheme(
                      context, kPriceColor, kDarkPriceColor)),
            ),
            subtitle: Text(
              packagingModel?.name ?? '',
              style: context.textTheme.subtitle2!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }
}

class ShippingDetails extends ConsumerWidget {
  final CartItem cartItem;

  const ShippingDetails({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _userState = watch(userNotifierProvider);
    var params = {
      'ship_to_acountry_id': cartItem.countryId,
      'ship_to_state_id': cartItem.stateId,
    };

    String _url = API.shippingOptionsForCart(cartItem.id!) +
        "?" +
        params.entries.map((e) => e.key + "=" + e.value.toString()).join("&");
    final _shippingOptions = watch(cartShippingOptionsFutureProvider(_url));

    return _shippingOptions.when(
      data: (value) {
        if (value == null || value.isEmpty) {
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
                  "This seller does not deliver to your selected Country/Region. Change the shipping address or find other sellers who ship to your area.",
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
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) {
                      return SizedBox(
                        height: context.screenHeight * 0.7,
                        child: ProductPageDefaultContainer(
                          isFullPadding: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Select Shipping",
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
                                        (e) => RadioListTile<int?>(
                                            value: e.id,
                                            groupValue: _shippingOption?.id,
                                            title: Text(
                                              (e.name ?? "Unknown") +
                                                  " by " +
                                                  (e.carrierName ?? "Unknown"),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              e.deliveryTakes ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!,
                                            ),
                                            secondary: Text(
                                              e.cost ?? "0",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                    color: getColorBasedOnTheme(
                                                        context,
                                                        kPriceColor,
                                                        kDarkPriceColor),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            onChanged: (value) async {
                                              Navigator.of(context).pop();
                                              context
                                                  .read(cartNotifierProvider
                                                      .notifier)
                                                  .updateCart(
                                                    cartItem.id!,
                                                    shippingOptionId: e.id,
                                                    shippingZoneId:
                                                        e.shippingZoneId,
                                                  );
                                            }),
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
                },
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                title: Text(
                  LocaleKeys.shipping.tr() + ':',
                  style: context.textTheme.caption!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryFadeTextColor),
                ),
                trailing: Text(
                  double.parse(_shippingOption.costRaw ?? "0") <= 0.0
                      ? ""
                      : (_shippingOption.cost ?? "0"),
                  style: context.textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: getColorBasedOnTheme(
                          context, kPriceColor, kDarkPriceColor)),
                ),
                subtitle: Text(
                  (_shippingOption.name ?? 'Unknown') +
                      " by " +
                      (_shippingOption.carrierName ?? 'Unknown'),
                  style: context.textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                              .read(cartItemDetailsNotifierProvider.notifier)
                              .getCartItemDetails(cartItem.id);

                          context.nextPage(
                              CheckoutScreen(customerEmail: _customerEmail));
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
        Text(cartItem.grandTotal!,
            style: context.textTheme.bodyText2!.copyWith(
                color:
                    getColorBasedOnTheme(context, kPriceColor, kDarkPriceColor),
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}






// ElevatedButton(
//                             onPressed: () async {
//                               String? _customerEmail;

//                               if (accessAllowed) {
//                                 if (userState is UserLoadedState) {
//                                   _customerEmail = userState.user!.email!;
//                                 }
//                               }

//                               context
//                                   .read(paymentOptionsNotifierProvider.notifier)
//                                   .fetchPaymentMethod(
//                                       cartId: cartItem.id!.toString());
//                               context
//                                   .read(
//                                       cartItemDetailsNotifierProvider.notifier)
//                                   .getCartItemDetails(cartItem.id);

//                               // context.nextPage(
//                               //     CheckoutScreen(customerEmail: customerEmail));
//                             },
//                             child: Text(LocaleKeys.checkout.tr()))
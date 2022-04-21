import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/models/address/states_model.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/product_details/components/product_brand_card.dart';
import 'package:zcart/views/screens/product_details/components/ratings_and_reviews.dart';
import 'package:zcart/views/screens/product_details/components/shop_card.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/my_cart_tab.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_details.dart';
import 'package:zcart/views/shared_widgets/image_viewer_page.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/views/shared_widgets/system_config_builder.dart';
import 'components/frequently_bought_together.dart';
import 'components/more_offer_from_seller.dart';
import 'components/product_details_widget.dart';
import 'components/product_name_card_dart.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productSlug;
  const ProductDetailsScreen({
    Key? key,
    required this.productSlug,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late String _productSlug;

  @override
  void initState() {
    _productSlug = widget.productSlug;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final _productDetailsProvider =
            watch(productDetailsFutureProvider(_productSlug));

        final _cartState = watch(cartNotifierProvider);
        final _wishListState = watch(wishListNotifierProvider);

        int? _cartItems;
        if (_cartState is CartLoadedState) {
          _cartItems = 0;
          if (_cartState.cartList != null) {
            for (var item in _cartState.cartList!) {
              _cartItems = _cartItems! + item.items!.length;
            }
          }
        }
        bool _isInWishList = false;

        _productDetailsProvider.whenData((value) {
          if (value != null) {
            if (_wishListState is WishListLoadedState) {
              _isInWishList = _wishListState.wishList
                  .any((element) => element.slug! == value.data!.slug!);
            }
          }
        });

        return _productDetailsProvider.when(
          data: (value) {
            if (value == null) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(LocaleKeys.product_details.tr()),
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                body: Center(child: Text(LocaleKeys.something_went_wrong.tr())),
              );
            } else {
              return _ProductDetailsBody(
                details: value,
                isWishlist: _isInWishList,
                cartItemsCount: _cartItems,
                onChangedVariant: (newSlug) {
                  setState(() {
                    _productSlug = newSlug;
                  });
                },
              );
            }
          },
          loading: () => Scaffold(body: const ProductLoadingWidget().p(10)),
          error: (error, stackTrace) {
            debugPrint("Stack Trace: $stackTrace");
            return Scaffold(
                appBar: AppBar(
                  title: Text(LocaleKeys.product_details.tr()),
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                body: Center(
                  child: Text(
                    error.toString(),
                  ),
                ));
          },
        );
      },
    );
  }
}

class _ProductDetailsBody extends StatefulWidget {
  final ProductDetailsModel details;
  final int? cartItemsCount;
  final bool isWishlist;
  final Function(String) onChangedVariant;

  const _ProductDetailsBody({
    Key? key,
    required this.details,
    required this.cartItemsCount,
    required this.isWishlist,
    required this.onChangedVariant,
  }) : super(key: key);

  @override
  __ProductDetailsBodyState createState() => __ProductDetailsBodyState();
}

class __ProductDetailsBodyState extends State<_ProductDetailsBody> {
  late int _quantity;
  late ProductDetailsModel _details;
  late int _countryId;
  int? _stateId;
  String? _selectedShippingOption;
  final List<_ProductCountry> _countries = [];
  final List<_ProductCountry> _states = [];
  final List<ShippingOption> _shippingOptions = [];
  final List<Attribute> _selectedAttributes = [];
  Map<String, AttributeValue>? _allAttributes;

  bool _isNotAvailable = false;

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    setState(() {
      _quantity--;
    });
  }

  @override
  void initState() {
    _details = widget.details;
    _countryId = _details.shippingCountryId ?? 0;
    _quantity = _details.data!.minOrderQuantity ?? 1;
    _stateId = _details.shippingStateId;

    if (_details.countries != null) {
      for (var key in _details.countries!.keys) {
        _countries.add(_ProductCountry(
          id: key.toInt(),
          name: _details.countries![key]!,
        ));
      }
    }
    if (_details.states != null) {
      for (var key in _details.states!.keys) {
        _states.add(_ProductCountry(
          id: key.toInt(),
          name: _details.states![key]!,
        ));
      }
    }

    if (_details.shippingOptions != null) {
      _shippingOptions.addAll(_details.shippingOptions!);
      _selectedShippingOption =
          _shippingOptions.isNotEmpty ? _shippingOptions.first.name : null;
    }

    _allAttributes = _details.variants?.attributes;

    if (_details.data?.attributes != null &&
        _details.data?.attributes!.isNotEmpty == true) {
      _selectedAttributes.addAll(_details.data!.attributes!);
    } else if (_allAttributes != null) {
      for (var key in _allAttributes!.keys) {
        _selectedAttributes.add(
          Attribute(
            id: key.toInt(),
            value: int.parse(_allAttributes![key]!.value.keys.toList().first),
          ),
        );
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _totalPrice = double.parse(_details.data!.rawPrice!) * _quantity;

    int? _shippingId;
    int? _shippingZoneId;
    if (_shippingOptions.isNotEmpty) {
      _shippingId = _shippingOptions
          .firstWhere((element) => element.name == _selectedShippingOption)
          .id;
      _shippingZoneId = _shippingOptions
          .firstWhere((element) => element.name == _selectedShippingOption)
          .shippingZoneId;
      _totalPrice += double.parse(_shippingOptions
              .firstWhere((element) => element.name == _selectedShippingOption)
              .costRaw ??
          "0.0");
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _details.variants?.images == null ||
                              _details.variants!.images!.isEmpty
                          ? SizedBox(
                              height: 300,
                              child: Center(
                                child: TextIcon(
                                  text: LocaleKeys.image_not_available.tr(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : ProductDetailsImageSection(
                              images: _details.variants!.images!,
                              selectedImageId: _details.data!.imageId,
                            ),
                      const SizedBox(height: 10),
                      ProductPageDefaultContainer(
                          isFullPadding: true,
                          child: ProductNameCard(
                              onDoneCountDown: () {
                                widget.onChangedVariant(_details.data!.slug!);
                              },
                              productModel: _details,
                              isNotAvailable: _isNotAvailable)),
                      const SizedBox(height: 10),

                      _countries.isEmpty
                          ? const SizedBox()
                          : Column(
                              children: [
                                _shippingZoneSelection(context),
                                const SizedBox(height: 10),
                              ],
                            ),

                      ProductPageDefaultContainer(
                        isFullPadding: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(LocaleKeys.quantity.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                    Text(
                                        (_isNotAvailable
                                                    ? 0
                                                    : _details.data
                                                            ?.stockQuantity ??
                                                        0)
                                                .toString() +
                                            " " +
                                            LocaleKeys.in_stock.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: getColorBasedOnTheme(
                                        context,
                                        kDarkColor.withOpacity(0.5),
                                        kLightColor.withOpacity(0.5),
                                      ),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CupertinoButton(
                                        padding: const EdgeInsets.all(0),
                                        child: Icon(
                                          Icons.remove,
                                          color: getColorBasedOnTheme(
                                              context, kDarkColor, kLightColor),
                                        ),
                                        onPressed: _isNotAvailable
                                            ? null
                                            : _quantity ==
                                                    _details
                                                        .data!.minOrderQuantity
                                                ? () {
                                                    toast(
                                                      LocaleKeys
                                                          .reached_minimum_quantity
                                                          .tr(),
                                                    );
                                                  }
                                                : _decreaseQuantity,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _quantity.toString(),
                                        style: context.textTheme.headline6!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CupertinoButton(
                                        padding: const EdgeInsets.all(0),
                                        child: Icon(
                                          Icons.add,
                                          color: getColorBasedOnTheme(
                                              context, kDarkColor, kLightColor),
                                        ),
                                        onPressed: _isNotAvailable
                                            ? null
                                            : _quantity ==
                                                    _details.data!.stockQuantity
                                                ? () {
                                                    toast(
                                                      LocaleKeys
                                                          .reached_maximum_quantity
                                                          .tr(),
                                                    );
                                                  }
                                                : _increaseQuantity,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _selectedAttributes.isEmpty &&
                                    _allAttributes == null
                                ? const SizedBox()
                                : _attributesSection(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      _details.data!.feedbacks.isEmpty
                          ? const SizedBox()
                          : Column(
                              children: [
                                ProductPageDefaultContainer(
                                  child: ProductRatingsAndReview(
                                    productSlug: _details.data!.slug!,
                                    feedbacks: _details.data!.feedbacks,
                                    feedBackCount:
                                        _details.data!.feedbacksCount ?? 0,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),

                      ProductDetailsWidget(details: _details),
                      // BrandCards

                      _details.data!.product!.manufacturer!.slug == null
                          ? const SizedBox()
                          : Column(
                              children: [
                                ProductPageDefaultContainer(
                                    child: ProductBrandCard(details: _details)),
                                const SizedBox(height: 10),
                              ],
                            ),

                      ProductPageDefaultContainer(
                          child: MoreOffersFromSellerCard(details: _details)),
                      const SizedBox(height: 10),
                      ProductPageDefaultContainer(
                          child: ShopCard(details: _details)),
                      const SizedBox(height: 10),
                      FrequentlyBoughtTogetherCard(details: _details),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.,
                    children: [
                      SystemConfigBuilder(
                        builder: (context, systemConfig) {
                          return systemConfig?.enableChat == true
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: LocaleKeys.contact_seller.tr(),
                                      child: ProductDetailsPageIconButton(
                                        icon: const Icon(
                                            CupertinoIcons.chat_bubble_2_fill),
                                        backgroundColor: getColorBasedOnTheme(
                                            context, kLightColor, kDarkBgColor),
                                        onPressed: () {
                                          if (accessAllowed) {
                                            context
                                                .read(productChatProvider
                                                    .notifier)
                                                .productConversation(
                                                    _details.data!.shop!.id);

                                            context.nextPage(VendorChatScreen(
                                                shopId: _details.data!.shop!.id,
                                                shopImage:
                                                    _details.data!.shop!.image,
                                                shopName:
                                                    _details.data!.shop!.name,
                                                shopVerifiedText: _details
                                                    .data!.shop!.verifiedText));
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen(
                                                  needBackButton: true,
                                                  nextScreenIndex: 0,
                                                  nextScreen:
                                                      ProductDetailsScreen(
                                                          productSlug: _details
                                                              .data!.slug!),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                )
                              : const SizedBox();
                        },
                      ),
                      Tooltip(
                        message: LocaleKeys.vendor_details.tr(),
                        child: ProductDetailsPageIconButton(
                          icon: const Icon(Icons.store),
                          backgroundColor: getColorBasedOnTheme(
                              context, kLightColor, kDarkBgColor),
                          onPressed: () {
                            context
                                .read(vendorDetailsNotifierProvider.notifier)
                                .getVendorDetails(_details.data!.shop!.slug);
                            context
                                .read(vendorItemsNotifierProvider.notifier)
                                .getVendorItems(_details.data!.shop!.slug);
                            context.nextPage(const VendorsDetailsScreen());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProductDetailsPageIconButton(
                          backgroundColor:
                              _isNotAvailable ? kFadeColor : kPrimaryColor,
                          isNoWidth: true,
                          onPressed: _isNotAvailable
                              ? () {}
                              : _selectedShippingOption == null
                                  ? () {
                                      toast(LocaleKeys
                                          .please_select_shipping_option
                                          .tr());
                                    }
                                  : () async {
                                      if (_details.data!.stockQuantity ==
                                              null ||
                                          _details.data!.stockQuantity! < 0) {
                                        toast(LocaleKeys.out_of_stock.tr());
                                        return;
                                      } else {
                                        toast(LocaleKeys.please_wait.tr());
                                        await context
                                            .read(cartNotifierProvider.notifier)
                                            .addToCart(
                                                context, _details.data!.slug!,
                                                countryId: _countryId,
                                                quantity: _quantity,
                                                shippingOptionId: _shippingId,
                                                stateId: _stateId,
                                                shippingZoneId:
                                                    _shippingZoneId);
                                      }
                                    },
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.cart_fill_badge_plus,
                                  color: kLightColor,
                                ).pOnly(right: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(LocaleKeys.add_to_cart.tr(),
                                        style: context.textTheme.subtitle2!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kLightColor,
                                        )),
                                    _isNotAvailable
                                        ? const SizedBox()
                                        : Text(
                                            "${LocaleKeys.total.tr()} - ${_details.data!.currencySymbol!}${_totalPrice.toDoubleStringAsPrecised(length: 2)}",
                                            style: context.textTheme.overline!
                                                .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: kLightColor,
                                            ),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: ProductDetailsPageIconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 35,
                ),
                backgroundColor:
                    getColorBasedOnTheme(context, kLightColor, kDarkBgColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 70,
              child: ProductDetailsPageIconButton(
                backgroundColor:
                    getColorBasedOnTheme(context, kLightColor, kDarkBgColor),
                icon: Icon(
                  widget.isWishlist
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  size: 28,
                  color: widget.isWishlist ? Colors.red : null,
                ),
                onPressed: () async {
                  if (widget.isWishlist) {
                    toast(LocaleKeys.item_already_wishlist.tr());
                  } else {
                    toast(LocaleKeys.adding_to_wishlist.tr());
                    await context
                        .read(wishListNotifierProvider.notifier)
                        .addToWishList(_details.data!.slug, context);
                  }
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: ProductDetailsPageIconButton(
                backgroundColor: kPrimaryColor,
                icon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: VxBadge(
                    position: VxBadgePosition.rightBottom,
                    child: const Icon(CupertinoIcons.cart, color: kLightColor),
                    size: 16,
                    count: widget.cartItemsCount,
                    textStyle: Theme.of(context).textTheme.caption!.copyWith(
                        fontWeight: FontWeight.bold, color: kPrimaryColor),
                    color: kLightColor,
                  ),
                ),
                onPressed: () {
                  context.nextPage(const MyCartTab());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _attributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 0),
        ..._selectedAttributes
            .map(
              (e) => _AttributeItem(
                attribute: e,
                value: _allAttributes![e.id.toString()]!,
                onTap: () async {
                  final _result =
                      await _getAttribute(e, _allAttributes![e.id.toString()]!);

                  if (_result != null) {
                    if (_result.value == e.value) {
                      debugPrint("Same");
                    } else {
                      setState(() {
                        _selectedAttributes[_selectedAttributes.indexOf(e)] =
                            _result;
                      });

                      Map<String, String> _requestBody = {};
                      for (var item in _selectedAttributes) {
                        _requestBody["attributes[${item.id}]"] =
                            item.value.toString();
                      }
                      final _newVariant = await context
                          .read(getProductDetailsModelProvider)
                          .getProductVariantDetails(
                            _details.data!.slug!,
                            _requestBody,
                          );

                      if (_newVariant != null) {
                        setState(() {
                          _isNotAvailable = false;
                        });
                        debugPrint(_newVariant.data.slug);
                        widget.onChangedVariant(_newVariant.data.slug!);
                      } else {
                        setState(() {
                          _isNotAvailable = true;
                        });
                      }
                    }
                  } else {}
                },
              ),
            )
            .toList()
      ],
    );
  }

  Future<Attribute?> _getAttribute(
      Attribute attribute, AttributeValue attributeValue) async {
    final _result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                  "${LocaleKeys.select_variant_for.tr()} '${attributeValue.name}'",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: attributeValue.value.keys.map((e) {
                      return Card(
                        color: getColorBasedOnTheme(
                            context, kLightCardBgColor, kDarkBgColor),
                        child: ListTile(
                          title: Text(attributeValue.value[e]!),
                          trailing: attribute.value == int.parse(e)
                              ? const Icon(Icons.check_circle)
                              : const Icon(Icons.circle_outlined),
                          onTap: () {
                            Navigator.pop(
                                context,
                                Attribute(
                                  id: attribute.id,
                                  value: int.parse(e),
                                ));
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return _result is Attribute ? _result : null;
  }

  ProductPageDefaultContainer _shippingZoneSelection(BuildContext context) {
    ShippingOption? _option;
    for (var i = 0; i < _shippingOptions.length; i++) {
      if (_shippingOptions
          .any((element) => element.name == _selectedShippingOption)) {
        _option = _shippingOptions
            .firstWhere((element) => element.name == _selectedShippingOption);
      }
    }

    String? _countryName;
    if (_countries.any((element) => element.id == _countryId)) {
      _countryName =
          _countries.firstWhere((element) => element.id == _countryId).name;
    }
    String? _stateName;
    if (_states.any((element) => element.id == _stateId)) {
      _stateName = _states.firstWhere((element) => element.id == _stateId).name;
    }

    return ProductPageDefaultContainer(
      child: ListTile(
        leading: const Icon(Icons.delivery_dining),
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.zero,
        subtitle: GestureDetector(
          onTap: _selectedShippingOption == null ? null : _selectShippingOption,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              _selectedShippingOption == null
                  ? Text(LocaleKeys.seller_doesnt_ship_this_area.tr(),
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            fontWeight: FontWeight.bold,
                          ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                              "${_option?.name ?? LocaleKeys.unknown.tr()} by ${_option?.carrierName ?? LocaleKeys.unknown.tr()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  )).pOnly(right: 8),
                        ),
                        Text(
                          LocaleKeys.change.tr(),
                          style: Theme.of(context).textTheme.caption!.copyWith(
                              fontWeight: FontWeight.bold, color: kFadeColor),
                        ),
                      ],
                    ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _option?.deliveryTakes ?? "",
                      style: context.textTheme.caption!,
                    ).pOnly(right: 8),
                  ),
                  Text(
                      double.parse(_option?.costRaw ?? "0") <= 0.0
                          ? ""
                          : (_option?.cost ?? "0"),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getColorBasedOnTheme(
                                context, kPriceColor, kDarkPriceColor),
                          )),
                ],
              )
            ],
          ),
        ),
        title: GestureDetector(
          onTap: () async {
            final _selectedCountryId = await _selectShippingCountry();

            if (_selectedCountryId != null) {
              setState(() {
                _countryId = _selectedCountryId;
              });

              final _getStatesForCurrentCountry = await context
                  .read(getProductDetailsModelProvider)
                  .getStatesFromSelectedCountry(_selectedCountryId);

              int? _selectedStateId;
              if (_getStatesForCurrentCountry != null &&
                  _getStatesForCurrentCountry.isNotEmpty) {
                _selectedStateId =
                    await _selectShippingState(_getStatesForCurrentCountry);

                setState(() {
                  _states.clear();
                  for (var element in _getStatesForCurrentCountry) {
                    _states.add(_ProductCountry(
                        id: element.id!,
                        name: element.name ?? LocaleKeys.unknown.tr()));
                  }
                  _stateId = _selectedStateId;
                });
              } else {
                setState(() {
                  _states.clear();
                  _stateId = null;
                });
              }

              final _newShippingOptions = await context
                  .read(getProductDetailsModelProvider)
                  .getProductShippingOptions(
                    countryId: _selectedCountryId,
                    listingId: _details.data!.id!,
                    stateId: _selectedStateId,
                  );
              if (_newShippingOptions != null &&
                  _newShippingOptions.isNotEmpty) {
                _shippingOptions.clear();
                setState(() {
                  _shippingOptions.addAll(_newShippingOptions);
                  _selectedShippingOption = _shippingOptions.first.name!;
                });
              } else {
                _shippingOptions.clear();
                setState(() {
                  _selectedShippingOption = null;
                });
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  LocaleKeys.ship_to.tr() +
                      " " +
                      (_stateName ?? _countryName ?? LocaleKeys.unknown.tr()),
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                LocaleKeys.change.tr(),
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontWeight: FontWeight.bold, color: kFadeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _selectShippingCountry() async {
    final int? _newCountryId = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SelectSippingCountryPage(
          title: LocaleKeys.select_shipping_country.tr(),
          items: _countries,
          onCountrySelected: (country) {
            Navigator.pop(context, country.id);
          },
          selected: _countryId,
        );
      },
    );

    return _newCountryId;
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
          onCountrySelected: (state) {
            Navigator.pop(context, state.id);
          },
          selected: _stateId,
        );
        // return SizedBox(
        //   height: context.screenHeight * 0.85,
        //   child: ProductPageDefaultContainer(
        //     isFullPadding: true,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.stretch,
        //       children: [
        //         Text(
        //           "Select State",
        //           style: Theme.of(context)
        //               .textTheme
        //               .headline6!
        //               .copyWith(fontWeight: FontWeight.bold),
        //         ),
        //         const SizedBox(height: 10),
        //         Expanded(
        //           child: ListView(
        //             children: states.map(
        //               (e) {
        //                 return ListTile(
        //                   onTap: () {
        //                     Navigator.pop(context, e.id);
        //                   },
        //                   title: Text(
        //                     e.name ?? "Unknown",
        //                     style: Theme.of(context)
        //                         .textTheme
        //                         .subtitle2!
        //                         .copyWith(fontWeight: FontWeight.bold),
        //                   ),
        //                   trailing: e.id == _stateId
        //                       ? const Icon(Icons.check_circle)
        //                       : const Icon(Icons.circle_outlined),
        //                 );
        //               },
        //             ).toList(),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // );
      },
    );

    return _state;
  }

  void _selectShippingOption() async {
    await showModalBottomSheet(
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
                  LocaleKeys.select_shipping_option.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: _shippingOptions
                        .map(
                          (e) => ListTile(
                            title: Text(
                              (e.name ?? LocaleKeys.unknown.tr()) +
                                  " by " +
                                  (e.carrierName ?? LocaleKeys.unknown.tr()),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            trailing: Text(
                              e.cost ?? "0",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: getColorBasedOnTheme(context,
                                          kPriceColor, kDarkPriceColor)),
                            ),
                            subtitle: Text(
                              e.deliveryTakes ?? LocaleKeys.not_available.tr(),
                              style: Theme.of(context).textTheme.caption!,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedShippingOption = e.name;
                              });
                              Navigator.of(context).pop();
                            },
                            minLeadingWidth: 0,
                            leading: _selectedShippingOption == e.name
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

class _AttributeItem extends StatelessWidget {
  final Attribute attribute;
  final AttributeValue value;
  final VoidCallback onTap;
  const _AttributeItem({
    Key? key,
    required this.attribute,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      title: Text(
        value.name,
        style: Theme.of(context).textTheme.caption!.copyWith(
            fontWeight: FontWeight.bold, color: kPrimaryFadeTextColor),
      ),
      subtitle: Text(
        value.value[attribute.value.toString()] ?? "",
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      trailing: const Icon(CupertinoIcons.chevron_down),
    );
  }
}

class ProductPageDefaultContainer extends StatelessWidget {
  final Widget child;
  final double padding;
  final bool isFullPadding;

  const ProductPageDefaultContainer({
    Key? key,
    required this.child,
    this.padding = 16,
    this.isFullPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isFullPadding ? padding : padding / 2, horizontal: padding),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class ProductDetailsImageSection extends StatefulWidget {
  final List<ProductImage> images;
  final int? selectedImageId;

  const ProductDetailsImageSection({
    Key? key,
    required this.images,
    this.selectedImageId,
  }) : super(key: key);

  @override
  State<ProductDetailsImageSection> createState() =>
      _ProductDetailsImageSectionState();
}

class _ProductDetailsImageSectionState
    extends State<ProductDetailsImageSection> {
  late PageController _pageController;
  late int _selectedImageIndex;

  @override
  void initState() {
    _selectedImageIndex = widget.selectedImageId == null
        ? 0
        : widget.images
            .indexWhere((element) => element.id == widget.selectedImageId);

    _pageController = PageController(initialPage: _selectedImageIndex);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView(
              onPageChanged: (value) {
                setState(() {
                  _selectedImageIndex = value;
                });
              },
              controller: _pageController,
              children: widget.images.map((element) {
                return GestureDetector(
                  onTap: () {
                    context.nextPage(
                      ImageViewerPage(
                          imageUrl: widget.images[_selectedImageIndex].path!,
                          title: LocaleKeys.product_image.tr()),
                    );
                  },
                  child: CachedNetworkImage(
                    key: ValueKey(element.path!),
                    imageUrl: element.path!,
                    fit: BoxFit.scaleDown,
                    errorWidget: (context, url, error) => const SizedBox(),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child:
                          CircularProgressIndicator(value: progress.progress),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 8,
            children: [
              for (final image in widget.images)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = widget.images.indexOf(image);
                      _pageController.animateToPage(_selectedImageIndex,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    key: ValueKey(image.path!),
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            _selectedImageIndex == widget.images.indexOf(image)
                                ? getColorBasedOnTheme(
                                    context, kDarkColor, kAccentColor)
                                : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: image.path!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ProductDetailsPageIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final bool isNoWidth;
  final bool isNoHeight;
  final Color backgroundColor;
  const ProductDetailsPageIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isNoWidth = false,
    this.isNoHeight = false,
    this.backgroundColor = kPrimaryFadeTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isNoWidth ? null : 50,
        height: isNoHeight ? null : 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color:
                  getColorBasedOnTheme(context, Colors.black12, Colors.black54),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: icon,
      ),
    );
  }
}

class _ProductCountry {
  int id;
  String name;
  _ProductCountry({
    required this.id,
    required this.name,
  });
}

class _SelectSippingCountryPage extends StatefulWidget {
  final String title;
  final List<_ProductCountry> items;
  final int? selected;
  final Function(_ProductCountry) onCountrySelected;
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
  final List<_ProductCountry> _filteredItems = [];

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
                  _filteredItems.addAll(widget.items.where((element) => element
                      .name
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
                        e.name,
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

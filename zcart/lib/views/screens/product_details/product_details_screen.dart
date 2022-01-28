import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/riverpod/state/product/product_state.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/components/product_brand_card.dart';
import 'package:zcart/views/screens/product_details/components/ratings_and_reviews.dart';
import 'package:zcart/views/screens/product_details/components/shop_card.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/screens/tabs/tabs.dart';
import 'package:zcart/views/shared_widgets/image_viewer_page.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'components/attribute_card.dart';
import 'components/frequently_bought_together.dart';
import 'components/more_offer_from_seller.dart';
import 'components/product_details_widget.dart';
import 'components/product_name_card_dart.dart';
import 'components/shipping_card.dart';

// class ProductDetailsScreen extends StatefulWidget {
//   const ProductDetailsScreen({Key? key}) : super(key: key);

//   @override
//   _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
// }

// class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();

//   bool _isInWishList = false;

//   @override
//   Widget build(BuildContext context) {
//     double _totalPrice = 0.0;
//     return ProviderListener<ProductState>(
//         provider: productNotifierProvider,
//         onChange: (context, state) {
//           if (state is ProductLoadedState) {
//             context.read(cartNotifierProvider.notifier).getCartList();
//             _quantity = state.productModel.data!.minOrderQuantity ?? 1;
//           }
//         },
//         child: Consumer(
//           builder: (context, watch, _) {
//             final _productDetailsState = watch(productNotifierProvider);
//             final _wishListState = watch(wishListNotifierProvider);

//             if (_productDetailsState is ProductLoadedState) {
//               if (_wishListState is WishListLoadedState) {
//                 _isInWishList = _wishListState.wishList.any((element) =>
//                     element.slug ==
//                     _productDetailsState.productModel.data!.slug);
//               }
//             }

//             if (_productDetailsState is ProductLoadedState) {
//               _totalPrice = double.parse(
//                       _productDetailsState.productModel.data!.rawPrice!) *
//                   _quantity;
//             }

//             final _cartState = watch(cartNotifierProvider);

//             int? _cartItems;
//             if (_cartState is CartLoadedState) {
//               _cartItems = 0;
//               if (_cartState.cartList != null) {
//                 for (var item in _cartState.cartList!) {
//                   _cartItems = _cartItems! + item.items!.length;
//                 }
//               }
//             }

//             return WillPopScope(
//               // ignore: missing_return
//               onWillPop: () async {
//                 /// Reason: Deep linking product details screen navigation.
//                 context
//                     .read(productSlugListProvider.notifier)
//                     .removeProductSlug();
//                 if (context.read(productSlugListProvider).isNotEmpty) {
//                   context
//                       .read(productNotifierProvider.notifier)
//                       .getProductDetails(
//                           context.read(productSlugListProvider).last);
//                 }

//                 Navigator.of(context).pop(true);

//                 return true;
//               },
//               child: Scaffold(
//                 appBar: AppBar(
//                   systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
//                   toolbarHeight: 0,
//                   backgroundColor: Colors.transparent,
//                 ),
//                 body: Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: _productDetailsState is ProductLoadedState
//                             ? Column(
//                                 children: [
//                                   ProductImageSlider(
//                                     sliderList: _productDetailsState
//                                         .productModel.variants!.images,
//                                   ),
//                                   ProductNameCard(
//                                           isWishlist: _isInWishList,
//                                           productModel:
//                                               _productDetailsState.productModel)
//                                       .pOnly(top: 5),
//                                   AttributeCard(
//                                     productModel:
//                                         _productDetailsState.productModel,
//                                     quantity: _quantity,
//                                     increaseQuantity: () => _increaseQuantity(),
//                                     decreaseQuantity: () => _decreaseQuantity(),
//                                     formKey: _formKey,
//                                   ).cornerRadius(10).p(10),
//                                   _productDetailsState
//                                               .productModel.shippingOptions ==
//                                           null
//                                       ? const SizedBox()
//                                       : ShippingCard(
//                                               productDetailsState:
//                                                   _productDetailsState)
//                                           .cornerRadius(10)
//                                           .px(10),

//                                   _productDetailsState
//                                           .productModel.data!.feedbacks.isEmpty
//                                       ? const SizedBox()
//                                       : ProductRatingsAndReview(
//                                               feedbacks: _productDetailsState
//                                                   .productModel.data!.feedbacks)
//                                           .cornerRadius(10)
//                                           .px(10)
//                                           .pOnly(top: 10),

//                                   ProductDetailsWidget(
//                                       productDetailsState:
//                                           _productDetailsState),
//                                   // BrandCards
//                                   ProductBrandCard(
//                                     productDetailsState: _productDetailsState,
//                                   ).cornerRadius(10).px(10).pOnly(top: 10),

//                                   MoreOffersFromSellerCard(
//                                           productDetailsState:
//                                               _productDetailsState)
//                                       .cornerRadius(10)
//                                       .px(10)
//                                       .pOnly(top: 10),

//                                   ShopCard(
//                                       productDetailsState:
//                                           _productDetailsState),
//                                   FrequentlyBoughtTogetherCard(
//                                           productDetailsState:
//                                               _productDetailsState)
//                                       .pOnly(bottom: 50)
//                                 ],
//                               )
//                             : const ProductLoadingWidget().p(10),
//                       ),
//                     ),
//                     Visibility(
//                       visible: _productDetailsState is! ProductLoadingState,
//                       child: Container(
//                         color: kDarkColor,
//                         padding: const EdgeInsets.all(10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const CircleAvatar(
//                               radius: 20,
//                               backgroundColor: kLightColor,
//                               child: Center(
//                                   child: Icon(CupertinoIcons.bubble_left_fill,
//                                       color: kDarkColor, size: 20)),
//                             ).cornerRadius(10).px(5).onInkTap(() {
//                               if (_productDetailsState is ProductLoadedState) {
//                                 if (accessAllowed) {
//                                   context
//                                       .read(productChatProvider.notifier)
//                                       .productConversation(_productDetailsState
//                                           .productModel.data!.shop!.id);

//                                   context.nextPage(VendorChatScreen(
//                                       shopId: _productDetailsState
//                                           .productModel.data!.shop!.id,
//                                       shopImage: _productDetailsState
//                                           .productModel.data!.shop!.image,
//                                       shopName: _productDetailsState
//                                           .productModel.data!.shop!.name,
//                                       shopVerifiedText: _productDetailsState
//                                           .productModel
//                                           .data!
//                                           .shop!
//                                           .verifiedText));
//                                 } else {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               const LoginScreen(
//                                                 needBackButton: true,
//                                               )));
//                                 }
//                               }
//                             }),
//                             ElevatedButton.icon(
//                                 style: ButtonStyle(
//                                   backgroundColor:
//                                       MaterialStateProperty.all(kLightColor),
//                                   shape: MaterialStateProperty.all(
//                                       const StadiumBorder()),
//                                   foregroundColor:
//                                       MaterialStateProperty.all(kDarkColor),
//                                 ),
//                                 onPressed: () {
//                                   context.nextAndRemoveUntilPage(
//                                       const BottomNavBar(selectedIndex: 4));
//                                 },
//                                 icon: const Icon(CupertinoIcons.cart,
//                                     color: kDarkColor, size: 20),
//                                 label: Text(_cartItems == null
//                                     ? "+"
//                                     : _cartItems.toString())),
//                             const Spacer(),
//                             _productDetailsState is ProductLoadedState
//                                 ? Container(
//                                     height: 40,
//                                     width: context.screenWidth * 0.50,
//                                     color: kPrimaryColor,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(LocaleKeys.add_to_cart.tr(),
//                                                 style: context
//                                                     .textTheme.subtitle2!
//                                                     .copyWith(
//                                                         color:
//                                                             kPrimaryLightTextColor)),
//                                             Text(
//                                               "${LocaleKeys.total.tr()} - ${_productDetailsState.productModel.data!.currencySymbol!}${_totalPrice.toDoubleStringAsPrecised(length: 2)}",
//                                               style: context.textTheme.overline!
//                                                   .copyWith(
//                                                       color:
//                                                           kPrimaryLightTextColor),
//                                             )
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           width: 10,
//                                         ),
//                                         const Icon(
//                                                 CupertinoIcons.cart_badge_plus,
//                                                 color: kPrimaryLightTextColor,
//                                                 size: 20)
//                                             .pOnly(left: 10)
//                                       ],
//                                     ).px(10),
//                                   ).cornerRadius(10).onInkTap(() async {
//                                     if (_productDetailsState.productModel
//                                                 .variants!.attributes !=
//                                             null
//                                         ? _formKey.currentState!.validate()
//                                         : true) {
//                                       toast(LocaleKeys.please_wait.tr());
//                                       context
//                                           .read(cartNotifierProvider.notifier)
//                                           .addToCart(
//                                               context,
//                                               _productDetailsState
//                                                   .productModel.data!.slug,
//                                               _quantity,
//                                               _productDetailsState.productModel
//                                                   .shippingCountryId,
//                                               _productDetailsState.productModel
//                                                           .shippingOptions ==
//                                                       null
//                                                   ? null
//                                                   : _productDetailsState
//                                                       .productModel
//                                                       .shippingOptions!
//                                                       .first
//                                                       .id,
//                                               _productDetailsState.productModel
//                                                           .shippingOptions ==
//                                                       null
//                                                   ? null
//                                                   : _productDetailsState
//                                                       .productModel
//                                                       .shippingOptions!
//                                                       .first
//                                                       .shippingZoneId);
//                                     }
//                                   })
//                                 : const SizedBox(),
//                           ],
//                         ),
//                       ),
//                       replacement: const SizedBox(),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ));
//   }
// }

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

  int _quantity = 1;

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
                appBar: AppBar(title: const Text("Product Details")),
                body: Center(child: Text(LocaleKeys.something_went_wrong.tr())),
              );
            } else {
              return _productDetailsLoadedBody(
                details: value,
                cartItems: _cartItems,
                isWishlist: _isInWishList,
                quantity: _quantity,
              );
            }
          },
          loading: () => Scaffold(
              // appBar: AppBar(title: const Text("Product Details")),
              body: const ProductLoadingWidget().p(10)),
          error: (error, stackTrace) => Scaffold(
              appBar: AppBar(title: const Text("Product Details")),
              body: Center(
                child: Text(error.toString()),
              )),
        );
      },
    );
  }

  Widget _productDetailsLoadedBody({
    required ProductDetailsModel details,
    required int? cartItems,
    required bool isWishlist,
    required int quantity,
  }) {
    final _totalPrice = double.parse(details.data!.rawPrice!) * _quantity;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      details.variants?.images == null ||
                              details.variants!.images!.isEmpty
                          ? SizedBox(
                              height: 300,
                              child: Center(
                                child: TextIcon(
                                  text: "Image Not Found",
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : ProductDetailsImageSection(
                              images: details.variants!.images!,
                              selectedImageId: details.data!.imageId,
                            ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: ProductDetailsPageIconButton(
                          icon: const Icon(Icons.chevron_left, size: 35),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 70,
                        child: ProductDetailsPageIconButton(
                          icon: Icon(
                            isWishlist
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            size: 28,
                            color: isWishlist ? Colors.red : null,
                          ),
                          onPressed: () async {
                            if (isWishlist) {
                              toast("Item is already added in the wishlist.");
                            } else {
                              toast(LocaleKeys.adding_to_wishlist.tr());
                              await context
                                  .read(wishListNotifierProvider.notifier)
                                  .addToWishList(details.data!.slug, context);
                            }
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ProductDetailsPageIconButton(
                          icon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: VxBadge(
                              position: VxBadgePosition.rightBottom,
                              child: const Icon(CupertinoIcons.cart),
                              size: 16,
                              count: cartItems,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kLightColor),
                              color: kDarkColor,
                            ),
                          ),
                          onPressed: () {
                            context.nextAndRemoveUntilPage(
                                const BottomNavBar(selectedIndex: 4));
                          },
                        ),
                      ),
                    ],
                  ),
                  ProductNameCard(productModel: details),

                  details.data!.feedbacks.isEmpty
                      ? const SizedBox()
                      : ProductRatingsAndReview(
                              feedbacks: details.data!.feedbacks)
                          .cornerRadius(10)
                          .pOnly(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),

                  ProductDetailsWidget(details: details),
                  // BrandCards
                  ProductBrandCard(
                    details: details,
                  ).cornerRadius(10).p(10),

                  MoreOffersFromSellerCard(details: details)
                      .cornerRadius(10)
                      .px(10),

                  ShopCard(details: details).cornerRadius(10).p(10),
                  FrequentlyBoughtTogetherCard(details: details).p(5)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProductDetailsPageIconButton(
                    icon: const Icon(CupertinoIcons.bubble_left),
                    onPressed: () {
                      if (accessAllowed) {
                        context
                            .read(productChatProvider.notifier)
                            .productConversation(details.data!.shop!.id);

                        context.nextPage(VendorChatScreen(
                            shopId: details.data!.shop!.id,
                            shopImage: details.data!.shop!.image,
                            shopName: details.data!.shop!.name,
                            shopVerifiedText:
                                details.data!.shop!.verifiedText));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen(
                                      needBackButton: true,
                                    )));
                      }
                    },
                  ),
                  const Spacer(),
                  // ButtonBar(
                  //   mainAxisSize: MainAxisSize.min,
                  //   buttonPadding: const EdgeInsets.only(left: 10),
                  //   buttonMinWidth: 30,
                  //   buttonHeight: 20,
                  //   children: <Widget>[
                  //     OutlinedButton(
                  //         style: ButtonStyle(
                  //           backgroundColor: MaterialStateProperty.all(
                  //             getColorBasedOnTheme(
                  //                 context, kLightBgColor, kDarkBgColor),
                  //           ),
                  //           foregroundColor: MaterialStateProperty.all(
                  //               getColorBasedOnTheme(
                  //                   context,
                  //                   kPrimaryDarkTextColor,
                  //                   kPrimaryLightTextColor)),
                  //           shape: MaterialStateProperty.all(
                  //               RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(10))),
                  //         ),
                  //         child: const Icon(Icons.remove),
                  //         onPressed: _quantity == details.data!.minOrderQuantity
                  //             ? () {
                  //                 toast(
                  //                   LocaleKeys.reached_minimum_quantity.tr(),
                  //                 );
                  //               }
                  //             : _decreaseQuantity),
                  //     OutlinedButton(
                  //       child: Text(
                  //         _quantity.toString(),
                  //         style: context.textTheme.subtitle2,
                  //       ),
                  //       onPressed: null,
                  //     ),
                  //     OutlinedButton(
                  //         style: ButtonStyle(
                  //             backgroundColor: MaterialStateProperty.all(
                  //               getColorBasedOnTheme(
                  //                   context, kLightBgColor, kDarkBgColor),
                  //             ),
                  //             foregroundColor: MaterialStateProperty.all(
                  //                 getColorBasedOnTheme(
                  //                     context,
                  //                     kPrimaryDarkTextColor,
                  //                     kPrimaryLightTextColor)),
                  //             shape: MaterialStateProperty.all(
                  //                 RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(10)))),
                  //         child: const Icon(Icons.add),
                  //         onPressed: _quantity == details.data!.stockQuantity
                  //             ? () {
                  //                 toast(
                  //                   LocaleKeys.reached_maximum_quantity.tr(),
                  //                 );
                  //               }
                  //             : _increaseQuantity),
                  //   ],
                  // ),
                  ProductDetailsPageIconButton(
                    icon: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          child: Icon(
                            Icons.remove,
                            color: getColorBasedOnTheme(
                                context, kDarkColor, kLightColor),
                          ),
                          onPressed: _quantity == details.data!.minOrderQuantity
                              ? () {
                                  toast(
                                    LocaleKeys.reached_minimum_quantity.tr(),
                                  );
                                }
                              : _decreaseQuantity,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _quantity.toString(),
                          style: context.textTheme.headline6!.copyWith(
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
                          onPressed: _quantity == details.data!.stockQuantity
                              ? () {
                                  toast(
                                    LocaleKeys.reached_maximum_quantity.tr(),
                                  );
                                }
                              : _increaseQuantity,
                        ),
                      ],
                    ),
                    isNoWidth: true,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ProductDetailsPageIconButton(
                    isNoWidth: true,
                    onPressed: () async {
                      toast(LocaleKeys.please_wait.tr());
                      await context
                          .read(cartNotifierProvider.notifier)
                          .addToCart(
                              context,
                              details.data!.slug!,
                              _quantity,
                              details.shippingCountryId,
                              details.shippingOptions?.first.id,
                              details.shippingOptions?.first.shippingZoneId);
                    },
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(LocaleKeys.add_to_cart.tr(),
                                style: context.textTheme.subtitle2!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              "${LocaleKeys.total.tr()} - ${details.data!.currencySymbol!}${_totalPrice.toDoubleStringAsPrecised(length: 2)}",
                              style: context.textTheme.overline!,
                            )
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(CupertinoIcons.cart_badge_plus)
                            .pOnly(left: 10)
                      ],
                    ).px(10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                          title: "Product Image"),
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
  const ProductDetailsPageIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isNoWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isNoWidth ? null : 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: getColorBasedOnTheme(context, kLightBgColor, kDarkCardBgColor),
          boxShadow: [
            BoxShadow(
              color: getColorBasedOnTheme(
                  context, Colors.black12, Colors.transparent),
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

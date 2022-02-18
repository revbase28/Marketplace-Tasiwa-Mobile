import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/product/random_item_state.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:easy_localization/easy_localization.dart';

class WishListTab extends ConsumerWidget {
  const WishListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final wishListState = watch(wishListNotifierProvider);
    final scrollControllerProvider =
        watch(wishlistScrollNotifierProvider.notifier);
    final randomItemState = watch(randomItemNotifierProvider);
    final randomScrollControllerProvider =
        watch(randomItemScrollNotifierProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.wishlist_text.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
                onPressed: () {
                  context
                      .read(wishListNotifierProvider.notifier)
                      .getMoreWishList();
                },
                icon: const Icon(Icons.sync))
          ],
        ),
        body: wishListState is WishListLoadedState
            ? wishListState.wishList.isEmpty
                ? ProviderListener<ScrollState>(
                    provider: randomItemScrollNotifierProvider,
                    onChange: (context, state) {
                      if (state is ScrollReachedBottomState) {
                        context
                            .read(randomItemNotifierProvider.notifier)
                            .getMoreRandomItems();
                      }
                    },
                    child: SingleChildScrollView(
                      controller: randomScrollControllerProvider.controller,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 70),
                          const Icon(Icons.info_outline),
                          Text(
                            LocaleKeys.no_item_found.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 50),

                          const RecentlyViewed().p(10),

                          /// Popular Items
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: randomItemState is RandomItemLoadedState
                                ? ProductDetailsCardGridView(
                                        title: LocaleKeys.additional_items.tr(),
                                        isTitleCentered: true,
                                        productList:
                                            randomItemState.randomItemList)
                                    .py(15)
                                : randomItemState is RandomItemErrorState
                                    ? ErrorMessageWidget(
                                        randomItemState.message)
                                    : const ProductLoadingWidget(),
                          )
                        ],
                      ),
                    ),
                  )
                : ProviderListener<ScrollState>(
                    onChange: (context, state) {
                      if (state is ScrollReachedBottomState) {
                        context
                            .read(wishListNotifierProvider.notifier)
                            .getMoreWishList();
                      }
                    },
                    provider: wishlistScrollNotifierProvider,
                    child: ListView.builder(
                        controller: scrollControllerProvider.controller,
                        itemCount: wishListState.wishList.length,
                        padding: const EdgeInsets.only(top: 5),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              context.nextPage(ProductDetailsScreen(
                                  productSlug:
                                      wishListState.wishList[index].slug!));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: getColorBasedOnTheme(
                                      context, kLightColor, kDarkCardBgColor),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: getColorBasedOnTheme(context,
                                          Colors.black12, Colors.black54),
                                      blurRadius: 6,
                                      offset: const Offset(0, 0),
                                      spreadRadius: 1,
                                    ),
                                  ]),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 12),
                              child: Slidable(
                                actionPane: const SlidableStrechActionPane(),
                                actionExtentRatio: 0.25,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl:
                                          wishListState.wishList[index].image!,
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                      progressIndicatorBuilder:
                                          (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                            value: progress.progress),
                                      ),
                                      height: 50,
                                      width: 50,
                                    ).pOnly(left: 10, right: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      if (wishListState
                                                              .wishList[index]
                                                              .stuffPick ??
                                                          false)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                              "Staff Pick",
                                                              style: context
                                                                  .textTheme
                                                                  .overline!
                                                                  .copyWith(
                                                                      color:
                                                                          kPrimaryLightTextColor)),
                                                        ).pOnly(right: 3),
                                                      if (wishListState
                                                              .wishList[index]
                                                              .hotItem ??
                                                          false)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                              "Hot Item",
                                                              style: context
                                                                  .textTheme
                                                                  .overline!
                                                                  .copyWith(
                                                                      color:
                                                                          kPrimaryLightTextColor)),
                                                        ).pOnly(right: 3),
                                                      if (wishListState
                                                              .wishList[index]
                                                              .freeShipping ??
                                                          false)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                              "Free Shipping",
                                                              style: context
                                                                  .textTheme
                                                                  .overline!
                                                                  .copyWith(
                                                                      color:
                                                                          kPrimaryLightTextColor)),
                                                        ).pOnly(right: 3),
                                                      if (wishListState
                                                              .wishList[index]
                                                              .condition ==
                                                          "New")
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text("New",
                                                              style: context
                                                                  .textTheme
                                                                  .overline!
                                                                  .copyWith(
                                                                      color:
                                                                          kPrimaryLightTextColor)),
                                                        ).pOnly(right: 3),
                                                      if (wishListState
                                                              .wishList[index]
                                                              .hasOffer ??
                                                          false)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                          child: Text(
                                                              wishListState
                                                                  .wishList[
                                                                      index]
                                                                  .discount!,
                                                              style: context
                                                                  .textTheme
                                                                  .overline!
                                                                  .copyWith(
                                                                      color:
                                                                          kPrimaryLightTextColor)),
                                                        ).pOnly(right: 3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            wishListState
                                                .wishList[index].title!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: context.textTheme.bodyText2!
                                                .copyWith(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Text(
                                                      wishListState
                                                              .wishList[index]
                                                              .hasOffer!
                                                          ? wishListState
                                                              .wishList[index]
                                                              .offerPrice!
                                                          : wishListState
                                                              .wishList[index]
                                                              .price!,
                                                      style: context
                                                          .textTheme.bodyText2!
                                                          .copyWith(
                                                              color: getColorBasedOnTheme(
                                                                  context,
                                                                  kPriceColor,
                                                                  kDarkPriceColor),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  wishListState.wishList[index]
                                                          .hasOffer!
                                                      ? Text(
                                                          wishListState
                                                              .wishList[index]
                                                              .price!,
                                                          style: context
                                                              .textTheme
                                                              .caption!
                                                              .copyWith(
                                                            color:
                                                                kPrimaryFadeTextColor,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          )).pOnly(left: 3)
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 80,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              showCustomConfirmDialog(
                                                context,
                                                dialogAnimation: DialogAnimation
                                                    .SLIDE_RIGHT_LEFT,
                                                dialogType: DialogType.DELETE,
                                                positiveText:
                                                    LocaleKeys.remove.tr(),
                                                title: LocaleKeys
                                                    .remove_from_wishlist
                                                    .tr(),
                                                onAccept: () {
                                                  toast(LocaleKeys.please_wait
                                                      .tr());
                                                  context
                                                      .read(
                                                          wishListNotifierProvider
                                                              .notifier)
                                                      .removeFromWishList(
                                                          wishListState
                                                              .wishList[index]
                                                              .id);
                                                },
                                              );
                                            },
                                            child: const Icon(Icons.favorite,
                                                color: Colors.red),
                                          ),
                                          const Spacer(),
                                          wishListState
                                                      .wishList[index].rating !=
                                                  null
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    const Icon(Icons.star,
                                                        color: kDarkPriceColor,
                                                        size: 14),
                                                    Text(
                                                      wishListState
                                                          .wishList[index]
                                                          .rating
                                                          .toString(),
                                                      textAlign: TextAlign.end,
                                                      style: context
                                                          .textTheme.caption!
                                                          .copyWith(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8)
                                  ],
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: LocaleKeys.delete.tr(),
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      toast(LocaleKeys.please_wait.tr());
                                      context
                                          .read(
                                              wishListNotifierProvider.notifier)
                                          .removeFromWishList(
                                              wishListState.wishList[index].id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  )
            : const ProductLoadingWidget().px(10));
  }
}

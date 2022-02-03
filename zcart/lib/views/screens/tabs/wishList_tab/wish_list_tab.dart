import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
                          return Container(
                            decoration: BoxDecoration(
                                color: getColorBasedOnTheme(
                                    context, kLightColor, kDarkCardBgColor),
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            padding: const EdgeInsets.all(5),
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
                                  ).p(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Wrap(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text("Staff Pick",
                                                  style: context
                                                      .textTheme.overline!
                                                      .copyWith(
                                                          color:
                                                              kPrimaryLightTextColor)),
                                            ).pOnly(right: 3).visible(
                                                wishListState.wishList[index]
                                                        .stuffPick ??
                                                    false),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text("Hot Item",
                                                  style: context
                                                      .textTheme.overline!
                                                      .copyWith(
                                                          color:
                                                              kPrimaryLightTextColor)),
                                            ).pOnly(right: 3).visible(
                                                wishListState.wishList[index]
                                                        .hotItem ??
                                                    false),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text("Free Shipping",
                                                  style: context
                                                      .textTheme.overline!
                                                      .copyWith(
                                                          color:
                                                              kPrimaryLightTextColor)),
                                            ).pOnly(right: 3).visible(
                                                wishListState.wishList[index]
                                                        .freeShipping ??
                                                    false),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text("New",
                                                  style: context
                                                      .textTheme.overline!
                                                      .copyWith(
                                                          color:
                                                              kPrimaryLightTextColor)),
                                            ).pOnly(right: 3).visible(
                                                wishListState.wishList[index]
                                                        .condition ==
                                                    "New"),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text(
                                                  wishListState.wishList[index]
                                                      .discount!,
                                                  style: context
                                                      .textTheme.overline!
                                                      .copyWith(
                                                          color:
                                                              kPrimaryLightTextColor)),
                                            ).pOnly(right: 3).visible(
                                                wishListState.wishList[index]
                                                        .hasOffer ??
                                                    false),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                wishListState
                                                    .wishList[index].title!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: context
                                                    .textTheme.bodyText2!
                                                    .copyWith(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).pOnly(bottom: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                                wishListState.wishList[index]
                                                        .hasOffer!
                                                    ? wishListState
                                                        .wishList[index]
                                                        .offerPrice!
                                                    : wishListState
                                                        .wishList[index].price!,
                                                style: context
                                                    .textTheme.bodyText2!
                                                    .copyWith(
                                                        color:
                                                            getColorBasedOnTheme(
                                                                context,
                                                                kPriceColor,
                                                                kDarkPriceColor),
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            wishListState
                                                    .wishList[index].hasOffer!
                                                ? Text(
                                                    wishListState
                                                        .wishList[index].price!,
                                                    style: context
                                                        .textTheme.caption!
                                                        .copyWith(
                                                      color:
                                                          kPrimaryFadeTextColor,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    )).pOnly(left: 3)
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.cart_badge_plus)
                                      .p(10)
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
                                        .read(wishListNotifierProvider.notifier)
                                        .removeFromWishList(
                                            wishListState.wishList[index].id);
                                  },
                                ),
                              ],
                            ),
                          ).onInkTap(() {
                            context.nextPage(ProductDetailsScreen(
                                productSlug:
                                    wishListState.wishList[index].slug!));
                          });
                        }),
                  )
            : const ProductLoadingWidget().px(10));
  }
}

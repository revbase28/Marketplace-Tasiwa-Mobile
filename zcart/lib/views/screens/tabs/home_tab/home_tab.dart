import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/deals/deal_of_the_day_model.dart' as deal;
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/deals_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/scroll_provider.dart';
import 'package:zcart/riverpod/state/deals_state.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/featured_brands.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'components/category_widget.dart';
import 'components/error_widget.dart';
import 'components/slider_widget.dart';
import 'components/search_bar.dart';
import 'components/banners_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final sliderState = watch(sliderNotifierProvider);
    final categoryState = watch(categoryNotifierProvider);
    final bannerState = watch(bannerNotifierProvider);
    final trendingNowState = watch(trendingNowNotifierProvider);
    final latestItemState = watch(latestItemNotifierProvider);
    final popularItemState = watch(popularItemNotifierProvider);
    final dealsUnderThePrice = watch(dealsUnderThePriceNotifierProvider);
    final dealOfTheDay = watch(dealOfThedayNotifierProvider);
    final randomItemState = watch(randomItemNotifierProvider);
    final scrollControllerProvider =
        watch(randomItemScrollNotifierProvider.notifier);

    return ProviderListener<ScrollState>(
        provider: randomItemScrollNotifierProvider,
        onChange: (context, state) {
          if (state is ScrollReachedBottomState) {
            context
                .read(randomItemNotifierProvider.notifier)
                .getMoreRandomItems();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                    ? kDarkBgColor
                    : kLightBgColor,
            flexibleSpace: const SafeArea(child: CustomSearchBar()),
          ),
          body: SingleChildScrollView(
            controller: scrollControllerProvider.controller,
            child: Column(
              children: [
                /// Slider
                sliderState is SliderLoadedState
                    ? SliderWidget(sliderState.sliderList).py(5)
                    : sliderState is SliderErrorState
                        ? ErrorMessageWidget(sliderState.message)
                        : Container(),

                /// Category
                (categoryState is CategoryInitialState ||
                        categoryState is CategoryLoadingState)
                    ? Container()
                    : categoryState is CategoryLoadedState
                        ? CategoryWidget(categoryState.categoryList).py(5)
                        : categoryState is CategoryErrorState
                            ? ErrorMessageWidget(categoryState.message)
                            : Container(),

                /// Banner
                bannerState is BannerLoadedState
                    ? BannerWidget(bannerState.bannerList!.sublist(0, 3))
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : Container(),

                /// Trending Now
                trendingNowState is TrendingNowLoadedState
                    ? ProductCard(
                            title: LocaleKeys.trending_now.tr(),
                            productList: trendingNowState.trendingNowList)
                        .py(15)
                    : trendingNowState is TrendingNowErrorState
                        ? ErrorMessageWidget(trendingNowState.message)
                        : ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? BannerWidget(
                        bannerState.bannerList!.sublist(3, 5),
                        isReverse: false,
                      )
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : Container(),

                ///Deals under the price
                dealsUnderThePrice is DealsUnderThePriceStateLoadedState
                    ? ProductCard(
                            title: dealsUnderThePrice
                                .dealsUnderThePrice!.meta!.dealTitle!,
                            productList:
                                dealsUnderThePrice.dealsUnderThePrice!.data)
                        .py(15)
                    : dealsUnderThePrice is DealsUnderThePriceStateErrorState
                        ? Container()
                        : ProductLoadingWidget(),

                ///Featured Brands
                const FeaturedBrands(),

                ///Deal of the day
                dealOfTheDay is DealOfTheDayStateLoadedState
                    ? DealOfTheDayWidget(
                            dealOfTheDay: dealOfTheDay.dealOfTheDay!)
                        .pOnly(bottom: 15)
                    : dealOfTheDay is DealOfTheDayStateErrorState
                        ? Container()
                        : ProductLoadingWidget(),

                /// Recently Added (Latest Item)
                latestItemState is LatestItemLoadedState
                    ? ProductCard(
                            title: LocaleKeys.recently_added.tr(),
                            productList: latestItemState.latestItemList)
                        .pOnly(bottom: 15)
                    : latestItemState is LatestItemErrorState
                        ? ErrorMessageWidget(latestItemState.message)
                        : ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? BannerWidget(bannerState.bannerList!.sublist(5, 7))
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : Container(),

                /// Popular Items
                popularItemState is PopularItemLoadedState
                    ? ProductCard(
                            title: LocaleKeys.popular_items.tr(),
                            productList: popularItemState.popularItemList)
                        .py(15)
                    : popularItemState is PopularItemErrorState
                        ? ErrorMessageWidget(popularItemState.message)
                        : ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? BannerWidget(
                        bannerState.bannerList!.sublist(7),
                        isReverse: false,
                      )
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : Container(),

                /// Random Items (Additional Items to Explore in the UI)
                randomItemState is RandomItemLoadedState
                    ? ProductDetailsCard(
                            isTitleCentered: true,
                            title: LocaleKeys.additional_items.tr(),
                            productList: randomItemState.randomItemList)
                        .py(20)
                    : randomItemState is RandomItemErrorState
                        ? ErrorMessageWidget(randomItemState.message)
                        : ProductLoadingWidget(),
              ],
            ).px(10),
          ),
        ));
  }
}

class DealOfTheDayWidget extends StatelessWidget {
  const DealOfTheDayWidget({
    Key? key,
    required this.dealOfTheDay,
  }) : super(key: key);

  final deal.DealOfTheDay dealOfTheDay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .read(productNotifierProvider.notifier)
            .getProductDetails(dealOfTheDay.data!.slug)
            .then((value) {
          getRecentlyViewedItems(context);
        });
        context
            .read(productSlugListProvider.notifier)
            .addProductSlug(dealOfTheDay.data!.slug);
        context.nextPage(const ProductDetailsScreen());
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deal Of The Day",
                  style: context.textTheme.headline6!
                      .copyWith(color: kPrimaryFadeTextColor))
              .pOnly(bottom: 10),
          Flexible(
            child: Stack(
              children: [
                Container(
                  color: kDarkColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: CarouselSlider(
                            options: CarouselOptions(
                              scrollDirection: Axis.horizontal,
                              height: context.percentHeight * 45,
                              viewportFraction: 1,
                              autoPlay: true,
                            ),
                            items: dealOfTheDay.data!.images!
                                .map((item) => Image.network(
                                      item.path!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        print(
                                            "Exception: $exception\nStackTrace: $stackTrace");
                                        return Container();
                                      },
                                    ).pSymmetric(v: 24))
                                .toList()),
                      ),
                      Text(
                        dealOfTheDay.data!.title!.toUpperCase(),
                        maxLines: null,
                        softWrap: true,
                        style: context.textTheme.headline6!.copyWith(
                            color: kPrimaryLightTextColor,
                            fontWeight: FontWeight.bold),
                      ).pSymmetric(h: 16).pOnly(bottom: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: dealOfTheDay.data!.hasOffer!
                            ? Text(dealOfTheDay.data!.offerPrice,
                                style: context.textTheme.headline6!.copyWith(
                                    color: kDarkPriceColor,
                                    fontWeight: FontWeight.bold))
                            : Text(dealOfTheDay.data!.price!,
                                style: context.textTheme.headline6!.copyWith(
                                    color: kDarkPriceColor,
                                    fontWeight: FontWeight.bold)),
                      ).pOnly(bottom: 10),
                      Text(
                        dealOfTheDay.data!.description!,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.subtitle1!
                            .copyWith(color: kPrimaryLightTextColor),
                      ).pSymmetric(h: 16).pOnly(bottom: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: dealOfTheDay.data!.keyFeatures!
                            .sublist(0, 3)
                            .map((e) => Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      color: kDarkPriceColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        e,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.caption!
                                            .copyWith(
                                                color: kPrimaryLightTextColor),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ).pSymmetric(h: 16).pOnly(bottom: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(kDarkBgColor),
                              backgroundColor:
                                  MaterialStateProperty.all(kDarkPriceColor),
                            ),
                            onPressed: () {
                              context
                                  .read(productNotifierProvider.notifier)
                                  .getProductDetails(dealOfTheDay.data!.slug)
                                  .then((value) {
                                getRecentlyViewedItems(context);
                              });
                              context
                                  .read(productSlugListProvider.notifier)
                                  .addProductSlug(dealOfTheDay.data!.slug);
                              context.nextPage(const ProductDetailsScreen());
                            },
                            child: const Icon(
                              Icons.add_shopping_cart,
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () async {
                              toast(LocaleKeys.adding_to_wishlist.tr());
                              await context
                                  .read(wishListNotifierProvider.notifier)
                                  .addToWishList(
                                      dealOfTheDay.data!.slug, context);
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.favorite_border,
                                  color: kDarkPriceColor,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Add to Wishlist",
                                  style: TextStyle(
                                    color: kDarkPriceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).pSymmetric(h: 16).pOnly(bottom: 16)
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                      ),
                      color: kDarkPriceColor,
                    ),
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Transform(
                        alignment: FractionalOffset.bottomRight,
                        transform: Matrix4.identity()
                          ..rotateZ(45 * 3.1415927 / 180),
                        child: Text(
                          "HOT",
                          style: context.textTheme.caption!.copyWith(
                              color: kDarkBgColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}

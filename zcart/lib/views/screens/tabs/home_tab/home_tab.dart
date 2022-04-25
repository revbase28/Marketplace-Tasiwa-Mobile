import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/deals/deal_of_the_day_model.dart' as deal;
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/deals_provider.dart';
import 'package:zcart/riverpod/providers/package_info_provider.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/deals_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/not_logged_in_screen.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/brand/featured_brands.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/flash_deals.dart';
import 'package:zcart/views/screens/tabs/home_tab/search/search_screen.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'components/banners_widget.dart';
import 'components/category_widget.dart';
import 'components/error_widget.dart';
import 'components/slider_widget.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final sliderState = watch(sliderNotifierProvider);

    final bannerState = watch(bannerNotifierProvider);
    final trendingNowState = watch(trendingNowNotifierProvider);
    final latestItemState = watch(latestItemNotifierProvider);
    final popularItemState = watch(popularItemNotifierProvider);
    final dealsUnderThePrice = watch(dealsUnderThePriceNotifierProvider);
    final dealOfTheDay = watch(dealOfThedayNotifierProvider);
    final randomItemState = watch(randomItemNotifierProvider);
    final scrollControllerProvider =
        watch(randomItemScrollNotifierProvider.notifier);

    final _flashDealsProvider = watch(flashDealPluginProvider);

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
                getColorBasedOnTheme(context, kLightBgColor, kDarkBgColor),
            centerTitle: true,
            title: SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: Image.asset(
                AppImages.topBar,
                fit: BoxFit.fitWidth,
              ),
            ),
            iconTheme: IconThemeData(
                color: getColorBasedOnTheme(context, kDarkColor, kLightColor)),
            actions: [
              IconButton(
                  onPressed: () {
                    context.nextPage(const SearchScreen());
                  },
                  icon: const Icon(Icons.search))
            ],
            // flexibleSpace: const SafeArea(child: CustomSearchBar()),
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            controller: scrollControllerProvider.controller,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              children: [
                /// Slider
                sliderState is SliderLoadedState
                    ? sliderState.sliderList == null ||
                            sliderState.sliderList!.isEmpty
                        ? const SizedBox()
                        : SliderWidget(sliderState.sliderList).py(5)
                    : sliderState is SliderErrorState
                        ? ErrorMessageWidget(sliderState.message)
                        : const SizedBox(),

                const FeaturedCategoriesSection(),

                ///Flash Deals
                _flashDealsProvider.when(
                  data: (value) => value == null
                      ? const SizedBox()
                      : FlashDealsSection(flashDeals: value).pOnly(bottom: 16),
                  loading: () => const SizedBox(),
                  error: (error, stackTrace) => const SizedBox(
                      //  child: Text(error.toString()),
                      ),
                ),

                /// Banner
                bannerState is BannerLoadedState
                    ? bannerState.bannerList == null ||
                            bannerState.bannerList!.isEmpty
                        ? const SizedBox()
                        : BannerWidget(bannerState.bannerList!.sublist(
                                0,
                                bannerState.bannerList!.length >= 3
                                    ? 3
                                    : bannerState.bannerList!.length))
                            .py(5)
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : const SizedBox(),

                /// Trending Now
                trendingNowState is TrendingNowLoadedState
                    ? ProductCard(
                            title: LocaleKeys.trending_now.tr(),
                            productList: trendingNowState.trendingNowList)
                        .py(15)
                    : trendingNowState is TrendingNowErrorState
                        ? ErrorMessageWidget(trendingNowState.message)
                        : const ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? bannerState.bannerList == null
                        ? const SizedBox()
                        : bannerState.bannerList!.length <= 3
                            ? const SizedBox()
                            : BannerWidget(
                                bannerState.bannerList!.sublist(
                                    3,
                                    bannerState.bannerList!.length <= 5
                                        ? bannerState.bannerList!.length
                                        : 5),
                                isReverse: false,
                              )
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : const SizedBox(),

                ///Deals under the price
                dealsUnderThePrice is DealsUnderThePriceStateLoadedState
                    ? ProductCard(
                            title: dealsUnderThePrice
                                .dealsUnderThePrice!.meta!.dealTitle!,
                            productList:
                                dealsUnderThePrice.dealsUnderThePrice!.data)
                        .py(15)
                    : dealsUnderThePrice is DealsUnderThePriceStateErrorState
                        ? const SizedBox()
                        : const ProductLoadingWidget(),

                ///Featured Brands
                const FeaturedBrands().pOnly(bottom: 10),

                ///Deal of the day
                dealOfTheDay is DealOfTheDayStateLoadedState
                    ? DealOfTheDayWidget(
                            dealOfTheDay: dealOfTheDay.dealOfTheDay!)
                        .pOnly(bottom: 15)
                    : dealOfTheDay is DealOfTheDayStateErrorState
                        ? const SizedBox()
                        : const ProductLoadingWidget(),

                /// Recently Added (Latest Item)
                latestItemState is LatestItemLoadedState
                    ? ProductCard(
                            title: LocaleKeys.recently_added.tr(),
                            productList: latestItemState.latestItemList)
                        .pOnly(bottom: 15)
                    : latestItemState is LatestItemErrorState
                        ? ErrorMessageWidget(latestItemState.message)
                        : const ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? bannerState.bannerList == null
                        ? const SizedBox()
                        : bannerState.bannerList!.length <= 5
                            ? const SizedBox()
                            : BannerWidget(bannerState.bannerList!.sublist(
                                5,
                                bannerState.bannerList!.length <= 7
                                    ? bannerState.bannerList!.length
                                    : 7))
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : const SizedBox(),

                /// Popular Items
                popularItemState is PopularItemLoadedState
                    ? ProductCard(
                            title: LocaleKeys.popular_items.tr(),
                            productList: popularItemState.popularItemList)
                        .py(15)
                    : popularItemState is PopularItemErrorState
                        ? ErrorMessageWidget(popularItemState.message)
                        : const ProductLoadingWidget(),

                /// Banner
                bannerState is BannerLoadedState
                    ? bannerState.bannerList == null
                        ? const SizedBox()
                        : bannerState.bannerList!.length <= 7
                            ? const SizedBox()
                            : BannerWidget(
                                bannerState.bannerList!.sublist(7),
                                isReverse: false,
                              )
                    : bannerState is BannerErrorState
                        ? ErrorMessageWidget(bannerState.message)
                        : const SizedBox(),

                /// Random Items (Additional Items to Explore in the UI)
                randomItemState is RandomItemLoadedState
                    ? ProductDetailsCardGridView(
                            isTitleCentered: true,
                            title: LocaleKeys.additional_items.tr(),
                            productList: randomItemState.randomItemList)
                        .py(20)
                    : randomItemState is RandomItemErrorState
                        ? ErrorMessageWidget(randomItemState.message)
                        : const ProductLoadingWidget(),
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
        context.nextPage(
            ProductDetailsScreen(productSlug: dealOfTheDay.data!.slug!));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocaleKeys.deal_of_the_day.tr(),
                  style: context.textTheme.headline6!
                      .copyWith(color: kPrimaryFadeTextColor))
              .pOnly(bottom: 10),
          Flexible(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kDarkColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 300,
                        child: CarouselSlider(
                            options: CarouselOptions(
                              scrollDirection: Axis.horizontal,
                              viewportFraction: 1,
                              autoPlay: true,
                            ),
                            items: dealOfTheDay.data!.images!
                                .map((item) => CachedNetworkImage(
                                      imageUrl: item.path!,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                      progressIndicatorBuilder:
                                          (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                            value: progress.progress),
                                      ),
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
                            .sublist(
                                0,
                                dealOfTheDay.data!.keyFeatures!.length > 3
                                    ? 3
                                    : dealOfTheDay.data!.keyFeatures!.length)
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
                              context.nextPage(ProductDetailsScreen(
                                  productSlug: dealOfTheDay.data!.slug!));
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
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  color: kDarkPriceColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  LocaleKeys.add_to_wishlist.tr(),
                                  style: const TextStyle(
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
                    padding: const EdgeInsets.only(top: 8, right: 6),
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
                        transform: Matrix4.identity()..rotateZ(45 * pi / 180),
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
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _cartState = watch(cartNotifierProvider);
    final _packageInfoProvider = watch(packageInfoProvider);
    int _cartItems = 0;

    if (_cartState is CartLoadedState) {
      for (var item in _cartState.cartList!) {
        _cartItems += item.items!.length;
      }
    }
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Image.asset(
                  AppImages.topBar,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shrinkWrap: true,
              children: [
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.home_text.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.home_outlined),
                    onTap: () {
                      context.pop();
                    },
                  ),
                ),
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.vendor_text.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.store_outlined),
                    onTap: () {
                      context.pop();
                      context.nextAndRemoveUntilPage(
                          const BottomNavBar(selectedIndex: 1));
                    },
                  ),
                ),
                //Brands
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.brands.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.local_mall_outlined),
                    onTap: () {
                      context.pop();
                      context.nextAndRemoveUntilPage(
                          const BottomNavBar(selectedIndex: 2));
                    },
                  ),
                ),
                //WishList
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.wishlist_text.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.favorite_border_outlined),
                    onTap: () {
                      context.pop();
                      context.nextAndRemoveUntilPage(
                          const BottomNavBar(selectedIndex: 3));
                    },
                  ),
                ),
                //Cart
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.cart_text.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.shopping_cart_outlined),
                    trailing: CircleAvatar(
                      radius: 10,
                      backgroundColor: kPrimaryColor,
                      foregroundColor: kLightColor,
                      child: Text(
                        _cartItems.toString(),
                        style: context.textTheme.caption!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kLightColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      context.pop();
                      context.nextAndRemoveUntilPage(
                          const BottomNavBar(selectedIndex: 4));
                    },
                  ),
                ),
                //Account
                Card(
                  elevation: 0,
                  child: ListTile(
                    title: Text(LocaleKeys.account_text.tr(),
                        style: context.textTheme.subtitle2!),
                    leading: const Icon(Icons.person_outline),
                    onTap: () {
                      context.pop();
                      context.nextAndRemoveUntilPage(
                          const BottomNavBar(selectedIndex: 5));
                    },
                  ),
                ),
                const Divider(),
                const NotLoggedInSettingItems(),
              ],
            ),
          ),
          _packageInfoProvider.when(
            data: (data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text("v" + data.version + "+" + data.buildNumber,
                    style: context.textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold, color: kFadeColor)),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class FeaturedCategoriesSection extends ConsumerWidget {
  const FeaturedCategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    // final _categoriesProvider = watch(featuredCategoriesProvider);
    final _categoryState = watch(categoryNotifierProvider);

    return (_categoryState is CategoryInitialState ||
            _categoryState is CategoryLoadingState)
        ? const SizedBox()
        : _categoryState is CategoryLoadedState
            ? _categoryState.categoryList.isEmpty
                ? const SizedBox()
                : CategoryWidget(_categoryState.categoryList).py(5)
            : _categoryState is CategoryErrorState
                ? ErrorMessageWidget(_categoryState.message)
                : const SizedBox();

    //   return _categoriesProvider.when(
    //       data: (model) {
    //         return model == null || model.data == null || model.data!.isEmpty
    //             ? (_categoryState is CategoryInitialState ||
    //                     _categoryState is CategoryLoadingState)
    //                 ? const SizedBox()
    //                 : _categoryState is CategoryLoadedState
    //                     ? _categoryState.categoryList.isEmpty
    //                         ? const SizedBox()
    //                         : CategoryWidget(_categoryState.categoryList).py(5)
    //                     : _categoryState is CategoryErrorState
    //                         ? ErrorMessageWidget(_categoryState.message)
    //                         : const SizedBox()
    //             : SizedBox(
    //                 height: 190,
    //                 child: Center(
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.stretch,
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Text(
    //                             LocaleKeys.categories.tr(),
    //                             style: context.textTheme.bodyMedium!.copyWith(
    //                                 fontWeight: FontWeight.bold,
    //                                 color: kFadeColor),
    //                           ),
    //                           GestureDetector(
    //                             onTap: () {
    //                               context.nextPage(const CategoriesPage());
    //                             },
    //                             child: Text(
    //                               LocaleKeys.view_all.tr(),
    //                               style: context.textTheme.subtitle2!.copyWith(
    //                                   fontWeight: FontWeight.bold,
    //                                   color: kFadeColor),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       const SizedBox(height: 4),
    //                       SizedBox(
    //                         height: 148,
    //                         child: ListView(
    //                           padding: const EdgeInsets.symmetric(vertical: 8),
    //                           scrollDirection: Axis.horizontal,
    //                           shrinkWrap: true,
    //                           children: model.data!.map(
    //                             (category) {
    //                               return GestureDetector(
    //                                 onTap: () {
    //                                   context.nextPage(CategoryProductsList(
    //                                       categoryName: category.name ??
    //                                           LocaleKeys.unknown.tr()));

    //                                   context
    //                                       .read(productListNotifierProvider
    //                                           .notifier)
    //                                       .getProductList(
    //                                           'category/${category.slug}');
    //                                 },
    //                                 child: Container(
    //                                   margin: const EdgeInsets.only(right: 16),
    //                                   width: 100,
    //                                   child: Column(
    //                                     mainAxisSize: MainAxisSize.min,
    //                                     children: [
    //                                       category.featureImage != null
    //                                           ? ClipRRect(
    //                                               borderRadius:
    //                                                   BorderRadius.circular(8),
    //                                               child: CachedNetworkImage(
    //                                                 imageUrl:
    //                                                     category.featureImage!,
    //                                                 fit: BoxFit.contain,
    //                                                 errorWidget: (_, __, ___) =>
    //                                                     Container(
    //                                                   decoration: BoxDecoration(
    //                                                     borderRadius:
    //                                                         BorderRadius.circular(
    //                                                             8),
    //                                                     color: kFadeColor
    //                                                         .withOpacity(0.3),
    //                                                   ),
    //                                                   height: 100,
    //                                                   child: const Center(
    //                                                       child:
    //                                                           Icon(Icons.image)),
    //                                                 ),
    //                                                 placeholder: (_, __) =>
    //                                                     Container(
    //                                                   decoration: BoxDecoration(
    //                                                     borderRadius:
    //                                                         BorderRadius.circular(
    //                                                             8),
    //                                                     color: kFadeColor
    //                                                         .withOpacity(0.3),
    //                                                   ),
    //                                                   height: 100,
    //                                                   child: const Center(
    //                                                       child: LoadingWidget()),
    //                                                 ),
    //                                               ),
    //                                             )
    //                                           : Container(
    //                                               decoration: BoxDecoration(
    //                                                 borderRadius:
    //                                                     BorderRadius.circular(8),
    //                                                 color: kFadeColor
    //                                                     .withOpacity(0.3),
    //                                               ),
    //                                               height: 100,
    //                                               child: const Center(
    //                                                   child: Icon(Icons.image)),
    //                                             ),
    //                                       const SizedBox(height: 4),
    //                                       Text(
    //                                         category.name ?? "",
    //                                         textAlign: TextAlign.center,
    //                                         overflow: TextOverflow.ellipsis,
    //                                         maxLines: 2,
    //                                         style: context.textTheme.caption!
    //                                             .copyWith(
    //                                           fontWeight: FontWeight.bold,
    //                                           color: kFadeColor,
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               );
    //                             },
    //                           ).toList(),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               );
    //       },
    //       loading: () => const SizedBox(),
    //       error: (_, __) => const SizedBox());
    // }
  }
}

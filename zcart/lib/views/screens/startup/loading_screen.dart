import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/controller/blog/blog_controller.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/providers/deals_provider.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();

    goToNextScreen();
  }

  goToNextScreen() async {
    var responseBody = await handleResponse(
        await getRequest(API.orders, bearerToken: true),
        showToast: false);
    if (responseBody.runtimeType == int && responseBody == 401) {
      await clearSharedPref();
    }
    accessAllowed = getBoolAsync(loggedIn, defaultValue: false);
    initialData();
    Future.delayed(const Duration(milliseconds: 300),
        () => context.nextReplacementPage(const BottomNavBar()));
  }

  initialData() async {
    context.read(categoryNotifierProvider.notifier).getCategory();
    context.read(bannerNotifierProvider.notifier).getBanner();
    context.read(sliderNotifierProvider.notifier).getSlider();
    context.read(trendingNowNotifierProvider.notifier).getTrendingNowItems();
    context.read(latestItemNotifierProvider.notifier).getLatestItem();
    context.read(popularItemNotifierProvider.notifier).getLatestItem();
    context.read(randomItemNotifierProvider.notifier).getRandomItems();
    context.read(vendorsNotifierProvider.notifier).getVendors();
    context.read(allBrandsNotifierProvider.notifier).getAllBrands();
    context.read(blogsProvider.notifier).blogs();
    context
        .read(dealsUnderThePriceNotifierProvider.notifier)
        .getAllDealsUnderThePrice();
    context.read(dealOfThedayNotifierProvider.notifier).getDealOfTheDay();
    context.read(featuredBrandsNotifierProvider.notifier).getFeaturedBrands();
    context.read(cartNotifierProvider.notifier).getCartList();
    context.read(countryNotifierProvider.notifier).getCountries();
    getRecentlyViewedItems(context: context);

    if (accessAllowed) {
      context.read(ordersProvider.notifier).orders();
      context.read(userNotifierProvider.notifier).getUserInfo();
      context.read(wishListNotifierProvider.notifier).getWishList();
      context.read(disputesProvider.notifier).getDisputes();
      context.read(couponsProvider.notifier).coupons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: LoadingWidget(),
    ));
  }
}

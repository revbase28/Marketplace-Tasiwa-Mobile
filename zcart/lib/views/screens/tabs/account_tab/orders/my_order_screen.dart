import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/models/orders/orders_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/order_state.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/open_dispute_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/order_chat_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/orders/order_details_screen.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_details.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/custom_small_button.dart';

class MyOrderScreen extends ConsumerWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _ordersState = watch(ordersProvider);
    final _scrollControllerProvider =
        watch(orderScrollNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.orders.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: kLightColor),
            onPressed: () {
              context.read(ordersProvider.notifier).orders();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _ordersState is OrdersLoadedState
            ? _ordersState.orders!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline),
                        Text(LocaleKeys.no_item_found.tr()),
                        TextButton(
                            onPressed: () {
                              context.nextReplacementPage(
                                  const BottomNavBar(selectedIndex: 0));
                            },
                            child: Text(LocaleKeys.go_shopping.tr())),
                      ],
                    ),
                  )
                : ProviderListener<ScrollState>(
                    onChange: (context, state) {
                      if (state is ScrollReachedBottomState) {
                        context
                            .read(ordersProvider.notifier)
                            .moreOrders(ignoreLoadingState: true);
                      }
                    },
                    provider: orderScrollNotifierProvider,
                    child: ListView(
                      controller: _scrollControllerProvider.controller,
                      children: _ordersState.orders != null
                          ? _ordersState.orders!
                              .map((e) => OrderCard(
                                  order: e,
                                  index: _ordersState.orders!.indexOf(e)))
                              .toList()
                          : [],
                    ),
                  )
            : _ordersState is OrdersErrorState
                ? ErrorMessageWidget(_ordersState.message)
                : const OrdersLoadingWidget(),
      ),
    );
  }
}

class OrdersLoadingWidget extends StatelessWidget {
  const OrdersLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Shimmer.fromColors(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              baseColor:
                  getColorBasedOnTheme(context, Colors.grey[200]!, kDarkColor),
              highlightColor: getColorBasedOnTheme(
                  context, Colors.grey[100]!, kDarkCardBgColor),
            ),
          ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final Orders order;
  final int index;

  const OrderCard({
    Key? key,
    required this.order,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  context
                      .read(vendorDetailsNotifierProvider.notifier)
                      .getVendorDetails(order.shop!.slug);
                  context
                      .read(vendorItemsNotifierProvider.notifier)
                      .getVendorItems(order.shop!.slug);
                  context.nextPage(const VendorsDetailsScreen());
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        imageUrl: order.shop!.image!,
                        errorWidget: (context, url, error) => const SizedBox(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                          child: CircularProgressIndicator(
                              value: progress.progress),
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.shop!.name ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RatingBar.builder(
                                initialRating:
                                    double.parse(order.shop!.rating ?? '0.0'),
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                ignoreGestures: true,
                                itemSize: 12,
                                itemPadding: const EdgeInsets.only(right: 1),
                                itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: kDarkPriceColor),
                                onRatingUpdate: (rating) =>
                                    debugPrint(rating.toString()),
                              ).pOnly(top: 5),
                              Container(
                                margin: const EdgeInsets.only(left: 10, top: 5),
                                decoration: BoxDecoration(
                                    color: order.orderStatus != "DELIVERED"
                                        ? kPrimaryColor
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(order.orderStatus!,
                                    style: context.textTheme.overline!.copyWith(
                                        color: kPrimaryLightTextColor)),
                              ),
                            ],
                          )
                        ],
                      ).pOnly(left: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                    itemCount: order.items!.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, itemsIndex) {
                      return CachedNetworkImage(
                        imageUrl: order.items![itemsIndex].image!,
                        errorWidget: (context, url, error) => const SizedBox(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                          child: CircularProgressIndicator(
                              value: progress.progress),
                        ),
                        height: 50,
                        width: 50,
                      ).p(10).onInkTap(() {
                        context.nextPage(ProductDetailsScreen(
                            productSlug: order.items![itemsIndex].slug!));
                      });
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${LocaleKeys.order_number.tr()} : ${order.orderNumber}",
                          style: context.textTheme.caption!),
                      Text("${LocaleKeys.ordered_at.tr()} : ${order.orderDate}",
                          style: context.textTheme.caption!),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(order.grandTotal!,
                          style: context.textTheme.bodyText2!.copyWith(
                              color: getColorBasedOnTheme(
                                  context, kPriceColor, kDarkPriceColor),
                              fontWeight: FontWeight.bold)),
                      Text(LocaleKeys.total.tr(),
                          style: context.textTheme.overline)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  CustomSmallButton(
                    text: LocaleKeys.order_details.tr(),
                    onPressed: () {
                      context
                          .read(orderProvider.notifier)
                          .getOrderDetails(order.id);
                      context.nextPage(const OrderDetailsScreen());
                    },
                  ),
                  CustomSmallButton(
                    text: LocaleKeys.contact_seller.tr(),
                    onPressed: () {
                      context
                          .read(orderChatProvider.notifier)
                          .orderConversation(order.id);
                      context.nextPage(OrderChatScreen(orders: order));
                    },
                  ),
                  if (order.disputeId == null)
                    CustomSmallButton(
                      text: LocaleKeys.open_a_dispute.tr(),
                      onPressed: () {
                        context
                            .read(disputeInfoProvider.notifier)
                            .getDisputeInfo(order.id);
                        context.nextPage(const OpenDisputeScreen());
                      },
                    ),
                  if (order.orderStatus != "DELIVERED")
                    CustomSmallButton(
                      text: LocaleKeys.confirm_received.tr(),
                      onPressed: () {
                        if (order.orderStatus != "DELIVERED") {
                          showCustomConfirmDialog(
                            context,
                            dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                            dialogType: DialogType.ACCEPT,
                            title: LocaleKeys.received_product.tr(),
                            subTitle: LocaleKeys.are_you_sure.tr(),
                            primaryColor: kPrimaryColor,
                            positiveText: LocaleKeys.yes.tr(),
                            onAccept: () {
                              context
                                  .read(orderReceivedProvider.notifier)
                                  .orderReceived(order.id)
                                  .then((value) => context
                                      .read(ordersProvider.notifier)
                                      .orders(ignoreLoadingState: true));
                            },
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(50),
              ),
              color: kPrimaryColor,
            ),
            width: 35,
            height: 35,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 10),
              child: Text(
                "${index + 1}",
                style: context.textTheme.overline!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kLightColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

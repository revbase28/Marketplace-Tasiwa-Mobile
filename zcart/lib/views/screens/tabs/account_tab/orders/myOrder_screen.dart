import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/order_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/order_state.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/open_dispute_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/order_chat_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/orders/order_details_screen.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/shared_widgets/customConfirmDialog.dart';

class MyOrderScreen extends ConsumerWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ordersState = watch(ordersProvider);
    final scrollControllerProvider =
        watch(orderScrollNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.orders.tr()),
      ),
      body: SafeArea(
        child: ordersState is OrdersLoadedState
            ? ordersState.orders!.isEmpty
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
                    child: ListView.builder(
                        controller: scrollControllerProvider.controller,
                        itemCount: ordersState.orders!.length,
                        itemBuilder: (context, orderIndex) {
                          return OrderCard(
                              orderListState: ordersState,
                              orderIndex: orderIndex);
                        }),
                  )
            : ordersState is OrdersErrorState
                ? ErrorMessageWidget(ordersState.message)
                : const SizedBox(),
      ),
    );
  }
}

/* WIDGET */
class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.orderListState, this.orderIndex})
      : super(key: key);

  final OrdersLoadedState orderListState;
  final int? orderIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.network(
                        orderListState.orders![orderIndex!].shop!.image!,
                        errorBuilder:
                            (BuildContext _, Object error, StackTrace? stack) {
                          return const SizedBox();
                        },
                        fit: BoxFit.contain,
                      ).pOnly(left: 10),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        orderListState.orders![orderIndex!].shop!.name == null
                            ? const Text("")
                            : Text(
                                orderListState.orders![orderIndex!].shop!.name!,
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
                              initialRating: double.parse(orderListState
                                      .orders![orderIndex!].shop!.rating ??
                                  '0.0'),
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              itemSize: 12,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) => print(rating),
                            ).pOnly(top: 5),
                            Container(
                              margin: const EdgeInsets.only(left: 10, top: 5),
                              decoration: BoxDecoration(
                                  color: orderListState.orders![orderIndex!]
                                              .orderStatus !=
                                          "DELIVERED"
                                      ? kPrimaryColor
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                  orderListState
                                      .orders![orderIndex!].orderStatus!,
                                  style: context.textTheme.overline!
                                      .copyWith(color: kPrimaryLightTextColor)),
                            ),
                          ],
                        )
                      ],
                    ).pOnly(left: 10),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                    itemCount:
                        orderListState.orders![orderIndex!].items!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, itemsIndex) {
                      return Image.network(
                        orderListState
                            .orders![orderIndex!].items![itemsIndex].image!,
                        errorBuilder:
                            (BuildContext _, Object error, StackTrace? stack) {
                          return const SizedBox();
                        },
                        height: 50,
                        width: 50,
                      ).p(10).onInkTap(() {
                        context
                            .read(productNotifierProvider.notifier)
                            .getProductDetails(orderListState
                                .orders![orderIndex!].items![itemsIndex].slug)
                            .then((value) {
                          getRecentlyViewedItems(context);
                        });
                        context
                            .read(productSlugListProvider.notifier)
                            .addProductSlug(orderListState
                                .orders![orderIndex!].items![itemsIndex].slug);
                        context.nextPage(const ProductDetailsScreen());
                      });
                    }),
              ),
              Text(
                "${LocaleKeys.order_number.tr()} : ${orderListState.orders![orderIndex!].orderNumber}",
                style: context.textTheme.overline!.copyWith(fontSize: 11),
              ).pOnly(top: 10),
              Text(
                "${LocaleKeys.ordered_at.tr()} : ${orderListState.orders![orderIndex!].orderDate}",
                style: context.textTheme.overline!.copyWith(fontSize: 11),
              ).pOnly(bottom: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Wrap(
                      //runSpacing: 5.0,
                      spacing: 10.0,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            LocaleKeys.contact_seller.tr(),
                            style: const TextStyle(
                                fontSize: 12, color: kLightColor),
                          ),
                        ).onInkTap(() {
                          context
                              .read(orderChatProvider.notifier)
                              .orderConversation(
                                  orderListState.orders![orderIndex!].id);
                          context.nextPage(OrderChatScreen(
                              orders: orderListState.orders![orderIndex!]));
                        }),
                        Container(
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            LocaleKeys.order_details.tr(),
                            style: const TextStyle(
                                fontSize: 12, color: kLightColor),
                          ),
                        ).onInkTap(() {
                          context.read(orderProvider.notifier).getOrderDetails(
                              orderListState.orders![orderIndex!].id);
                          context.nextPage(const OrderDetailsScreen());
                        }),
                        Visibility(
                          visible:
                              orderListState.orders![orderIndex!].disputeId ==
                                  null,
                          child: Container(
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              LocaleKeys.open_a_dispute.tr(),
                              style: const TextStyle(
                                  fontSize: 12, color: kLightColor),
                            ),
                          ).onInkTap(() {
                            context
                                .read(disputeInfoProvider.notifier)
                                .getDisputeInfo(
                                    orderListState.orders![orderIndex!].id);
                            context.nextPage(const OpenDisputeScreen());
                          }),
                        ),
                        Visibility(
                          visible:
                              orderListState.orders![orderIndex!].orderStatus !=
                                  "DELIVERED",
                          child: Container(
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              orderListState.orders![orderIndex!].orderStatus ==
                                      "DELIVERED"
                                  ? ""
                                  : LocaleKeys.confirm_received.tr(),
                              style: const TextStyle(
                                  fontSize: 12, color: kLightColor),
                            ),
                          ).onInkTap(() {
                            if (orderListState
                                    .orders![orderIndex!].orderStatus !=
                                "DELIVERED") {
                              showCustomConfirmDialog(
                                context,
                                dialogAnimation:
                                    DialogAnimation.SLIDE_BOTTOM_TOP,
                                dialogType: DialogType.ACCEPT,
                                title: LocaleKeys.received_product.tr(),
                                subTitle: LocaleKeys.are_you_sure.tr(),
                                positiveText: LocaleKeys.yes.tr(),
                                onAccept: () {
                                  context
                                      .read(orderReceivedProvider.notifier)
                                      .orderReceived(orderListState
                                          .orders![orderIndex!].id)
                                      .then((value) => context
                                          .read(ordersProvider.notifier)
                                          .orders(ignoreLoadingState: true));
                                },
                              );
                            }

                            // if (orderListState.orders[orderIndex].orderStatus ==
                            //     "DELIVERED") if (!orderListState.orders[orderIndex].canEvaluate)
                            //   context.nextPage(FeedbackScreen(
                            //     order: orderListState.orders[orderIndex],
                            //   ));
                            // else
                            //   toast('Feedback already given');
                          }),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(orderListState.orders![orderIndex!].grandTotal!,
                          style: context.textTheme.bodyText2!.copyWith(
                              color: getColorBasedOnTheme(
                                  context, kPriceColor, kDarkPriceColor),
                              fontWeight: FontWeight.bold)),
                      Text(LocaleKeys.total.tr(),
                          style: context.textTheme.overline)
                    ],
                  ).pOnly(left: 20)
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
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
                "${orderIndex! + 1}",
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

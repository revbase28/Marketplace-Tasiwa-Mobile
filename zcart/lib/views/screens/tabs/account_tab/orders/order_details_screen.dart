import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/order_provider.dart';
import 'package:zcart/riverpod/state/order_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/dispute_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/open_dispute_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/orders/feedback_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:zcart/views/shared_widgets/custom_button.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/custom_small_button.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/views/shared_widgets/pdf_screen.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final orderDetailsState = watch(orderProvider);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.order_details.tr()),
        automaticallyImplyLeading: true,
      ),
      body: orderDetailsState is OrderLoadedState
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButton(
                          buttonText:
                              orderDetailsState.orderDetails!.orderStatus,
                          buttonBGColor:
                              orderDetailsState.orderDetails!.orderStatus ==
                                      "DELIVERED"
                                  ? kGreenColor
                                  : kPrimaryColor,
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${LocaleKeys.order_number.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState
                                            .orderDetails!.orderNumber!,
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text("${LocaleKeys.date.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState
                                            .orderDetails!.orderDate!,
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${LocaleKeys.order_status.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState
                                                .orderDetails!.orderStatus ??
                                            LocaleKeys.not_available.tr(),
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${LocaleKeys.shipping_address.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState.orderDetails!
                                                .shippingAddress ??
                                            LocaleKeys.not_available.tr(),
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${LocaleKeys.billing_address.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState
                                                .orderDetails!.billingAddress ??
                                            LocaleKeys.not_available.tr(),
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${LocaleKeys.shipping_weight.tr()}: ")),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        orderDetailsState
                                                .orderDetails!.shippingWeight ??
                                            LocaleKeys.not_available.tr(),
                                        style: context.textTheme.subtitle2)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            orderDetailsState.orderDetails!.messageToCustomer !=
                                    null
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.message_to_customer.tr()}: ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              orderDetailsState.orderDetails!
                                                  .messageToCustomer,
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomShopCard(
                            image: orderDetailsState.orderDetails!.shop!.image,
                            title: orderDetailsState.orderDetails!.shop!.name ??
                                LocaleKeys.unknown.tr(),
                            verifiedText: orderDetailsState
                                    .orderDetails!.shop!.verifiedText ??
                                ""),
                        const Divider(height: 0),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              orderDetailsState.orderDetails!.items!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                context.nextPage(ProductDetailsScreen(
                                    productSlug: orderDetailsState
                                        .orderDetails!.items![index].slug!));
                              },
                              leading: orderDetailsState
                                          .orderDetails!.items![index].image !=
                                      null
                                  ? CachedNetworkImage(
                                      imageUrl: orderDetailsState
                                          .orderDetails!.items![index].image!,
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                      progressIndicatorBuilder:
                                          (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                            value: progress.progress),
                                      ),
                                      width: 50,
                                      height: 50,
                                    )
                                  : null,
                              title: Text(
                                orderDetailsState.orderDetails!.items![index]
                                        .description ??
                                    "",
                                style: context.textTheme.subtitle2!,
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    orderDetailsState.orderDetails!
                                            .items![index].unitPrice ??
                                        "",
                                    style: context.textTheme.subtitle2!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: getColorBasedOnTheme(context,
                                                kPriceColor, kDarkPriceColor)),
                                  ),
                                  Text(
                                    ' x ' +
                                        orderDetailsState.orderDetails!
                                            .items![index].quantity
                                            .toString(),
                                    style: context.textTheme.subtitle2!,
                                  )
                                ],
                              ).py(8),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${LocaleKeys.payment_details.tr()}\n',
                            style: context.textTheme.headline6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.total.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.total ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.taxes.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.taxes ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.shipping.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.shipping ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.packaging.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.packaging ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.handling.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.handling ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text("${LocaleKeys.discount.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState.orderDetails!.discount ??
                                        LocaleKeys.not_available.tr(),
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "${LocaleKeys.payment_method.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState
                                        .orderDetails!.paymentMethod!.name!,
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    "${LocaleKeys.payment_status.tr()}: ")),
                            Expanded(
                                flex: 3,
                                child: Text(
                                    orderDetailsState
                                        .orderDetails!.paymentStatus!,
                                    style: context.textTheme.subtitle2)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 2,
                                child:
                                    Text("${LocaleKeys.grand_total.tr()}: ")),
                            Expanded(
                              flex: 3,
                              child: Text(
                                orderDetailsState.orderDetails!.grandTotal!,
                                style: context.textTheme.headline6!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: getColorBasedOnTheme(
                                      context, kPriceColor, kDarkPriceColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _orderDetailsFooter(context, orderDetailsState),
                ],
              ),
            )
          : const LoadingWidget(),
    );
  }

  Widget _orderDetailsFooter(
      BuildContext context, OrderLoadedState orderDetailsState) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          CustomSmallButton(
            text: LocaleKeys.generate_invoice.tr(),
            onPressed: () async {
              toast(LocaleKeys.generating_invoice.tr());
              final _result = await generateInvoice(
                  API.downloadOrderInvoice(orderDetailsState.orderDetails!.id!),
                  orderDetailsState.orderDetails!.orderNumber!);

              if (_result != null) {
                toast(LocaleKeys.invoice_generated.tr());
                context.nextPage(PDFScreen(path: _result));
              } else {
                toast(LocaleKeys.error_generating_invoice.tr());
              }
            },
          ),
          if (orderDetailsState.orderDetails!.orderStatus == "DELIVERED")
            CustomSmallButton(
              text: LocaleKeys.feedback.tr(),
              onPressed: () {
                if (orderDetailsState.orderDetails!.canEvaluate ?? false) {
                  context.nextPage(
                      FeedbackScreen(order: orderDetailsState.orderDetails!));
                } else {
                  toast(LocaleKeys.feedback_already_given.tr());
                }
              },
            ),
          if (orderDetailsState.orderDetails!.disputeId == null)
            CustomSmallButton(
              text: LocaleKeys.open_dispute.tr(),
              onPressed: () {
                context
                    .read(disputeInfoProvider.notifier)
                    .getDisputeInfo(orderDetailsState.orderDetails!.id);
                context.nextPage(const OpenDisputeScreen());
              },
            ),
          if (orderDetailsState.orderDetails!.disputeId != null)
            CustomSmallButton(
              text: LocaleKeys.dispute_details.tr(),
              onPressed: () {
                context.read(disputeDetailsProvider.notifier).getDisputeDetails(
                    orderDetailsState.orderDetails!.disputeId);
                context.nextPage(const DisputeDetailsScreen());
              },
            ),
          if (orderDetailsState.orderDetails!.orderStatus == "DELIVERED"
              ? false
              : true)
            CustomSmallButton(
              text: LocaleKeys.confirm_received.tr(),
              onPressed: () {
                if (orderDetailsState.orderDetails!.orderStatus !=
                    "DELIVERED") {
                  showCustomConfirmDialog(
                    context,
                    dialogType: DialogType.ACCEPT,
                    dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                    title: LocaleKeys.received_product.tr(),
                    subTitle: LocaleKeys.are_you_sure.tr(),
                    primaryColor: kPrimaryColor,
                    positiveText: LocaleKeys.yes.tr(),
                    onAccept: () {
                      context
                          .read(orderReceivedProvider.notifier)
                          .orderReceived(orderDetailsState.orderDetails!.id)
                          .then((value) => context
                              .read(ordersProvider.notifier)
                              .orders(ignoreLoadingState: true))
                          .then((value) => context.pop());
                    },
                  );
                }
              },
            )
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/models/dispute/disputes_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/dispute/disputes_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/dispute_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/custom_small_button.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';

class DisputeScreen extends ConsumerWidget {
  const DisputeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final disputesState = watch(disputesProvider);
    final _scrollControllerProvider =
        watch(disputesScrollNotifierProvider.notifier);
    return ProviderListener<ScrollState>(
      provider: disputesScrollNotifierProvider,
      onChange: (context, state) {
        if (state is ScrollReachedBottomState) {
          context.read(disputesProvider.notifier).getMoreDisputes();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(LocaleKeys.disputes.tr()),
          actions: [
            Visibility(
              visible: disputesState is DisputesErrorState,
              child: IconButton(
                onPressed: () {
                  context.read(disputesProvider.notifier).getDisputes();
                },
                icon: const Icon(
                  Icons.sync,
                  color: kLightColor,
                ),
              ),
            )
          ],
        ),
        body: disputesState is DisputesLoadingState
            ? const LoadingWidget().center()
            : disputesState is DisputesErrorState
                ? Center(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dangerous).paddingRight(5),
                      Text(disputesState.message),
                    ],
                  ))
                : disputesState is DisputesLoadedState
                    ? disputesState.disputes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline),
                                Text(LocaleKeys.no_item_found.tr()),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollControllerProvider.controller,
                            padding: const EdgeInsets.all(16),
                            itemCount: disputesState.disputes.length,
                            itemBuilder: (context, index) {
                              final _dispute = disputesState.disputes[index];
                              return Column(
                                children: [
                                  DisputeCard(dispute: _dispute),
                                  const SizedBox(height: 16),
                                ],
                              );
                            })
                    : const LoadingWidget().center(),
      ),
    );
  }
}

class DisputeCard extends StatelessWidget {
  final Disputes dispute;
  const DisputeCard({
    Key? key,
    required this.dispute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomShopCard(
                    image: dispute.shop!.image,
                    title: dispute.shop!.name ?? LocaleKeys.unknown.tr(),
                    verifiedText: dispute.shop!.verifiedText ?? ""),
              ),
              Container(
                decoration: BoxDecoration(
                    color: dispute.status == 'SOLVED'
                        ? kGreenColor
                        : kPrimaryColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(dispute.status!,
                    style: context.textTheme.overline!
                        .copyWith(color: kPrimaryLightTextColor)),
              )
            ],
          ),
          const Divider(height: 0),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dispute.orderDetails!.items!.length,
            itemBuilder: (context, itemsIndex) {
              final _item = dispute.orderDetails!.items![itemsIndex];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: _item.image!,
                    height: 50,
                    width: 50,
                    errorWidget: (context, url, error) => const SizedBox(),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child:
                          CircularProgressIndicator(value: progress.progress),
                    ),
                  ).pOnly(right: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _item.description!,
                          softWrap: true,
                          style: context.textTheme.subtitle2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_item.total!,
                                style: context.textTheme.subtitle2!.copyWith(
                                  color: getColorBasedOnTheme(
                                      context, kPriceColor, kDarkPriceColor),
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              " x ${_item.quantity}",
                              style: context.textTheme.subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ).py(4);
            },
          ),
          const Divider(height: 0),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("${LocaleKeys.total.tr()} : ",
                    style: context.textTheme.subtitle2!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(
                  dispute.orderDetails!.grandTotal ?? "",
                  textAlign: TextAlign.end,
                  style: context.textTheme.headline6!.copyWith(
                      color: getColorBasedOnTheme(
                          context, kPriceColor, kDarkPriceColor),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                CustomSmallButton(
                  text: LocaleKeys.dispute_details.tr(),
                  onPressed: () {
                    context
                        .read(disputeDetailsProvider.notifier)
                        .getDisputeDetails(dispute.id);
                    context.nextPage(const DisputeDetailsScreen());
                  },
                ),
                CustomSmallButton(
                  text: LocaleKeys.contact_seller.tr(),
                  onPressed: () {
                    context.nextPage(VendorChatScreen(
                        shopId: dispute.shop!.id,
                        shopImage: dispute.shop!.image,
                        shopName: dispute.shop!.name,
                        shopVerifiedText: dispute.shop!.verifiedText));

                    context
                        .read(productChatProvider.notifier)
                        .productConversation(dispute.shop!.id);
                  },
                ),
                if (!dispute.closed!)
                  CustomSmallButton(
                    text: LocaleKeys.mark_as_solved.tr(),
                    onPressed: () {
                      showCustomConfirmDialog(
                        context,
                        dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                        title: LocaleKeys.close_dispute.tr(),
                        subTitle: LocaleKeys.are_you_sure.tr(),
                        primaryColor: kPrimaryColor,
                        onAccept: () {
                          context
                              .read(disputesProvider.notifier)
                              .markAsSolved(dispute.id);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

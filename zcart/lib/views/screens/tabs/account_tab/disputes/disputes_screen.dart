import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/dispute/disputes_state.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/dispute_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/shared_widgets/customConfirmDialog.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';

class DisputeScreen extends ConsumerWidget {
  const DisputeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final disputesState = watch(disputesProvider);
    final scrollControllerProvider =
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
                  Icons.refresh,
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
                // ? ListTile(
                //     title: Text(disputesState.message,
                //         style: TextStyle(color: kPrimaryLightTextColor)),
                //     leading: Icon(Icons.dangerous),
                //     contentPadding: EdgeInsets.zero,
                //     horizontalTitleGap: 0,
                //   ).px(10)
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
                            controller: scrollControllerProvider.controller,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: disputesState.disputes.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: getColorBasedOnTheme(
                                        context, kLightColor, kDarkCardBgColor),
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                disputesState.disputes[index]
                                                    .shop!.name!,
                                                style: context
                                                    .textTheme.bodyText2),
                                            Text(
                                                disputesState
                                                    .disputes[index].updatedAt!,
                                                style: context
                                                    .textTheme.overline!),
                                          ],
                                        ).pOnly(bottom: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: disputesState
                                                          .disputes[index]
                                                          .status ==
                                                      'SOLVED'
                                                  ? kGreenColor
                                                  : kPrimaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                              disputesState
                                                  .disputes[index].status!,
                                              style: context.textTheme.overline!
                                                  .copyWith(
                                                      color:
                                                          kPrimaryLightTextColor)),
                                        )
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: disputesState.disputes[index]
                                          .orderDetails!.items!.length,
                                      itemBuilder: (context, itemsIndex) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              disputesState
                                                  .disputes[index]
                                                  .orderDetails!
                                                  .items![itemsIndex]
                                                  .image!,
                                              height: 50,
                                              width: 50,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stack) {
                                                return const SizedBox();
                                              },
                                            ).pOnly(right: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                            disputesState
                                                                .disputes[index]
                                                                .orderDetails!
                                                                .items![
                                                                    itemsIndex]
                                                                .description!,
                                                            maxLines: null,
                                                            softWrap: true,
                                                            style: context
                                                                .textTheme
                                                                .bodyText2!
                                                                .copyWith(
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                    ],
                                                  ).pOnly(bottom: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          disputesState
                                                              .disputes[index]
                                                              .orderDetails!
                                                              .items![
                                                                  itemsIndex]
                                                              .total!,
                                                          style: context
                                                              .textTheme
                                                              .bodyText2!
                                                              .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          )),
                                                      Text(
                                                          " * ${disputesState.disputes[index].orderDetails!.items![itemsIndex].quantity}",
                                                          style: context
                                                              .textTheme
                                                              .bodyText2!
                                                              .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ).py(5);
                                      },
                                    ).pOnly(bottom: 10),
                                    Text(
                                      "${LocaleKeys.total.tr()} : ${disputesState.disputes[index].orderDetails!.grandTotal}"
                                          .toUpperCase(),
                                      textAlign: TextAlign.end,
                                      style: context.textTheme.bodyText2!
                                          .copyWith(
                                              color: getColorBasedOnTheme(
                                                  context,
                                                  kPriceColor,
                                                  kDarkPriceColor),
                                              fontWeight: FontWeight.bold),
                                    ).pOnly(bottom: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Wrap(
                                            spacing: 5.0,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: kPrimaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Text(
                                                    LocaleKeys.contact_seller
                                                        .tr(),
                                                    style: context
                                                        .textTheme.overline!
                                                        .copyWith(
                                                            color:
                                                                kPrimaryLightTextColor)),
                                              ).onInkTap(() async {
                                                context.nextPage(
                                                    VendorChatScreen(
                                                        shopId: disputesState
                                                            .disputes[index]
                                                            .shop!
                                                            .id,
                                                        shopImage: disputesState
                                                            .disputes[index]
                                                            .shop!
                                                            .image,
                                                        shopName: disputesState
                                                            .disputes[index]
                                                            .shop!
                                                            .name,
                                                        shopVerifiedText:
                                                            disputesState
                                                                .disputes[index]
                                                                .shop!
                                                                .verifiedText));

                                                await context
                                                    .read(productChatProvider
                                                        .notifier)
                                                    .productConversation(
                                                        disputesState
                                                            .disputes[index]
                                                            .shop!
                                                            .id);
                                              }),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: kPrimaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Text(
                                                    LocaleKeys.dispute_details
                                                        .tr(),
                                                    style: context
                                                        .textTheme.overline!
                                                        .copyWith(
                                                            color:
                                                                kPrimaryLightTextColor)),
                                              ).onInkTap(() {
                                                context
                                                    .read(disputeDetailsProvider
                                                        .notifier)
                                                    .getDisputeDetails(
                                                        disputesState
                                                            .disputes[index]
                                                            .id);
                                                context.nextPage(
                                                    const DisputeDetailsScreen());
                                              }),
                                              Visibility(
                                                visible: !disputesState
                                                    .disputes[index].closed!,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Text(
                                                      LocaleKeys.mark_as_solved
                                                          .tr(),
                                                      style: context
                                                          .textTheme.overline!
                                                          .copyWith(
                                                              color:
                                                                  kPrimaryLightTextColor)),
                                                ).onInkTap(() {
                                                  showCustomConfirmDialog(
                                                    context,
                                                    dialogAnimation:
                                                        DialogAnimation
                                                            .SLIDE_BOTTOM_TOP,
                                                    title: LocaleKeys
                                                        .close_dispute
                                                        .tr(),
                                                    subTitle: LocaleKeys
                                                        .are_you_sure
                                                        .tr(),
                                                    onAccept: () {
                                                      context
                                                          .read(disputesProvider
                                                              .notifier)
                                                          .markAsSolved(
                                                              disputesState
                                                                  .disputes[
                                                                      index]
                                                                  .id);
                                                    },
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            })
                    : const LoadingWidget().center(),
      ),
    );
  }
}

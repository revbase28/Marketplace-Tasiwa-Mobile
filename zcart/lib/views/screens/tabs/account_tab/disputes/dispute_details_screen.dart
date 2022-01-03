import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/pick_image_helper.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/state/dispute/dispute_details_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/disputes/dispute_responses.dart';
import 'package:zcart/views/shared_widgets/custom_button.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';

class DisputeDetailsScreen extends ConsumerWidget {
  const DisputeDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final disputeDetailsState = watch(disputeDetailsProvider);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.dispute_details.tr()),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
      ),
      body: disputeDetailsState is DisputeDetailsLoadedState
          ? SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        color: getColorBasedOnTheme(
                            context, kLightColor, kDarkCardBgColor),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CustomButton(
                                  buttonText: disputeDetailsState
                                      .disputeDetails!.status,
                                  buttonBGColor: disputeDetailsState
                                              .disputeDetails!.status ==
                                          "SOLVED"
                                      ? kGreenColor
                                      : kPrimaryColor,
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.reason.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                  .disputeDetails!.reason!,
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.updated_at.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                  .disputeDetails!.updatedAt!,
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.description.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                      .disputeDetails!
                                                      .description ??
                                                  LocaleKeys.not_available.tr(),
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.goods_received.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                          .disputeDetails!
                                                          .goodsReceived ??
                                                      false
                                                  ? LocaleKeys.yes.tr()
                                                  : LocaleKeys.no.tr(),
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.return_goods.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                          .disputeDetails!
                                                          .returnGoods ??
                                                      false
                                                  ? LocaleKeys.yes.tr()
                                                  : LocaleKeys.no.tr(),
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                  const SizedBox(height: 9),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              "${LocaleKeys.refund_amount.tr()} : ")),
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                              disputeDetailsState
                                                      .disputeDetails!
                                                      .refundAmount ??
                                                  LocaleKeys.not_available.tr(),
                                              style:
                                                  context.textTheme.subtitle2)),
                                    ],
                                  ),
                                ],
                              ).pOnly(top: 10),
                              _disputeDetailsButtons(
                                      disputeDetailsState, context)
                                  .pOnly(top: 10),
                            ],
                          ),
                        ),
                      ).cornerRadius(10),
                      Container(
                        color: getColorBasedOnTheme(
                            context, kLightColor, kDarkCardBgColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: disputeDetailsState
                                      .disputeDetails!.shop!.image!,
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
                                Text(
                                  disputeDetailsState
                                      .disputeDetails!.shop!.name!,
                                  style: context.textTheme.headline6!,
                                ),
                                disputeDetailsState
                                        .disputeDetails!.shop!.verified!
                                    ? Icon(Icons.check_circle,
                                            color: kPrimaryColor, size: 15)
                                        .px2()
                                        .pOnly(top: 3)
                                    : const SizedBox()
                              ],
                            ),
                            const Divider(),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: disputeDetailsState.disputeDetails!
                                    .orderDetails!.items!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CachedNetworkImage(
                                      imageUrl: disputeDetailsState
                                          .disputeDetails!
                                          .orderDetails!
                                          .items![index]
                                          .image!,
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                      progressIndicatorBuilder:
                                          (context, url, progress) => Center(
                                        child: CircularProgressIndicator(
                                            value: progress.progress),
                                      ),
                                      width: 50,
                                      height: 50,
                                    ),
                                    title: Text(disputeDetailsState
                                        .disputeDetails!
                                        .orderDetails!
                                        .items![index]
                                        .description!),
                                    subtitle: Text(
                                      disputeDetailsState
                                          .disputeDetails!
                                          .orderDetails!
                                          .items![index]
                                          .unitPrice!,
                                      style: context.textTheme.subtitle2!
                                          .copyWith(
                                              color: getColorBasedOnTheme(
                                                  context,
                                                  kPriceColor,
                                                  kDarkPriceColor)),
                                    ),
                                    trailing: Text('x ' +
                                        disputeDetailsState
                                            .disputeDetails!
                                            .orderDetails!
                                            .items![index]
                                            .quantity
                                            .toString()),
                                  );
                                })
                          ],
                        ),
                      ).cornerRadius(10).py(10),
                    ],
                  )),
            )
          : const LoadingWidget(),
    );
  }

  Row _disputeDetailsButtons(
      DisputeDetailsLoadedState disputeDetailsState, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Wrap(
            //runSpacing: 5.0,
            spacing: 10.0,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  LocaleKeys.responses.tr(),
                  style: const TextStyle(color: kLightColor),
                ),
              ).onInkTap(() {
                debugPrint(
                    disputeDetailsState.disputeDetails!.replies.toString());
                context.nextPage(const DisputeResponseScreen());
              }),
              Container(
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  disputeDetailsState.disputeDetails!.closed!
                      ? LocaleKeys.appeal.tr()
                      : LocaleKeys.mark_as_solved.tr(),
                  style: const TextStyle(color: kLightColor),
                ).onInkTap(() {
                  if (!disputeDetailsState.disputeDetails!.closed!) {
                    showCustomConfirmDialog(
                      context,
                      dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                      title: LocaleKeys.close_dispute.tr(),
                      subTitle: LocaleKeys.are_you_sure.tr(),
                      onAccept: () {
                        context
                            .read(disputesProvider.notifier)
                            .markAsSolved(
                                disputeDetailsState.disputeDetails!.id)
                            .then((value) {
                          context.pop();
                        });
                      },
                    );
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: AppealDialog(
                                disputeId:
                                    disputeDetailsState.disputeDetails!.id!),
                          );
                        });
                  }
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class AppealDialog extends StatefulWidget {
  final int disputeId;
  const AppealDialog({
    Key? key,
    required this.disputeId,
  }) : super(key: key);

  @override
  State<AppealDialog> createState() => _AppealDialogState();
}

class _AppealDialogState extends State<AppealDialog> {
  final _appealTextController = TextEditingController();

  String _attachment = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: getColorBasedOnTheme(
      //     context, kDarkCardBgColor, kLightBgColor),
      decoration: BoxDecoration(
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        borderRadius: BorderRadius.circular(10),
      ),

      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          CustomTextField(
            title: LocaleKeys.appeal.tr(),
            controller: _appealTextController,
            hintText: LocaleKeys.appeal_message.tr(),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          _attachment.isNotEmpty
              ? Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      height: 120,
                      child: Image.memory(base64Decode(_attachment)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          _attachment = "";
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    final _file = await pickImageToBase64();

                    if (_file != null) {
                      _attachment = _file;

                      setState(() {});
                    }
                  },
                  child: Text(LocaleKeys.attach_files.tr())),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    if (_appealTextController.text.isNotEmpty) {
                      context
                          .read(disputeDetailsProvider.notifier)
                          .postDisputeAppeal(
                        widget.disputeId,
                        {
                          'reply': _appealTextController.text.trim(),
                          if (_attachment.isNotEmpty) 'attachment': _attachment,
                        },
                      ).then((value) => context.pop());
                    } else {
                      toast(LocaleKeys.message_cannot_be_empty.tr());
                    }
                  },
                  child: Text(LocaleKeys.send_appeal.tr())),
            ],
          )
        ],
      ),
    );
  }
}

//  {
//                           return AlertDialog(
//                             title: Text("Appeal Dispute"),
//                             content: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//
//                                   },
//                                   child: Container(
//                                     height: 30,
//                                     width: 30,
//                                     decoration: BoxDecoration(
//                                         color: kPrimaryColor,
//                                         borderRadius:
//                                             BorderRadius.circular(30)),
//                                     child: Icon(Icons.image,
//                                         color: kLightColor, size: 20),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 CustomTextField(
//                                   controller: _appealTextController,
//                                   hintText: "Appeal Message",
//                                   color: kCardBgColor,
//                                 ),
//                               ],
//                             ),
//                             actions: [
//                               TextButton(
//                                 child: Text("Send"),
//                                 onPressed: () {
//
//                                 },
//                               )
//                             ],
//                           );
//                         };
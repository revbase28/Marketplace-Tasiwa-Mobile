import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/dispute/dispute_info_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';

class OpenDisputeScreen extends StatefulWidget {
  const OpenDisputeScreen({Key? key}) : super(key: key);

  @override
  _OpenDisputeScreenState createState() => _OpenDisputeScreenState();
}

class _OpenDisputeScreenState extends State<OpenDisputeScreen> {
  bool showItemsDropdownField = false;
  bool selected = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController disputeReasonController = TextEditingController();
  final TextEditingController goodsReceivedConfirmationController =
      TextEditingController();
  final TextEditingController refundAmountController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.open_a_dispute.tr()),
      ),
      body: Consumer(
        builder: (context, watch, _) {
          final disputeInfoState = watch(disputeInfoProvider);

          return disputeInfoState is DisputeInfoLoadedState
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
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
                            Text('${LocaleKeys.order_details.tr()}\n',
                                style: context.textTheme.headline6),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${LocaleKeys.order_number.tr()}: ")),
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                            disputeInfoState
                                                .disputeInfo!.orderNumber!,
                                            style:
                                                context.textTheme.subtitle2)),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${LocaleKeys.order_status.tr()}: ")),
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                            disputeInfoState
                                                .disputeInfo!.orderStatus!,
                                            style:
                                                context.textTheme.subtitle2)),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${LocaleKeys.amount_paid.tr()}: ")),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        disputeInfoState.disputeInfo!.total!,
                                        style: context.textTheme.subtitle2!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: getColorBasedOnTheme(context,
                                              kPriceColor, kDarkPriceColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Open dispute
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: getColorBasedOnTheme(
                              context, kLightColor, kDarkCardBgColor),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${LocaleKeys.open_dispute.tr()}\n',
                                  style: context.textTheme.headline6),
                              CustomDropDownField(
                                title: LocaleKeys.select_dispute_reason.tr(),
                                optionsList: disputeInfoState
                                    .disputeInfo!.disputeType!.values
                                    .toList(),
                                isCallback: true,
                                controller: disputeReasonController,
                                callbackFunction: (int disputeValueIndex) {
                                  context
                                          .read(openDisputeInfoProvider.notifier)
                                          .disputeType =
                                      disputeInfoState
                                          .disputeInfo!.disputeType!.keys
                                          .toList()[disputeValueIndex];
                                },
                                hintText: LocaleKeys.select_dispute_reason.tr(),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return LocaleKeys.field_required.tr();
                                  }
                                  return null;
                                },
                              ),
                              CustomDropDownField(
                                title: LocaleKeys.have_you_received_goods.tr(),
                                optionsList: [
                                  LocaleKeys.no.tr(),
                                  LocaleKeys.yes.tr(),
                                ],
                                hintText:
                                    LocaleKeys.have_you_received_goods.tr(),
                                controller: goodsReceivedConfirmationController,
                                isCallback: true,
                                callbackFunction: (id) {
                                  /* NO - 0, YES - 1*/
                                  setState(() {
                                    showItemsDropdownField = (id == 1);
                                    context
                                        .read(openDisputeInfoProvider.notifier)
                                        .orderReceived = id.toString();
                                    if (!showItemsDropdownField) {
                                      selected = false;
                                    }
                                  });
                                },
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return LocaleKeys.field_required.tr();
                                  }

                                  return null;
                                },
                              ),
                              Visibility(
                                visible: showItemsDropdownField,
                                child: CustomDropDownField(
                                  title: LocaleKeys.select_product.tr(),
                                  optionsList: disputeInfoState
                                      .disputeInfo!.items!.values
                                      .toList(),
                                  controller: productController,
                                  isCallback: true,
                                  callbackFunction: (int productValueIndex) {
                                    context
                                            .read(openDisputeInfoProvider.notifier)
                                            .productId =
                                        disputeInfoState
                                            .disputeInfo!.items!.keys
                                            .toList()[productValueIndex];
                                  },
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return LocaleKeys.field_required.tr();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Visibility(
                                  visible: showItemsDropdownField,
                                  child: ListTile(
                                    dense: true,
                                    minLeadingWidth: 0,
                                    horizontalTitleGap: 5,
                                    contentPadding: EdgeInsets.zero,
                                    leading: selected
                                        ? Icon(
                                            Icons.check_circle,
                                            color: kPrimaryColor,
                                          )
                                        : const Icon(
                                            Icons.radio_button_unchecked),
                                    onTap: () {
                                      setState(() {
                                        selected = !selected;
                                      });
                                      /* NO - 0, YES - 1*/
                                      if (showItemsDropdownField) {
                                        context
                                                .read(openDisputeInfoProvider
                                                    .notifier)
                                                .returnGoods =
                                            selected == true ? '1' : '0';
                                      }
                                    },
                                    title: Text(LocaleKeys.return_goods.tr()),
                                  )),
                              Visibility(
                                  visible: selected,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      LocaleKeys.open_dispute_note.tr(),
                                      style: context.textTheme.subtitle2!
                                          .copyWith(color: kPrimaryColor),
                                    ),
                                  )),
                              CustomTextField(
                                title: LocaleKeys.refund_amount.tr(),
                                hintText: LocaleKeys.refund_amount.tr(),
                                controller: refundAmountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}')),
                                ],
                                validator: (value) {
                                  if (value!.isNotEmpty) {
                                    if (double.parse(value) >
                                        double.parse(disputeInfoState
                                            .disputeInfo!.totalRaw!
                                            .split('\$')
                                            .last)) {
                                      return LocaleKeys.refund_amount_validation
                                          .tr(args: [
                                        "${disputeInfoState.disputeInfo!.totalRaw.toDouble().roundToDouble()}"
                                      ]);
                                    }
                                  } else if (value.isEmpty) {
                                    return LocaleKeys.field_required.tr();
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context
                                      .read(openDisputeInfoProvider.notifier)
                                      .refundAmount = value;
                                },
                              ),
                              CustomTextField(
                                title: LocaleKeys.description.tr(),
                                hintText: LocaleKeys.description.tr(),
                                controller: descriptionController,
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.field_required.tr();
                                  }
                                  context
                                      .read(openDisputeInfoProvider.notifier)
                                      .description = value;
                                  return null;
                                },
                              ),
                              CustomButton(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      toast(LocaleKeys.please_wait.tr());
                                      context
                                          .read(
                                              openDisputeInfoProvider.notifier)
                                          .getOpenDispute(
                                              disputeInfoState.disputeInfo!.id)
                                          .then((value) {
                                        toast(LocaleKeys.dispute_opened.tr());
                                        context
                                            .read(disputesProvider.notifier)
                                            .getDisputes();
                                        context
                                            .read(ordersProvider.notifier)
                                            .orders(ignoreLoadingState: true);
                                        context.pop();
                                      });
                                    }
                                  },
                                  buttonText: LocaleKeys.open_a_dispute.tr()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// How to open a dispute
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
                            Text('${LocaleKeys.how_to_open_dispute.tr()}\n',
                                style: context.textTheme.headline6),
                            Text('${LocaleKeys.first_step.tr()}:',
                                style: context.textTheme.subtitle2),
                            Text(
                              '${LocaleKeys.dispute_first_step.tr()}\n',
                              style: context.textTheme.subtitle2,
                            ),
                            Text('${LocaleKeys.second_step.tr()}:',
                                style: context.textTheme.subtitle2),
                            Text(
                              "${LocaleKeys.dispute_second_step.tr()}\n",
                              style: context.textTheme.subtitle2,
                            ),
                            Text('${LocaleKeys.third_step.tr()}:',
                                style: context.textTheme.subtitle2),
                            Text(
                              LocaleKeys.dispute_third_step.tr(),
                              style: context.textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : const LoadingWidget().center();
        },
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/feedback/feedback_controller.dart';
import 'package:zcart/data/models/orders/order_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/checkout_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  final Order order;

  const FeedbackScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productFormKey = GlobalKey<FormState>();
  final TextEditingController _shopRatingController = TextEditingController();
  final TextEditingController _shopCommentController = TextEditingController();
  final _pageController = PageController();

  List<int?> listingIdList = [];

  List<int> ratingList = [];

  List<String?> feedbackList = [];

  updateListingIdList({required int index, required int listingId}) {
    if (listingIdList.isEmpty) {
      listingIdList.insert(index, listingId);
    } else if (index <= listingIdList.length - 1) {
      listingIdList[index] = listingId;
    } else {
      listingIdList.insert(index, listingId);
    }
  }

  void _updateRatingList({required int index, required double rating}) {
    updateListingIdList(
        index: index, listingId: widget.order.items![index].id!);
    if (ratingList.isEmpty) {
      ratingList.insert(index, rating.toInt());
    } else if (index <= ratingList.length - 1) {
      ratingList[index] = rating.toInt();
    } else {
      ratingList.insert(index, rating.toInt());
    }
  }

  void _updateFeedbackList({required int index, String? feedback}) {
    updateListingIdList(
        index: index, listingId: widget.order.items![index].id!);
    if (feedbackList.isEmpty) {
      feedbackList.insert(index, feedback);
    } else if (index <= feedbackList.length - 1) {
      feedbackList[index] = feedback;
    } else {
      feedbackList.insert(index, feedback);
    }
  }

  @override
  void initState() {
    for (var _ in widget.order.items!) {
      ratingList.add(0);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(LocaleKeys.order_feedback.tr()),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: getColorBasedOnTheme(
                      context, kLightColor, kDarkCardBgColor),
                ),
                child: Form(
                  key: _productFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocaleKeys.rate_product.tr(),
                          style: context.textTheme.headline6),
                      const SizedBox(height: 16),
                      ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: widget.order.items!
                            .map(
                              (e) => Column(
                                children: [
                                  _SingleProductRatingCard(
                                    order: widget.order,
                                    index: widget.order.items!.indexOf(e),
                                    updateRatingList: _updateRatingList,
                                    updateFeedbackList: _updateFeedbackList,
                                  ),
                                  widget.order.items!.indexOf(e) ==
                                          widget.order.items!.length - 1
                                      ? const SizedBox()
                                      : const Divider(),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        buttonText: LocaleKeys.submit.tr(),
                        onTap: () async {
                          if (_productFormKey.currentState!.validate()) {
                            if (listingIdList.length ==
                                    widget.order.items!.length &&
                                feedbackList.length ==
                                    widget.order.items!.length) {
                              final _result = await context
                                  .read(productFeedbackProvider.notifier)
                                  .postFeedback(
                                    widget.order.id,
                                    listingIdList,
                                    ratingList,
                                    feedbackList,
                                  );

                              if (_result) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            }
                          } else {
                            toast(LocaleKeys.rate_all_product.tr());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(LocaleKeys.rate_seller.tr(),
                          style: context.textTheme.headline6),
                      CustomShopCard(
                        image: widget.order.shop!.image!,
                        title:
                            widget.order.shop!.name ?? LocaleKeys.unknown.tr(),
                        verifiedText: widget.order.shop!.verifiedText ?? "",
                      ),
                      const Divider(height: 0),
                      const SizedBox(height: 16),
                      RatingBar.builder(
                        initialRating: double.parse('0.00'),
                        minRating: 1,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 25,
                        itemPadding: const EdgeInsets.only(right: 5),
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: kDarkPriceColor),
                        onRatingUpdate: (rating) {
                          _shopRatingController.text = '${rating.toInt()}';
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        title: LocaleKeys.write_a_feedback.tr(),
                        hintText: LocaleKeys.write_about_experience.tr(),
                        validator: (value) {
                          if (value!.length < 10) {
                            return LocaleKeys.comment_minimum_requirement.tr();
                          } else if (value.length > 250) {
                            return LocaleKeys.comment_maximum_requirement.tr();
                          }
                          return null;
                        },
                        maxLines: 3,
                        controller: _shopCommentController,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        buttonText: LocaleKeys.submit.tr(),
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final _result = await context
                                .read(sellerFeedbackProvider.notifier)
                                .postFeedback(
                                  widget.order.id,
                                  _shopRatingController.text,
                                  _shopCommentController.text,
                                );

                            if (_result) {
                              context.pop();
                              context.pop();
                            }
                          } else {
                            toast(LocaleKeys.rate_seller.tr());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // body: SingleChildScrollView(
        //   padding: const EdgeInsets.all(16),
        //   child: Column(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(16),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(10),
        //           color: getColorBasedOnTheme(
        //               context, kLightColor, kDarkCardBgColor),
        //         ),
        //         child: Form(
        //           key: _formKey,
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(LocaleKeys.rate_seller.tr(),
        //                   style: context.textTheme.headline6),
        //               CustomShopCard(
        //                 image: widget.order.shop!.image!,
        //                 title: widget.order.shop!.name ?? "Unknown",
        //                 verifiedText: widget.order.shop!.verifiedText ?? "",
        //               ),
        //               const Divider(height: 0),
        //               const SizedBox(height: 16),
        //               RatingBar.builder(
        //                 initialRating: double.parse('0.00'),
        //                 minRating: 1,
        //                 direction: Axis.horizontal,
        //                 itemCount: 5,
        //                 itemSize: 25,
        //                 itemPadding: const EdgeInsets.only(right: 5),
        //                 itemBuilder: (context, _) =>
        //                     const Icon(Icons.star, color: kDarkPriceColor),
        //                 onRatingUpdate: (rating) {
        //                   _shopRatingController.text = '${rating.toInt()}';
        //                 },
        //               ),
        //               const SizedBox(height: 16),
        //               CustomTextField(
        //                 title: LocaleKeys.write_a_feedback.tr(),
        //                 hintText: LocaleKeys.write_about_experience.tr(),
        //                 validator: (value) {
        //                   if (value!.length < 10) {
        //                     return LocaleKeys.comment_minimum_requirement.tr();
        //                   } else if (value.length > 250) {
        //                     return LocaleKeys.comment_maximum_requirement.tr();
        //                   }
        //                   return null;
        //                 },
        //                 maxLines: 3,
        //                 controller: _shopCommentController,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //       const SizedBox(height: 16),
        //       Container(
        //         padding: const EdgeInsets.only(
        //           left: 16,
        //           right: 16,
        //           top: 16,
        //         ),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(10),
        //           color: getColorBasedOnTheme(
        //               context, kLightColor, kDarkCardBgColor),
        //         ),
        //         child: Form(
        //           key: _productFormKey,
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(LocaleKeys.rate_product.tr(),
        //                   style: context.textTheme.headline6),
        //               const SizedBox(height: 16),
        //               ListView(
        //                 shrinkWrap: true,
        //                 physics: const NeverScrollableScrollPhysics(),
        //                 children: widget.order.items!
        //                     .map(
        //                       (e) => Column(
        //                         children: [
        //                           _SingleProductRatingCard(
        //                             order: widget.order,
        //                             index: widget.order.items!.indexOf(e),
        //                             updateRatingList: _updateRatingList,
        //                             updateFeedbackList: _updateFeedbackList,
        //                           ),
        //                           const Divider(),
        //                         ],
        //                       ),
        //                     )
        //                     .toList(),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //       const SizedBox(height: 8),
        //       CustomButton(
        //         buttonText: LocaleKeys.submit.tr(),
        //         onTap: () async {
        //           if (_formKey.currentState!.validate()) {
        //             if (_productFormKey.currentState!.validate()) {
        //               if (listingIdList.length == widget.order.items!.length &&
        //                   feedbackList.length == widget.order.items!.length) {}
        //             } else {
        //               toast(LocaleKeys.rate_all_product.tr());
        //             }
        //           }
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

class _SingleProductRatingCard extends StatefulWidget {
  final Order order;
  final int index;
  final void Function({required int index, required double rating})
      updateRatingList;
  final void Function({required int index, String? feedback})
      updateFeedbackList;
  const _SingleProductRatingCard({
    Key? key,
    required this.order,
    required this.index,
    required this.updateRatingList,
    required this.updateFeedbackList,
  }) : super(key: key);

  @override
  State<_SingleProductRatingCard> createState() =>
      _SingleProductRatingCardState();
}

class _SingleProductRatingCardState extends State<_SingleProductRatingCard> {
  final TextEditingController _productFeedbackController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CachedNetworkImage(
            imageUrl: widget.order.items![widget.index].image!,
            errorWidget: (context, url, error) => const SizedBox(),
            progressIndicatorBuilder: (context, url, progress) => Center(
              child: CircularProgressIndicator(value: progress.progress),
            ),
            width: 50,
            height: 50,
          ),
          title: Text(widget.order.items![widget.index].description!,
              style: context.textTheme.subtitle2),
          subtitle: Row(
            children: [
              Text(
                widget.order.items![widget.index].unitPrice!,
                style: context.textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getColorBasedOnTheme(
                      context, kPriceColor, kDarkPriceColor),
                ),
              ),
              Text(
                ' x ' + widget.order.items![widget.index].quantity.toString(),
                style: context.textTheme.subtitle2!.copyWith(),
              )
            ],
          ).py(8),
        ),
        const Divider(height: 0),
        const SizedBox(height: 16),
        RatingBar.builder(
          initialRating: double.parse('0.00'),
          minRating: 1.0,
          direction: Axis.horizontal,
          itemCount: 5,
          itemSize: 25,
          itemPadding: const EdgeInsets.only(right: 5),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: kDarkPriceColor),
          onRatingUpdate: (rating) =>
              widget.updateRatingList(index: widget.index, rating: rating),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          title: LocaleKeys.write_a_feedback.tr(),
          hintText: LocaleKeys.write_about_experience.tr(),
          maxLines: null,
          controller: _productFeedbackController,
          validator: (value) {
            if (value!.length < 10) {
              return LocaleKeys.comment_minimum_requirement.tr();
            } else if (value.length > 250) {
              return LocaleKeys.comment_maximum_requirement.tr();
            }
            return null;
          },
          onChanged: (feedback) {
            widget.updateFeedbackList(index: widget.index, feedback: feedback);
          },
        ),
      ],
    );
  }
}


                        // context
                        //     .read(sellerFeedbackProvider.notifier)
                        //     .postFeedback(
                        //       widget.order.id,
                        //       _shopRatingController.text,
                        //       _shopCommentController.text,
                        //     );
                        // .then((value) {
                        //   return context
                        //     .read(productFeedbackProvider.notifier)
                        //     .postFeedback(
                        //       widget.order.id,
                        //       listingIdList,
                        //       ratingList,
                        //       feedbackList,
                        //     );
                        // })
                        // .then((value) => context
                        //         .read(ordersProvider.notifier)
                        //         .orders(ignoreLoadingState: false)
                        //         .then((value) {
                        //       context.pop();
                        //       context.pop();
                        //     }));
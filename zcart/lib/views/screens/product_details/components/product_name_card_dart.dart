import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/wishlist_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class ProductNameCard extends StatelessWidget {
  const ProductNameCard({
    Key? key,
    required this.productModel,
  }) : super(key: key);

  final ProductDetailsModel productModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          productModel.data!.hasOffer!
              ? Container(
                  width: context.screenWidth,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kGradientColor1, kGradientColor2],
                      ),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: CountdownTimer(
                      endWidget: Container(),
                      endTime:
                          productModel.data!.offerEnd!.millisecondsSinceEpoch,
                      textStyle: context.textTheme.bodyText1!
                          .copyWith(color: kPrimaryLightTextColor),
                    ),
                  ),
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    productModel.data!.hasOffer!
                        ? productModel.data!.offerPrice != null
                            ? productModel.data!.offerPrice!
                            : productModel.data!.price!
                        : productModel.data!.price!,
                    style: context.textTheme.headline6!.copyWith(
                      color: getColorBasedOnTheme(
                          context, kPriceColor, kDarkPriceColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    productModel.data!.hasOffer!
                        ? productModel.data!.offerPrice != null
                            ? productModel.data!.price!
                            : ""
                        : "",
                    style: context.textTheme.subtitle2!.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: kPrimaryFadeTextColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ).pOnly(left: 10),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(
                        CupertinoIcons.share,
                        size: 18,
                      ),
                      Text(LocaleKeys.share.tr(),
                              style: context.textTheme.overline)
                          .pOnly(top: 3)
                    ],
                  ).px(10).onInkTap(() async {
                    await Share.share(
                        '${productModel.data!.title}.\n${API.appUrl}/product/${productModel.data!.slug}');
                  }),
                  Column(
                    children: [
                      const Icon(CupertinoIcons.heart, size: 18),
                      Text(LocaleKeys.wishlist_text.tr(),
                              style: context.textTheme.overline)
                          .pOnly(top: 3),
                    ],
                  ).onInkTap(() async {
                    toast(LocaleKeys.adding_to_wishlist.tr());
                    await context
                        .read(wishListNotifierProvider.notifier)
                        .addToWishList(productModel.data!.slug, context);
                  })
                ],
              )
            ],
          ).py(5),
          Row(
            children: [
              Flexible(
                child: Text(productModel.data!.title!,
                    softWrap: true, style: context.textTheme.bodyText2),
              ),
            ],
          ).paddingBottom(10),
          productModel.data!.rating == null
              ? Container()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RatingBar.builder(
                      initialRating:
                          double.parse(productModel.data!.rating ?? '0.0'),
                      minRating: 0,
                      direction: Axis.horizontal,
                      wrapAlignment: WrapAlignment.center,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemCount: 5,
                      itemSize: 12,
                      unratedColor: kFadeColor,
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: kPrimaryColor),
                      onRatingUpdate: (rating) => print(rating),
                    ),
                    Text(
                      (productModel.data!.rating).toString(),
                      style: context.textTheme.subtitle2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ).px(5),
                  ],
                ).paddingBottom(10),
          SizedBox(
            width:
                productModel.data!.labels!.isEmpty ? null : context.screenWidth,
            height: productModel.data!.labels!.isEmpty ? null : 40,
            child: productModel.data!.labels!.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(productModel.data!.condition!,
                          style: context.textTheme.overline!
                              .copyWith(color: kPrimaryLightTextColor)),
                    ).onInkTap(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 8),
                          content: Text(productModel.data!.conditionNote!),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                        ),
                      );
                    }),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: productModel.data!.labels!.length,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          index == 0
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(productModel.data!.condition!,
                                      style: context.textTheme.overline!
                                          .copyWith(
                                              color: kPrimaryLightTextColor)),
                                ).onInkTap(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 8),
                                      content: Text(
                                          productModel.data!.conditionNote!),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                    ),
                                  );
                                })
                              : Container(),
                          Container(
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(productModel.data!.labels![index],
                                style: context.textTheme.overline!
                                    .copyWith(color: kPrimaryLightTextColor)),
                          ).pOnly(left: 5),
                        ],
                      );
                    }),
          ).pOnly(bottom: 5),
        ],
      ),
    );
  }
}

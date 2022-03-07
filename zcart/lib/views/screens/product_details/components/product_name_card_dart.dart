import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/custom_small_button.dart';
import 'package:zcart/views/shared_widgets/system_config_builder.dart';

class ProductNameCard extends StatelessWidget {
  final ProductDetailsModel productModel;
  final bool isNotAvailable;
  final VoidCallback onDoneCountDown;
  const ProductNameCard({
    Key? key,
    required this.productModel,
    required this.isNotAvailable,
    required this.onDoneCountDown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _hasOffer = (productModel.data!.hasOffer ?? false) &&
        productModel.data!.offerEnd != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isNotAvailable
            ? Text(
                LocaleKeys.out_of_stock.tr(),
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: getColorBasedOnTheme(
                          context, kPriceColor, kDarkPriceColor),
                    ),
              )
            : Container(
                padding: _hasOffer
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                    : null,
                decoration: _hasOffer
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kGradientColor1, kGradientColor2],
                        ),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      children: [
                        Text(
                          productModel.data!.hasOffer!
                              ? productModel.data!.offerPrice != null
                                  ? productModel.data!.offerPrice!
                                  : productModel.data!.price!
                              : productModel.data!.price!,
                          style: context.textTheme.headline6!.copyWith(
                            color: _hasOffer
                                ? kLightColor
                                : getColorBasedOnTheme(
                                    context, kPriceColor, kDarkPriceColor),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          productModel.data!.hasOffer!
                              ? productModel.data!.offerPrice != null
                                  ? productModel.data!.price!
                                  : ""
                              : "",
                          style: context.textTheme.caption!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: _hasOffer
                                ? Colors.white60
                                : kPrimaryFadeTextColor,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ).pOnly(left: 8),
                      ],
                    ),
                    _hasOffer
                        ? SlideCountdown(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            duration: productModel.data!.offerEnd!
                                .difference(DateTime.now()),
                            decoration: const BoxDecoration(),
                            onDone: onDoneCountDown,
                            showZeroValue: true,
                            fade: true,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                          )
                        : const SizedBox()
                  ],
                ),
              ).py(5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(productModel.data!.title!,
                  softWrap: true,
                  style: context.textTheme.bodyText2!
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const SizedBox(height: 8),
                const Icon(
                  CupertinoIcons.share,
                  size: 18,
                ),
                Text(LocaleKeys.share.tr(), style: context.textTheme.overline)
                    .pOnly(top: 3)
              ],
            ).pOnly(left: 10).onInkTap(() async {
              await Share.share(
                  '${productModel.data!.title}.\n${API.appUrl}/product/${productModel.data!.slug}');
            }),
          ],
        ),
        productModel.data!.rating == null
            ? const SizedBox()
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
                    itemSize: 15,
                    unratedColor: kFadeColor,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: kDarkPriceColor),
                    onRatingUpdate: (rating) => debugPrint(rating.toString()),
                  ),

                  Text(
                    " (${(productModel.data!.rating).toString()}) ",
                    style: context.textTheme.caption!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),

                  // if (productModel.data!.condition != null)
                  //   Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [

                  //       //   width: 2,
                  //       //   height: 15,
                  //       //   color: kPrimaryColor,
                  //       // ),
                  //       const SizedBox(width: 4),
                  //       Text(productModel.data!.condition!,
                  //           style: context.textTheme.subtitle2!.copyWith(
                  //               fontWeight: FontWeight.bold,
                  //               decoration: TextDecoration.underline)),
                  //     ],
                  //   )
                ],
              ).py(4),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            if (productModel.data!.condition != null)
              SystemConfigBuilder(
                builder: (context, systemConfig) {
                  return systemConfig?.showItemConditions == true
                      ? CustomSmallButton(
                          text: productModel.data!.condition!,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: kPrimaryColor,
                                duration: const Duration(seconds: 8),
                                content: Text(
                                  productModel.data!.conditionNote!,
                                  style: context.textTheme.subtitle2!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kLightColor),
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox();
                },
              ),
            if (productModel.data!.labels != null &&
                productModel.data!.labels!.isNotEmpty)
              ...productModel.data!.labels!.map(
                  (label) => CustomSmallButton(text: label, onPressed: () {})),
          ],
        ),
      ],
    );
  }
}

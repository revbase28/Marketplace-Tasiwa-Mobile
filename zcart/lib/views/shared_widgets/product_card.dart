import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/Theme/styles/colors.dart';

import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';

class ProductCard extends StatelessWidget {
  const ProductCard(
      {required this.productList,
      this.title,
      this.willShuffle = true,
      Key? key})
      : super(key: key);

  final List<dynamic>? productList;
  final String? title;
  final bool willShuffle;

  @override
  Widget build(BuildContext context) {
    if (willShuffle) {
      productList!.shuffle();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == null
            ? const SizedBox()
            : Text(title!,
                    style: context.textTheme.headline6!
                        .copyWith(color: kPrimaryFadeTextColor))
                .pOnly(bottom: 10),
        Flexible(
          child: Container(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .85,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: productList!.length > 12 ? 12 : productList!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Expanded(
                            child: CachedNetworkImage(
                          imageUrl: productList![index].image,
                          fit: BoxFit.fitWidth,
                          errorWidget: (context, url, error) =>
                              const SizedBox(),
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                                value: progress.progress),
                          ),
                        ).pOnly(bottom: 10)),
                        Text(
                          "${productList![index].offerPrice ?? ''}",
                          style: context.textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: getColorBasedOnTheme(
                                  context, kPriceColor, kDarkPriceColor)),
                        )
                            .pOnly(bottom: 3)
                            .visible(productList![index].hasOffer),
                        Text("${productList![index].price}",
                                style: context.textTheme.subtitle2!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: getColorBasedOnTheme(
                                      context, kPriceColor, kDarkPriceColor),
                                ))
                            .pOnly(bottom: 3)
                            .visible(!productList![index].hasOffer),
                        Text(
                          "${productList![index].price}",
                          style: context.textTheme.caption!.copyWith(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: kPrimaryFadeTextColor),
                        ).visible(productList![index].hasOffer),
                      ],
                    ),
                  ).onInkTap(() {
                    context.nextPage(ProductDetailsScreen(
                        productSlug: productList![index].slug));
                  });
                }).p(10),
          ).cornerRadius(10),
        ),
      ],
    );
  }
}

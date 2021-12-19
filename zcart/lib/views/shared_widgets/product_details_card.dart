import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/riverpod/providers/product_slug_list_provider.dart';
import 'package:zcart/riverpod/providers/product_provider.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailsCard extends StatelessWidget {
  final List<dynamic> productList;
  final String? title;
  final bool isTitleCentered;

  const ProductDetailsCard(
      {required this.productList,
      this.title,
      this.isTitleCentered = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title == null
            ? const SizedBox()
            : Text(title!,
                    textAlign:
                        isTitleCentered ? TextAlign.center : TextAlign.left,
                    style: context.textTheme.headline6!
                        .copyWith(color: kPrimaryFadeTextColor))
                .pOnly(bottom: 5),
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  context
                      .read(productNotifierProvider.notifier)
                      .getProductDetails(productList[index].slug)
                      .then((value) {
                    getRecentlyViewedItems(context);
                  });
                  context
                      .read(productSlugListProvider.notifier)
                      .addProductSlug(productList[index].slug);
                  context.nextPage(const ProductDetailsScreen());
                },
                child: Card(
                  elevation: 0,
                  color: getColorBasedOnTheme(
                      context, kLightColor, kDarkCardBgColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridTile(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          productList[index] is LinkedItem
                              ? const SizedBox()
                              : productList[index].hotItem
                                  ? ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.yellow[700]!,
                                                    Colors.deepOrange[300]!
                                                  ],
                                                  tileMode: TileMode.clamp)
                                              .createShader(bounds),
                                      child: Text(
                                        "Hot Item",
                                        style:
                                            context.textTheme.caption!.copyWith(
                                                fontWeight: FontWeight.bold,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                      offset:
                                                          const Offset(1, 1),
                                                      blurRadius: 10,
                                                      color: kDarkColor
                                                          .withOpacity(0.4)),
                                                ],
                                                color: kPrimaryLightTextColor),
                                      ),
                                    )
                                  : const SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              productList[index].condition == "New"
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 6),
                                      child: Text(
                                        productList[index].condition,
                                        style: context.textTheme.caption!
                                            .copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: kPrimaryLightTextColor),
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: kPrimaryColor),
                                    ).pOnly(right: 3)
                                  : const SizedBox(),
                              productList[index].discount != null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 6),
                                      child: Text(
                                        productList[index].discount,
                                        style: context.textTheme.caption!
                                            .copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: kPrimaryLightTextColor),
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: kPrimaryColor),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ).pSymmetric(h: 6, v: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: CachedNetworkImage(
                            imageUrl: productList[index].image,
                            fit: BoxFit.fitWidth,
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: CircularProgressIndicator(
                                  value: progress.progress),
                            ),
                          )),
                          Text(
                            productList[index].title,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: context.textTheme.subtitle2,
                          ).pOnly(bottom: 5, top: 5),
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              productList[index].hasOffer
                                  ? Text(productList[index].offerPrice,
                                      style: context.textTheme.subtitle2!
                                          .copyWith(
                                              color: getColorBasedOnTheme(
                                                  context,
                                                  kPriceColor,
                                                  kDarkPriceColor),
                                              fontWeight: FontWeight.bold))
                                  : Text(productList[index].price,
                                      style: context.textTheme.subtitle2!
                                          .copyWith(
                                              color: getColorBasedOnTheme(
                                                  context,
                                                  kPriceColor,
                                                  kDarkPriceColor),
                                              fontWeight: FontWeight.bold)),
                              const SizedBox(width: 3),
                              productList[index].hasOffer
                                  ? Text(
                                      productList[index].price,
                                      style: context.textTheme.caption!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 10,
                                              color: kPrimaryFadeTextColor),
                                    )
                                  : const SizedBox(),
                              productList[index].rating != null
                                  ? Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.star,
                                              color: kDarkPriceColor, size: 14),
                                          Text(
                                            productList[index].rating,
                                            textAlign: TextAlign.end,
                                            style: context.textTheme.caption!
                                                .copyWith(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          )
                        ],
                      ).p(10),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }
}

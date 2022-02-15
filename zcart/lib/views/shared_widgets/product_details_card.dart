import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailsCardGridView extends StatelessWidget {
  final List<dynamic> productList;
  final String? title;
  final bool isTitleCentered;

  const ProductDetailsCardGridView(
      {required this.productList,
      this.title,
      this.isTitleCentered = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return productList.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title == null
                  ? const SizedBox()
                  : Text(title!,
                          textAlign: isTitleCentered
                              ? TextAlign.center
                              : TextAlign.left,
                          style: context.textTheme.headline6!
                              .copyWith(color: kPrimaryFadeTextColor))
                      .pOnly(bottom: 5),
              productList.length - 1 == 0
                  ? const SizedBox(height: 10)
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: productList.length.isOdd
                          ? productList.length - 1
                          : productList.length,
                      itemBuilder: (context, index) {
                        return ProductDetailsCard(product: productList[index]);
                      }),
              productList.length.isOdd
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width * .6,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 2,
                        ),
                        child: ProductDetailsCard(
                            product: productList[productList.length - 1]),
                      ),
                    )
                  : const SizedBox(),
            ],
          );
  }
}

class ProductDetailsCard extends StatelessWidget {
  const ProductDetailsCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  final dynamic product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.nextPage(ProductDetailsScreen(productSlug: product.slug));
      },
      child: Card(
        elevation: 0,
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: GridTile(
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                product is LinkedItem
                    ? const SizedBox()
                    : product.hotItem
                        ? ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
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
                              style: context.textTheme.caption!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 10,
                                        color: kDarkColor.withOpacity(0.4)),
                                  ],
                                  color: kPrimaryLightTextColor),
                            ),
                          )
                        : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    product.condition == "New"
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: Text(
                              product.condition,
                              style: context.textTheme.caption!.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryLightTextColor),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor),
                          ).pOnly(right: 3)
                        : const SizedBox(),
                    product.discount != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            child: Text(
                              product.discount,
                              style: context.textTheme.caption!.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryLightTextColor),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ).pSymmetric(h: 6, v: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const SizedBox(),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                )),
                Text(
                  product.title,
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
                    product.hasOffer
                        ? Text(product.offerPrice,
                            style: context.textTheme.subtitle2!.copyWith(
                                color: getColorBasedOnTheme(
                                    context, kPriceColor, kDarkPriceColor),
                                fontWeight: FontWeight.bold))
                        : Text(product.price,
                            style: context.textTheme.subtitle2!.copyWith(
                                color: getColorBasedOnTheme(
                                    context, kPriceColor, kDarkPriceColor),
                                fontWeight: FontWeight.bold)),
                    const SizedBox(width: 3),
                    product.hasOffer
                        ? Text(
                            product.price,
                            style: context.textTheme.caption!.copyWith(
                                decoration: TextDecoration.lineThrough,
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                                color: kPrimaryFadeTextColor),
                          )
                        : const SizedBox(),
                    product.rating != null
                        ? Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.star,
                                    color: kDarkPriceColor, size: 14),
                                Text(
                                  product.rating.toString(),
                                  textAlign: TextAlign.end,
                                  style: context.textTheme.caption!.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
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
  }
}

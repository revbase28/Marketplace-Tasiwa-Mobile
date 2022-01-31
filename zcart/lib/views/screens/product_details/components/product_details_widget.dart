import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';

class ProductDetailsWidget extends StatelessWidget {
  final ProductDetailsModel details;
  const ProductDetailsWidget({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProductPageDefaultContainer(
          isFullPadding: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              details.data!.keyFeatures!.isEmpty
                  ? const SizedBox()
                  : Text('${LocaleKeys.key_features.tr()}\n',
                      style: context.textTheme.subtitle2),
              details.data!.keyFeatures != null
                  ? Column(
                      children: details.data!.keyFeatures!
                          .map((e) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.circle_rounded,
                                    size: 10,
                                  ).p(8).pOnly(right: 5),
                                  Flexible(
                                    child: Text(
                                      e,
                                      style: context.textTheme.bodyText2!
                                          .copyWith(
                                              fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ).pSymmetric(v: 2))
                          .toList(),
                    )
                  : const SizedBox(),
              Text('\n${LocaleKeys.technical_details.tr()}\n',
                  style: context.textTheme.subtitle2),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2, child: Text("${LocaleKeys.brand.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.brand ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.model_no.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.modelNumber ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2, child: Text("${LocaleKeys.isbn.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.gtin ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2, child: Text("${LocaleKeys.part_no.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.mpn ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.seller_sku.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.sku ?? LocaleKeys.not_available,
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.manufacturer.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.manufacturer!.name ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2, child: Text("${LocaleKeys.origin.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.origin ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.min_quantity.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.minOrderQuantity == null
                                  ? LocaleKeys.not_available.tr()
                                  : details.data!.minOrderQuantity.toString(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.shipping_weight.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.shippingWeight ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("${LocaleKeys.added_on.tr()}: ")),
                      Expanded(
                          flex: 3,
                          child: Text(
                              details.data!.product!.availableFrom ??
                                  LocaleKeys.not_available.tr(),
                              style: context.textTheme.bodyText2)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        details.data!.product!.description == null
            ? const SizedBox()
            : Column(
                children: [
                  ProductPageDefaultContainer(
                    child: ExpansionTile(
                      childrenPadding: EdgeInsets.zero,
                      tilePadding: EdgeInsets.zero,
                      title: Text(LocaleKeys.product_desc.tr(),
                          style: context.textTheme.subtitle2),
                      iconColor: getColorBasedOnTheme(
                          context, kDarkColor, kLightColor),
                      collapsedIconColor: kPrimaryColor,
                      children: [
                        HtmlWidget(
                          details.data!.product!.description!,
                          enableCaching: true,
                          factoryBuilder: () => WidgetFactory(),
                          onTapUrl: (url) {
                            launchURL(url);
                            return true;
                          },
                        ).px(10).py(5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
        details.data!.description == null
            ? const SizedBox()
            : Column(
                children: [
                  ProductPageDefaultContainer(
                    child: ExpansionTile(
                      childrenPadding: EdgeInsets.zero,
                      tilePadding: EdgeInsets.zero,
                      title: Text(LocaleKeys.seller_spec.tr(),
                          style: context.textTheme.subtitle2),
                      iconColor: getColorBasedOnTheme(
                          context, kLightColor, kDarkColor),
                      collapsedIconColor: kPrimaryColor,
                      children: [
                        HtmlWidget(
                          details.data!.description!,
                          enableCaching: true,
                          onTapUrl: (url) {
                            launchURL(url);
                            return true;
                          },
                        ).px(10).py(5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
      ],
    );
  }
}

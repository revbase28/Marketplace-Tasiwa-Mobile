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
              details.data!.keyFeatures == null ||
                      details.data!.keyFeatures!.isEmpty
                  ? const SizedBox()
                  : Text('${LocaleKeys.key_features.tr()}\n',
                      style: context.textTheme.subtitle2!
                          .copyWith(fontWeight: FontWeight.bold)),
              details.data!.keyFeatures != null
                  ? Column(
                      children: details.data!.keyFeatures!.map(
                        (e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle,
                                    size: 14,
                                    color: Theme.of(context).disabledColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: context.textTheme.subtitle2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    )
                  : const SizedBox(),
              details.data!.keyFeatures == null ||
                      details.data!.keyFeatures!.isEmpty
                  ? const SizedBox()
                  : const SizedBox(height: 8),
              Text('${LocaleKeys.technical_details.tr()}\n',
                  style: context.textTheme.subtitle2!
                      .copyWith(fontWeight: FontWeight.bold)),
              Column(
                children: [
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.brand.tr()}: ",
                    value: details.data!.product!.brand ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.model_no.tr()}: ",
                    value: details.data!.product!.modelNumber ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${details.data!.product!.gtinType}: ",
                    value: details.data!.product!.gtin ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.part_no.tr()}: ",
                    value: details.data!.product!.mpn ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.seller_sku.tr()}: ",
                    value: details.data!.sku ?? LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.condition.tr()}: ",
                    value: details.data!.condition ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.manufacturer.tr()}: ",
                    value: details.data!.product!.manufacturer!.name ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.origin.tr()}: ",
                    value: details.data!.product!.origin ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.min_quantity.tr()}: ",
                    value: details.data!.minOrderQuantity == null
                        ? LocaleKeys.not_available.tr()
                        : details.data!.minOrderQuantity.toString(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.shipping_weight.tr()}: ",
                    value: details.data!.shippingWeight ??
                        LocaleKeys.not_available.tr(),
                  ),
                  TechnicalDetailsItem(
                    title: "${LocaleKeys.added_on.tr()}: ",
                    value: details.data!.product!.availableFrom ??
                        LocaleKeys.not_available.tr(),
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
                          isSelectable: true,
                          textStyle: Theme.of(context).textTheme.subtitle2,
                          // customWidgetBuilder: (e) {
                          //   return Text(
                          //     e.outerHtml,
                          //     style: Theme.of(context).textTheme.subtitle2,
                          //   );
                          // },
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
                      iconColor: getColorBasedOnTheme(
                          context, kLightColor, kDarkColor),
                      collapsedIconColor: kPrimaryColor,
                      title: Text(LocaleKeys.seller_spec.tr(),
                          style: context.textTheme.subtitle2),
                      children: [
                        HtmlWidget(
                          details.data!.description!,
                          enableCaching: true,
                          factoryBuilder: () => WidgetFactory(),
                          isSelectable: true,
                          textStyle: Theme.of(context).textTheme.subtitle2,
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

class TechnicalDetailsItem extends StatelessWidget {
  final String title;
  final String value;
  const TechnicalDetailsItem({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 35,
            child: Text(
              title,
              textAlign: TextAlign.end,
              style: context.textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).disabledColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 65,
            child: Text(value,
                textAlign: TextAlign.start,
                style: context.textTheme.bodyText2!),
          ),
        ],
      ),
    );
  }
}

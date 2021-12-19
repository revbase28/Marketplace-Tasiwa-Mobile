import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/product/product_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';

class ProductBrandCard extends StatelessWidget {
  final ProductLoadedState productDetailsState;
  const ProductBrandCard({
    Key? key,
    required this.productDetailsState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: productDetailsState
                  .productModel.data!.product!.manufacturer!.slug ==
              null
          ? const SizedBox()
          : Container(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              child: ListTile(
                title: Text(
                  "${LocaleKeys.brand.tr()}  :  ${productDetailsState.productModel.data!.product!.manufacturer!.name}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.subtitle2!,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                onTap: () async {
                  context.nextPage(const BrandProfileScreen());
                  await context
                      .read(brandProfileNotifierProvider.notifier)
                      .getBrandProfile(productDetailsState
                          .productModel.data!.product!.manufacturer!.slug);

                  await context
                      .read(brandItemsListNotifierProvider.notifier)
                      .getBrandItemsList(productDetailsState
                          .productModel.data!.product!.manufacturer!.slug);
                },
              ),
            ),
    );
  }
}

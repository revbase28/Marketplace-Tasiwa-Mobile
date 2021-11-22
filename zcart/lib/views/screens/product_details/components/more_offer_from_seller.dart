import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/offers_provider.dart';
import 'package:zcart/riverpod/state/product/product_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/offers_screen.dart';

class MoreOffersFromSellerCard extends StatelessWidget {
  const MoreOffersFromSellerCard({
    Key? key,
    required this.productDetailsState,
  }) : super(key: key);

  final ProductLoadedState productDetailsState;

  @override
  Widget build(BuildContext context) {
    return productDetailsState.productModel.data!.product!.listingCount == 0 ||
            productDetailsState.productModel.data!.product!.listingCount == null
        ? Container()
        : Container(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            child: ListTile(
              title: Text(
                LocaleKeys.more_offers_from_others.tr(args: [
                  "${productDetailsState.productModel.data!.product!.listingCount}"
                ]),
                style: context.textTheme.subtitle2!,
              ),
              onTap: () {
                context
                    .read(offersNotifierProvider.notifier)
                    .getOffersFromOtherSellers(
                        productDetailsState.productModel.data!.product!.slug);
                context.nextPage(const OffersScreen());
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
            ));
  }
}

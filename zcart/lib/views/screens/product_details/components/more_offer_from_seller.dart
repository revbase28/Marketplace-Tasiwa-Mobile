import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/riverpod/providers/offers_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/offers_screen.dart';

class MoreOffersFromSellerCard extends StatelessWidget {
  final ProductDetailsModel details;
  const MoreOffersFromSellerCard({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return details.data!.product!.listingCount == 0 ||
            details.data!.product!.listingCount == null
        ? const SizedBox()
        : ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              LocaleKeys.more_offers_from_others
                  .tr(args: ["${details.data!.product!.listingCount}"]),
              style: context.textTheme.subtitle2!,
            ),
            onTap: () {
              context
                  .read(offersNotifierProvider.notifier)
                  .getOffersFromOtherSellers(details.data!.product!.slug);
              context.nextPage(const OffersScreen());
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 15),
          );
  }
}

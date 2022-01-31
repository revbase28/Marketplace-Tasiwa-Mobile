import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';

class ProductBrandCard extends StatelessWidget {
  final ProductDetailsModel details;
  const ProductBrandCard({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        "${LocaleKeys.brand.tr()}  :  ${details.data!.product!.manufacturer!.name}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.subtitle2!,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: () async {
        context.nextPage(const BrandProfileScreen());
        await context
            .read(brandProfileNotifierProvider.notifier)
            .getBrandProfile(details.data!.product!.manufacturer!.slug);

        await context
            .read(brandItemsListNotifierProvider.notifier)
            .getBrandItemsList(details.data!.product!.manufacturer!.slug);
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_details.dart';

class ShopCard extends StatelessWidget {
  final ProductDetailsModel details;
  const ShopCard({
    Key? key,
    required this.details,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      trailing: const Icon(
        Icons.keyboard_arrow_right,
      ),
      leading: CachedNetworkImage(
        imageUrl: details.data!.shop!.image!,
        width: context.screenWidth * 0.15,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => const SizedBox(),
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(value: progress.progress),
        ),
      ).p(5),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              details.data!.shop!.name!,
              style: context.textTheme.headline6,
            ),
          ),
          const Icon(Icons.check_circle, color: kGreenColor, size: 15)
              .px(4)
              .pOnly(top: 3)
              .onInkTap(() {
            toast(details.data!.shop!.verifiedText);
          })
        ],
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RatingBar.builder(
            initialRating: double.parse(details.data!.shop!.rating ?? '0.0'),
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            ignoreGestures: true,
            unratedColor: kFadeColor,
            itemCount: 5,
            itemSize: 12,
            itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: kDarkPriceColor),
            onRatingUpdate: (rating) => debugPrint(rating.toString()),
          ),
          Text(
            details.data!.shop!.rating ?? '',
            style: context.textTheme.overline,
          ).visible(details.data!.shop!.rating != null),
        ],
      ),
      onTap: () {
        context
            .read(vendorDetailsNotifierProvider.notifier)
            .getVendorDetails(details.data!.shop!.slug);
        context
            .read(vendorItemsNotifierProvider.notifier)
            .getVendorItems(details.data!.shop!.slug);
        context.nextPage(const VendorsDetailsScreen());
      },
    );
  }
}

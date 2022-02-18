import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class VendorsActivityCard extends StatelessWidget {
  final int activeListCount;
  final String rating;
  final int itemsSold;
  const VendorsActivityCard({
    Key? key,
    required this.activeListCount,
    required this.rating,
    required this.itemsSold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$activeListCount",
                          style: context.textTheme.headline4!),
                      Text(LocaleKeys.activity_listing.tr(),
                          textAlign: TextAlign.center,
                          style: context.textTheme.subtitle2!)
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(rating, style: context.textTheme.headline4!),
                      Text(LocaleKeys.rating.tr(),
                          textAlign: TextAlign.center,
                          style: context.textTheme.subtitle2!)
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$itemsSold", style: context.textTheme.headline4!),
                      Text(LocaleKeys.item_sold.tr(),
                          textAlign: TextAlign.center,
                          style: context.textTheme.subtitle2!)
                    ],
                  )),
            ],
          ).py(10).px(10),
        ],
      ),
    ).cornerRadius(10);
  }
}

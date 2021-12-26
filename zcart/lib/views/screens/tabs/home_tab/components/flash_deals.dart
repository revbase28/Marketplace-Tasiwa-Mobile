import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/deals/flash_deals_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class FlashDealsSection extends StatelessWidget {
  final FlashDealsModel flashDeals;
  const FlashDealsSection({
    Key? key,
    required this.flashDeals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: getColorBasedOnTheme(context, kDarkColor.withOpacity(0.4),
                kLightBgColor.withOpacity(0.2)),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        color: getColorBasedOnTheme(context, kLightBgColor, kDarkBgColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  flashDeals.meta!.dealTitle ?? "Flash Deal",
                  style: context.textTheme.headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SlideCountdownSeparated(
                  duration: flashDeals.meta!.endTime!.difference(
                    DateTime.now(),
                  ),
                  //countUp: true,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),

                  separator: "",
                  showZeroValue: false,
                  textStyle: context.textTheme.subtitle2!.copyWith(
                    color: kPrimaryLightTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  width: 40,
                )
              ],
            ),
          ),

          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProductDetailsCardGridView(
              productList: flashDeals.featured ?? [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CarouselSlider(
              items: flashDeals.listings!
                  .map((e) => ProductDetailsCard(product: e))
                  .toList(),
              options: CarouselOptions(
                scrollDirection: Axis.horizontal,
                viewportFraction: 0.5,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

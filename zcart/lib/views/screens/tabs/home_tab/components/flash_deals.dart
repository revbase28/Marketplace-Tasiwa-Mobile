import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/deals/flash_deals_model.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class FlashDealsSection extends StatelessWidget {
  final FlashDealsModel flashDeals;
  const FlashDealsSection({
    Key? key,
    required this.flashDeals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                flashDeals.meta!.dealTitle ?? "Flash Deals",
                style: context.textTheme.headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SlideCountdownSeparated(
                duration: flashDeals.meta!.endTime!.difference(
                  DateTime.now(),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kGradientColor1,
                      kGradientColor2,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
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
          ProductDetailsCardGridView(
            productList: flashDeals.featured,
          ),
          flashDeals.featured.isEmpty
              ? const SizedBox(
                  height: 8,
                )
              : const SizedBox(),
          CarouselSlider(
            items: flashDeals.listings
                .map((e) => ProductDetailsCard(product: e))
                .toList(),
            options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              viewportFraction: 0.5,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

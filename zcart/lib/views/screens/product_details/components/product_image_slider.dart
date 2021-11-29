import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';

class ProductImageSlider extends StatelessWidget {
  final List? sliderList;

  const ProductImageSlider({
    Key? key,
    this.sliderList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
            options: CarouselOptions(
              scrollDirection: Axis.horizontal,
              height: context.percentHeight * 45,
              viewportFraction: 1,
              autoPlay: true,
            ),
            items: sliderList!
                .map((item) => Container(
                      width: double.infinity,
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                      child: Image.network(
                        item.path,
                        fit: BoxFit.scaleDown,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          print(
                              "Exception: $exception\nStackTrace: $stackTrace");
                          return const SizedBox();
                        },
                      ),
                    ))
                .toList()),
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: kFadeColor.withOpacity(0.3),
          ),
          child: BackButton(
            color: getColorBasedOnTheme(context, kLightColor, kDarkColor),
            onPressed: () async {
              context.pop();
            },
          ),
        ).p(10),
      ],
    );
  }
}

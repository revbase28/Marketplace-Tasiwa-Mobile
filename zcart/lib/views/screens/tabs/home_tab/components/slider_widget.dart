import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/data/models/sliders/slider_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/category_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_list/product_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget(this.sliderList, {Key? key}) : super(key: key);

  final List<SliderList>? sliderList;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
          scrollDirection: Axis.horizontal,
          height: context.percentHeight * 25,
          viewportFraction: 1,
          autoPlay: true,
        ),
        items: sliderList!
            .map((item) => SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: item.image!.path!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const SizedBox(),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child:
                          CircularProgressIndicator(value: progress.progress),
                    ),
                  ),
                ).cornerRadius(10).onInkTap(() {
                  if (item.link != null && item.link!.isNotEmpty) {
                    context
                        .read(categoryItemNotifierProvider.notifier)
                        .getCategoryItem(item.link);
                    context.nextPage(const ProductListScreen());
                  } else {
                    toast(
                      LocaleKeys.no_offer.tr(),
                    );
                  }
                }))
            .toList());
  }
}

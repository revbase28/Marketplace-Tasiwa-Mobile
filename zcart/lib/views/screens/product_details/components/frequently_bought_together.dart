import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class FrequentlyBoughtTogetherCard extends StatelessWidget {
  final ProductDetailsModel details;
  const FrequentlyBoughtTogetherCard({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return details.data!.linkedItems!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.frequently_bought_together.tr(),
                      style: context.textTheme.subtitle2!
                          .copyWith(color: kPrimaryFadeTextColor))
                  .pOnly(top: 10, left: 10, bottom: 5),
              ProductDetailsCardGridView(
                      productList: details.data!.linkedItems!)
                  .px(8),
            ],
          )
        : const SizedBox();
  }
}

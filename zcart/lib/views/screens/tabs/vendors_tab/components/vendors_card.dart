import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';

class VendorCard extends StatelessWidget {
  final String? logo;
  final String? name;
  final bool? isVerified;
  final String? verifiedText;
  final String? rating;
  final Function? onTap;
  final bool trailingEnabled;

  const VendorCard(
      {Key? key,
      this.logo,
      this.name,
      this.isVerified = false,
      this.verifiedText,
      this.rating,
      this.onTap,
      this.trailingEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                blurRadius: 20,
                color: kDarkColor.withOpacity(0.1),
                spreadRadius: 3,
                offset: const Offset(1, 1)),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.network(
            logo!,
            width: context.screenWidth * 0.15,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const Icon(
                Icons.image_not_supported,
              );
            },
          ).p(10),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name!,
                style: context.textTheme.headline6!,
              ),
              isVerified!
                  ? Icon(Icons.check_circle, color: kPrimaryColor, size: 15)
                      .px2()
                      .pOnly(top: 3)
                      .onInkTap(() {
                      toast(verifiedText);
                    })
                  : Container()
            ],
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating: double.parse(rating ?? '0.0'),
                minRating: 0,
                direction: Axis.horizontal,
                ignoreGestures: true,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 12,
                itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => print(rating),
              ),
              const SizedBox(width: 5),
              Text(
                rating ?? '',
                style: context.textTheme.overline!.copyWith(
                    color: getColorBasedOnTheme(
                        context, kPriceColor, kDarkPriceColor)),
              ).visible(rating != null),
            ],
          ),
          trailing: trailingEnabled
              ? const Icon(Icons.arrow_forward_ios, size: 15).pOnly(right: 10)
              : null,
          onTap: onTap as void Function()?,
        )).cornerRadius(10).py(5).px(10);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/search/search_screen.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          width: 50,
          child: Image.asset(AppImages.logo),
        ).pOnly(left: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => context.nextPage(const SearchScreen()),
            child: Container(
              decoration: customBoxDecoration.copyWith(
                color: getColorBasedOnTheme(
                    context, kLightBgColor, kDarkCardBgColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 18,
                        color: kFadeColor,
                      ),
                      Text(
                        LocaleKeys.search_keyword.tr(),
                        style: context.textTheme.subtitle2!
                            .copyWith(color: kPrimaryFadeTextColor),
                      ).px(5),
                    ],
                  ).p(10),
                  IconButton(
                      onPressed: () {
                        //TODO: Add Image Search
                        context.nextPage(const SearchScreen());
                      },
                      icon: const Icon(
                        CupertinoIcons.camera,
                        size: 18,
                        color: kFadeColor,
                      ))
                ],
              ),
            ).pSymmetric(h: 10, v: 8),
          ),
        ),
      ],
    );
  }
}

var customBoxDecoration = BoxDecoration(
  color: kLightColor,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
        blurRadius: 20,
        color: kDarkColor.withOpacity(0.1),
        spreadRadius: 3,
        offset: const Offset(1, 1)),
  ],
);

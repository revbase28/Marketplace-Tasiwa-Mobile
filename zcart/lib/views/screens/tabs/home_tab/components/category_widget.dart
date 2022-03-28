import 'package:flutter/material.dart';
import 'package:zcart/data/models/categories/category_model.dart';
import 'package:zcart/helper/category_icons.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/categories/categories_page.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/search_bar.dart';

class CategoryWidget extends StatelessWidget {
  final List<CategoryList> categoryList;

  const CategoryWidget(this.categoryList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
          itemCount: categoryList.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: customBoxDecoration.copyWith(
                color: getColorBasedOnTheme(
                    context, kLightColor, kDarkCardBgColor),
              ),
              width: 150,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    getCategoryIcon(categoryList[index].icon),
                    color: getColorBasedOnTheme(
                        context, kDarkBgColor, kLightColor),
                  ).pOnly(bottom: 5),
                  Text(
                    categoryList[index].name!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.subtitle2!.copyWith(),
                  ),
                ],
              )),
            )
                .onInkTap(() {
                  context.nextPage(CategoriesPage(
                    selectedIndex: index == 0 ? 0 : index - 1,
                  ));
                })
                .cornerRadius(10)
                .pOnly(right: 10);
          }),
    );
  }
}

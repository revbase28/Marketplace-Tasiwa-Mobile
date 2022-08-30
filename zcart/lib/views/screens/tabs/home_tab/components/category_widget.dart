import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/models/categories/category_model.dart';
import 'package:zcart/helper/category_icons.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zcart/views/screens/tabs/home_tab/categories/categoris_list_screen.dart';
import 'package:zcart/views/screens/tabs/home_tab/categories/category_details_screen.dart';
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
                  const SizedBox(height: 4),
                  Expanded(
                    child: Center(
                      child: categoryList[index].iconImage == null
                          ? FaIcon(
                              getCategoryIcon(categoryList[index].icon),
                              color: getColorBasedOnTheme(
                                  context, kDarkBgColor, kLightColor),
                            )
                          : CachedNetworkImage(
                              imageUrl: categoryList[index].iconImage!,
                              errorWidget: (context, url, error) => FaIcon(
                                getCategoryIcon(categoryList[index].icon),
                                color: getColorBasedOnTheme(
                                    context, kDarkBgColor, kLightColor),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    categoryList[index].name!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(),
                  ),
                ],
              )),
            )
                .onInkTap(() {
                  // context.nextPage(CategoriesPage(
                  //   selectedIndex: index == 0 ? 0 : index - 1,
                  // ));

                  if (index > 0) {
                    final e = categoryList[index];
                    context
                        .read(subgroupCategoryNotifierProvider.notifier)
                        .resetState();
                    context
                        .read(categorySubgroupNotifierProvider.notifier)
                        .getCategorySubgroup(e.id.toString());
                    context
                        .read(productListNotifierProvider.notifier)
                        .getProductList('category-grp/${e.slug}');
                    context.nextPage(CategoryDetailsScreen(
                      categoryListItem: categoryList[index],
                    ));
                  } else {
                    context.nextPage(const CategoryListScreen());
                  }
                })
                .cornerRadius(10)
                .pOnly(right: 10);
          }),
    );
  }
}

class CategoryLoadingWidget extends StatelessWidget {
  const CategoryLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: context.screenHeight * .1,
        child: ListView.builder(
            itemCount: 8,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (BuildContext context, int index) {
              return Chip(
                backgroundColor: getColorBasedOnTheme(
                    context, kLightCardBgColor, kDarkCardBgColor),
                label: Text(
                  LocaleKeys.loading.tr(),
                ).pSymmetric(h: 12, v: 8),
              ).px(4);
            }),
      ),
    );
  }
}

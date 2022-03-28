import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/categories/category_model.dart';
import 'package:zcart/helper/category_icons.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/categories/category_details_screen.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/search_bar.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _categoryState = watch(categoryNotifierProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.categories.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: _categoryState is CategoryLoadedState
            ? _categoryState.categoryList.isEmpty
                ? const SizedBox()
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: _categoryState.categoryList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctx, index) {
                      return Container(
                        decoration: customBoxDecoration.copyWith(
                          boxShadow: [],
                          color: getColorBasedOnTheme(
                              context, kLightCardBgColor, kDarkCardBgColor),
                        ),
                        child: GridTile(
                          // header: Container(
                          //   height: 5,
                          //   decoration: BoxDecoration(
                          //       gradient: LinearGradient(colors: [
                          //         kAccentColor.withOpacity(0.7),
                          //         kPrimaryColor
                          //       ]),
                          //       borderRadius: BorderRadius.circular(30)),
                          // ).pOnly(top: 16, left: 112, right: 16),
                          child: Center(
                            child: FaIcon(
                              getCategoryIcon(
                                  _categoryState.categoryList[index].icon),
                              size: 35,
                              color: getColorBasedOnTheme(
                                  context, kDarkColor, kLightBgColor),
                            ),
                            // child: Image.network(
                            //   _categoryState.categoryList[index].coverImage ??
                            //       "",
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                          footer: Center(
                              child:
                                  Text(_categoryState.categoryList[index].name!)
                                      .pOnly(bottom: 24)),
                        ).onInkTap(() {
                          context
                              .read(subgroupCategoryNotifierProvider.notifier)
                              .resetState();
                          context
                              .read(categorySubgroupNotifierProvider.notifier)
                              .getCategorySubgroup(_categoryState
                                  .categoryList[index].id
                                  .toString());
                          context
                              .read(productListNotifierProvider.notifier)
                              .getProductList(
                                  'category-grp/${_categoryState.categoryList[index].slug}');
                          context.nextPage(CategoryDetailsScreen(
                              categoryListItem:
                                  _categoryState.categoryList[index]));
                        }),
                      ).p(10);
                    })
            : const Center(child: CircularProgressIndicator()));
  }
}

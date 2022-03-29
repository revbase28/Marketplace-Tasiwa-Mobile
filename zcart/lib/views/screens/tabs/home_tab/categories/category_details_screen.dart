import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/categories/category_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/category_widget.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final CategoryList categoryListItem;

  const CategoryDetailsScreen({Key? key, required this.categoryListItem})
      : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final categorySubgroupState = watch(categorySubgroupNotifierProvider);
    final subgroupCategoryState = watch(subgroupCategoryNotifierProvider);
    final productListState = watch(productListNotifierProvider);
    final scrollControllerProvider =
        watch(categoryDetailsScrollNotifierProvider.notifier);

    return ProviderListener<ScrollState>(
      provider: categoryDetailsScrollNotifierProvider,
      onChange: (context, state) {
        if (state is ScrollReachedBottomState) {
          context
              .read(productListNotifierProvider.notifier)
              .getMoreProductList();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: scrollControllerProvider.controller,
            child: Column(
              children: [
                /// Cover image
                Stack(
                  children: [
                    Container(
                      height: context.screenHeight * .15,
                      width: context.screenWidth,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(categoryListItem.coverImage!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            kDarkBgColor.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categoryListItem.name!,
                          style: context.textTheme.headline6!.copyWith(
                            color: kLightColor.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).pOnly(bottom: 5),
                    const Positioned(
                        child: BackButton(
                      color: kLightColor,
                    )),
                  ],
                ),

                (categorySubgroupState is CategorySubgroupInitialState ||
                        categorySubgroupState is CategorySubgroupLoadingState)
                    ? const CategoryLoadingWidget()
                    : categorySubgroupState is CategorySubgroupLoadedState
                        ? SizedBox(
                            height: context.screenHeight * .07,
                            child: ListView.builder(
                                itemCount: categorySubgroupState
                                    .categorysSubgroupList!.length,
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                itemBuilder: (BuildContext context, int index) {
                                  return ActionChip(
                                    backgroundColor: context
                                                .read(
                                                    categorySubgroupNotifierProvider
                                                        .notifier)
                                                .getSelectedSubgroup ==
                                            index
                                        ? kPrimaryColor
                                        : kLightCardBgColor,
                                    label: Text(
                                      categorySubgroupState
                                          .categorysSubgroupList![index].name!,
                                      style: TextStyle(
                                        color: context
                                                    .read(
                                                        categorySubgroupNotifierProvider
                                                            .notifier)
                                                    .getSelectedSubgroup ==
                                                index
                                            ? kPrimaryLightTextColor
                                            : getColorBasedOnTheme(context,
                                                kDarkColor, kLightColor),
                                      ),
                                    ).pSymmetric(h: 12, v: 8),
                                    onPressed: () {
                                      context
                                          .read(categorySubgroupNotifierProvider
                                              .notifier)
                                          .setSelectedSubgroup = index;
                                      context
                                          .read(subgroupCategoryNotifierProvider
                                              .notifier)
                                          .getSubgroupCategory(
                                              categorySubgroupState
                                                  .categorysSubgroupList![index]
                                                  .id
                                                  .toString());
                                      context
                                          .read(productListNotifierProvider
                                              .notifier)
                                          .getProductList(
                                              'category-subgrp/${categorySubgroupState.categorysSubgroupList![index].slug}');
                                    },
                                  ).px(4);
                                }),
                          ).px(10)
                        : categorySubgroupState is CategorySubgroupErrorState
                            ? ErrorMessageWidget(categorySubgroupState.message)
                            : const SizedBox(),

                /// Category under Subgroup
                subgroupCategoryState is SubgroupCategoryLoadingState
                    ? const CategoryLoadingWidget()
                    : subgroupCategoryState is SubgroupCategoryLoadedState
                        ? SizedBox(
                            height: context.screenHeight * .07,
                            child: ListView.builder(
                                itemCount: subgroupCategoryState
                                    .subgroupCategoryList!.length,
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                itemBuilder: (BuildContext context, int index) {
                                  return ActionChip(
                                    backgroundColor: context
                                                .read(
                                                    subgroupCategoryNotifierProvider
                                                        .notifier)
                                                .getSelectedSubgroupCategory ==
                                            index
                                        ? kPrimaryColor
                                        : kLightCardBgColor,
                                    label: Text(
                                      subgroupCategoryState
                                          .subgroupCategoryList![index].name!,
                                      style: TextStyle(
                                        color: context
                                                    .read(
                                                        subgroupCategoryNotifierProvider
                                                            .notifier)
                                                    .getSelectedSubgroupCategory ==
                                                index
                                            ? kPrimaryLightTextColor
                                            : getColorBasedOnTheme(context,
                                                kDarkColor, kLightColor),
                                      ),
                                    ).pSymmetric(h: 12, v: 8),
                                    onPressed: () {
                                      context
                                          .read(subgroupCategoryNotifierProvider
                                              .notifier)
                                          .setSelectedSubgroupCategory = index;
                                      context
                                          .read(productListNotifierProvider
                                              .notifier)
                                          .getProductList(
                                              'category/${subgroupCategoryState.subgroupCategoryList![index].slug}');
                                    },
                                  ).px(4);
                                  // return Container(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 10, vertical: 4),
                                  //         color: context
                                  //                     .read(
                                  //                         subgroupCategoryNotifierProvider)
                                  //                     .getSelectedSubgroupCategory ==
                                  //                 index
                                  //             ? kPrimaryColor.withOpacity(0.5)
                                  //             : kCardBgColor,
                                  //         child: Column(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.center,
                                  //           children: [
                                  //             Text(subgroupCategoryState
                                  //                 .subgroupCategoryList[index]
                                  //                 .name),
                                  //           ],
                                  //         ))
                                  //     .onInkTap(() {
                                  //       context
                                  //           .read(
                                  //               subgroupCategoryNotifierProvider)
                                  //           .setSelectedSubgroupCategory = index;
                                  //       context
                                  //           .read(productListNotifierProvider)
                                  //           .getProductList(
                                  //               'category/${subgroupCategoryState.subgroupCategoryList[index].slug}');
                                  //     })
                                  //     .cornerRadius(10)
                                  //     .pOnly(right: 10);
                                }),
                          ).px(10)
                        : const SizedBox(),

                /// Product List
                productListState is ProductListLoadedState
                    ? productListState.productList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              const Icon(Icons.info_outline),
                              Text(LocaleKeys.no_item_found.tr()),
                            ],
                          )
                        : ProductDetailsCardGridView(
                                productList: productListState.productList)
                            .px(8)
                    : const ProductLoadingWidget().px(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

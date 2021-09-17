import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/brand_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:velocity_x/velocity_x.dart';

class FeaturedBrands extends ConsumerWidget {
  const FeaturedBrands({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final featuredBrandsState = watch(featuredBrandsNotifierProvider);

    return featuredBrandsState is FeaturedBrandsLoadedState
        ? SizedBox(
            height: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(LocaleKeys.featured_brands.tr(),
                              style: context.textTheme.headline6!
                                  .copyWith(color: kPrimaryFadeTextColor))
                          .pOnly(bottom: 10),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.nextReplacementPage(
                            const BottomNavBar(selectedIndex: 2));
                      },
                      child: Text(
                        LocaleKeys.view_all.tr(),
                        style: context.textTheme.subtitle2!
                            .copyWith(color: kPrimaryFadeTextColor),
                      ).pSymmetric(v: 5),
                    ),
                  ],
                ),
                Flexible(
                  child: Container(
                    color:
                        EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                            ? kDarkCardBgColor
                            : kLightColor,
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        itemCount:
                            featuredBrandsState.featuredBrands!.data.length > 8
                                ? 8
                                : featuredBrandsState
                                    .featuredBrands!.data.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext ctx, index) {
                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: EasyDynamicTheme.of(context)
                                                      .themeMode ==
                                                  ThemeMode.dark
                                              ? kDarkBgColor
                                              : kFadeColor),
                                    ),
                                    child: Image.network(
                                      featuredBrandsState
                                          .featuredBrands!.data[index].image!,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const Center(
                                              child: Icon(Icons.image));
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  ).pOnly(bottom: 10),
                                ),
                                Text(
                                  featuredBrandsState
                                      .featuredBrands!.data[index].name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.subtitle2!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: EasyDynamicTheme.of(context)
                                                .themeMode ==
                                            ThemeMode.dark
                                        ? kFadeColor
                                        : kDarkColor,
                                  ),
                                )
                              ],
                            ),
                          ).onInkTap(() async {
                            context.nextPage(const BrandProfileScreen());
                            await context
                                .read(brandProfileNotifierProvider.notifier)
                                .getBrandProfile(featuredBrandsState
                                    .featuredBrands!.data[index].slug);

                            await context
                                .read(brandItemsListNotifierProvider.notifier)
                                .getBrandItemsList(featuredBrandsState
                                    .featuredBrands!.data[index].slug);
                          });
                        }).p(10),
                  ).cornerRadius(10),
                ),
              ],
            ),
          )
        : featuredBrandsState is FeaturedBrandsErrorState
            ? Container().p(10)
            : Container();
  }
}

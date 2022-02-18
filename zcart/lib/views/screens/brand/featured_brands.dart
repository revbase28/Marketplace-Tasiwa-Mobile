import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/brand_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/views/screens/tabs/brands_tab/brands_tab.dart';

class FeaturedBrands extends ConsumerWidget {
  const FeaturedBrands({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final featuredBrandsState = watch(featuredBrandsNotifierProvider);

    return featuredBrandsState is FeaturedBrandsLoadedState
        ? SizedBox(
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
                              .copyWith(color: kPrimaryFadeTextColor)),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.nextPage(const BrandsTab());
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
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2),
                      itemCount:
                          featuredBrandsState.featuredBrands!.data.length > 8
                              ? 8
                              : featuredBrandsState.featuredBrands!.data.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext ctx, index) {
                        return Card(
                          elevation: 5,
                          shadowColor: getColorBasedOnTheme(
                              context, Colors.black45, kDarkBgColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: getColorBasedOnTheme(
                              context, kLightColor, kDarkCardBgColor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: CachedNetworkImage(
                                    imageUrl: featuredBrandsState
                                        .featuredBrands!.data[index].image!,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) =>
                                        const SizedBox(),
                                    progressIndicatorBuilder:
                                        (context, url, progress) => Center(
                                      child: CircularProgressIndicator(
                                          value: progress.progress),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    color: getColorBasedOnTheme(
                                        context, kLightBgColor, kDarkBgColor)),
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  featuredBrandsState
                                      .featuredBrands!.data[index].name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.caption!,
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
                      }),
                ),
              ],
            ),
          )
        : featuredBrandsState is FeaturedBrandsErrorState
            ? const SizedBox().p(10)
            : const SizedBox();
  }
}

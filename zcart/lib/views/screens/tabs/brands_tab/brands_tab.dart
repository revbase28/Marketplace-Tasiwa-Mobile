import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/brand_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:velocity_x/velocity_x.dart';

class BrandsTab extends ConsumerWidget {
  const BrandsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final brandsState = watch(allBrandsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.brands.tr()),
      ),
      body: brandsState is BrandsLoadedState
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: brandsState.allBrands!.data.length,
              itemBuilder: (context, index) {
                final brand = brandsState.allBrands!.data[index];
                return GestureDetector(
                  onTap: () async {
                    context.nextPage(const BrandProfileScreen());
                    await context
                        .read(brandProfileNotifierProvider.notifier)
                        .getBrandProfile(brand.slug);

                    await context
                        .read(brandItemsListNotifierProvider.notifier)
                        .getBrandItemsList(brand.slug);
                  },
                  child: Card(
                    elevation: 3,
                    shadowColor: kDarkColor.withOpacity(0.26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: getColorBasedOnTheme(
                        context, kLightColor, kDarkCardBgColor),
                    child: GridTile(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CachedNetworkImage(
                              imageUrl: brand.image!,
                              errorWidget: (context, url, error) =>
                                  const SizedBox(),
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                    value: progress.progress),
                              ),
                            ),
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  brand.name!,
                                  maxLines: null,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.subtitle2!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ).pOnly(bottom: 5, top: 5),
                        ],
                      ).p(10),
                    ),
                  ),
                );
              },
            ).px(10)
          : brandsState is BrandsErrorState
              ? ErrorMessageWidget(brandsState.message)
              : const SizedBox(),
    );
  }
}

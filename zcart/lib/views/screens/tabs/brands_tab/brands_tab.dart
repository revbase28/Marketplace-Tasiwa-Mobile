import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/brand/all_brands_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/brand_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/brand_profile.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';

class BrandsTab extends StatefulWidget {
  const BrandsTab({Key? key}) : super(key: key);

  @override
  State<BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends State<BrandsTab> {
  bool _showSearchBar = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final brandsState = watch(allBrandsNotifierProvider);
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Text(LocaleKeys.brands.tr()),
            actions: [
              CupertinoButton(
                child: Icon(!_showSearchBar ? Icons.search : Icons.search_off,
                    color: kLightColor),
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                  });
                },
              ),
            ],
          ),
          body: brandsState is BrandsLoadedState
              ? BrandListBody(
                  allBrands: brandsState.allBrands!,
                  showSearchBar: _showSearchBar)
              : brandsState is BrandsErrorState
                  ? ErrorMessageWidget(brandsState.message)
                  : const SizedBox(),
        ),
      );
    });
  }
}

class BrandListBody extends StatefulWidget {
  final AllBrands allBrands;
  final bool showSearchBar;
  const BrandListBody({
    Key? key,
    required this.allBrands,
    required this.showSearchBar,
  }) : super(key: key);

  @override
  _BrandListBodyState createState() => _BrandListBodyState();
}

class _BrandListBodyState extends State<BrandListBody> {
  final _searchController = TextEditingController();
  final List<Brands> _brandsList = [];

  @override
  void initState() {
    _brandsList.addAll(widget.allBrands.data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearchBar) const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(sizeFactor: animation, child: child);
          },
          child: widget.showSearchBar
              ? Padding(
                  key: const ValueKey("SearchBar"),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField(
                    controller: _searchController,
                    autoFocus: widget.showSearchBar,
                    hintText: LocaleKeys.search_brand.tr(),
                    onChanged: (value) {
                      setState(() {
                        _brandsList.clear();
                        _brandsList.addAll(widget.allBrands.data.where(
                            (vendor) => vendor.name!
                                .toLowerCase()
                                .contains(value.toLowerCase())));
                      });
                    },
                  ),
                )
              : const SizedBox(
                  key: ValueKey("NoSearchBar"),
                ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _brandsList.length,
            itemBuilder: (context, index) {
              final brand = _brandsList[index];
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
                  elevation: 5,
                  shadowColor: getColorBasedOnTheme(
                      context, Colors.black26, kDarkBgColor),
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
                        padding: const EdgeInsets.all(16.0),
                        child: CachedNetworkImage(
                          imageUrl: brand.image!,
                          errorWidget: (context, url, error) =>
                              const SizedBox(),
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                                value: progress.progress),
                          ),
                        ),
                      )),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: getColorBasedOnTheme(
                                context, kLightBgColor, kDarkBgColor)),
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          (brand.name ?? ""),
                          maxLines: null,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: context.textTheme.subtitle2!.copyWith(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).px(10),
        ),
      ],
    );
  }
}

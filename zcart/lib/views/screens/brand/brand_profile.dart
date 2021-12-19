import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/brand/brand_profile_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/riverpod/providers/brand_provider.dart';
import 'package:zcart/riverpod/state/brand_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/brand/brand_items_list.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';

class BrandProfileScreen extends ConsumerWidget {
  const BrandProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final brandProfileState = watch(brandProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            brandProfileState is BrandProfileLoadedState
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: context.screenHeight * .25,
                            width: context.screenWidth,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(brandProfileState
                                    .brandProfile.data!.coverImage!),
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
                                brandProfileState.brandProfile.data!.name!,
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

                      //Name
                      ListTile(
                        title: Text(
                          brandProfileState.brandProfile.data!.name!,
                          style: context.textTheme.headline6!,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          width: context.screenWidth * .10,
                          child: CachedNetworkImage(
                            imageUrl:
                                brandProfileState.brandProfile.data!.image!,
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: CircularProgressIndicator(
                                  value: progress.progress),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ).p(10),

                      Container(
                        color: getColorBasedOnTheme(
                            context, kLightColor, kDarkBgColor),
                        child: Column(
                          children: [
                            BrandDetailsRowItem(
                              title: LocaleKeys.origin.tr(),
                              value:
                                  brandProfileState.brandProfile.data!.origin ??
                                      LocaleKeys.not_available.tr(),
                            ).py(5),
                            BrandDetailsRowItem(
                              title: LocaleKeys.available_from.tr(),
                              value: brandProfileState
                                      .brandProfile.data!.availableFrom ??
                                  LocaleKeys.not_available.tr(),
                            ).py(5),
                            BrandDetailsRowItem(
                              title: LocaleKeys.url.tr(),
                              value: brandProfileState.brandProfile.data!.url ??
                                  LocaleKeys.not_available.tr(),
                            ).py(5),
                            BrandDetailsRowItem(
                              title: LocaleKeys.product_count.tr(),
                              value: brandProfileState
                                      .brandProfile.data!.listingCount ??
                                  LocaleKeys.not_available.tr(),
                            ).py(5),
                          ],
                        ).px(16).py(10),
                      ).cornerRadius(10).py(5).px(10),

                      BrandDescription(
                              brandProfile: brandProfileState.brandProfile)
                          .cornerRadius(10)
                          .py(5)
                          .px(10),

                      const BrandItemsListView(),
                    ],
                  )
                : brandProfileState is BrandProfileLoadingState ||
                        brandProfileState is BrandProfileInitialState
                    ? const ProductLoadingWidget().px(10)
                    : brandProfileState is BrandProfileErrorState
                        ? Center(
                            child: Column(
                              children: [
                                const Icon(Icons.info_outline),
                                Text(LocaleKeys.something_went_wrong.tr()),
                              ],
                            ),
                          ).px(10)
                        : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class BrandDescription extends StatelessWidget {
  const BrandDescription({
    Key? key,
    required this.brandProfile,
  }) : super(key: key);

  final BrandProfile brandProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: ListTile(
        title: Text(LocaleKeys.description.tr()).py(5),
        subtitle: HtmlWidget(
          brandProfile.data!.description ?? "",
          enableCaching: true,
          onTapUrl: (url) {
            launchURL(url);
            return true;
          },
        ),
      ),
    );
  }
}

class BrandDetailsRowItem extends StatelessWidget {
  const BrandDetailsRowItem({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title  :  ",
          style: context.textTheme.subtitle2,
        ),
        Flexible(
          child: SelectableText(
            value,
            style: context.textTheme.subtitle2,
          ),
        )
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/vendors/vendor_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/riverpod/state/vendors_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zcart/views/shared_widgets/system_config_builder.dart';
import 'components/vendors_activity_card.dart';
import 'components/vendors_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorsAboutUsScreen extends StatelessWidget {
  final VendorDetails? vendorDetails;
  final VoidCallback onPressedContact;
  const VendorsAboutUsScreen({
    Key? key,
    this.vendorDetails,
    required this.onPressedContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: context.screenHeight * .25,
                  width: context.screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(vendorDetails!.bannerImage!),
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
                      vendorDetails!.name!,
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
            Stack(
              alignment: Alignment.center,
              children: [
                VendorCard(
                  logo: vendorDetails!.image,
                  name: vendorDetails!.name,
                  verifiedText: vendorDetails!.verifiedText,
                  isVerified: vendorDetails!.verified,
                  rating: vendorDetails!.rating,
                  trailingEnabled: false,
                ),
                SystemConfigBuilder(
                  builder: (context, systemConfig) {
                    return systemConfig?.enableChat == true
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: IconButton(
                                tooltip: LocaleKeys.contact_shop.tr(),
                                onPressed: onPressedContact,
                                icon: const Icon(CupertinoIcons.chat_bubble_2),
                              ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 5, bottom: 10),
              child: VendorsActivityCard(
                activeListCount: vendorDetails!.activeListingsCount ?? 0,
                rating: vendorDetails!.rating ?? '0',
                itemsSold: vendorDetails!.soldItemCount ?? 0,
              ),
            ),
            VendorRatingsAndReview(
              vendorSlug: vendorDetails!.slug!,
              feedbacks: vendorDetails!.feedbacks ?? [],
              feedbacksCount: vendorDetails!.feedbacksCount ?? 0,
            ).cornerRadius(10).pSymmetric(h: 10),
            Container(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.description.tr(),
                      style: context.textTheme.headline6),
                  const SizedBox(height: 10),
                  ResponsiveTextWidget(
                      title: vendorDetails!.description,
                      textStyle: context.textTheme.subtitle2!)
                ],
              ),
            ).cornerRadius(10).p(10),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class VendorRatingsAndReview extends StatelessWidget {
  final String vendorSlug;
  final List<VendorDetailsFeedback> feedbacks;
  final int feedbacksCount;
  const VendorRatingsAndReview({
    Key? key,
    required this.vendorSlug,
    required this.feedbacks,
    required this.feedbacksCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${LocaleKeys.rating_and_reviews.tr()} ($feedbacksCount)',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: feedbacks.isEmpty
                      ? null
                      : () {
                          context
                              .read(vendorReviewsNotifierProvider.notifier)
                              .getVendorReviews(vendorSlug);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const _VendorRatingAndReviewAllPage()));
                        },
                  child: Text(LocaleKeys.view_all.tr(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: feedbacks.isEmpty ? null : kPrimaryColor,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          feedbacks.isEmpty
              ? const SizedBox()
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 0,
                  ),
                ),
          feedbacks.isEmpty ? const SizedBox() : const SizedBox(height: 10),
          for (var feedBack in feedbacks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _RatingAndReviewSection(feedBack: feedBack),
            ),
        ],
      ),
    );
  }
}

class _VendorRatingAndReviewAllPage extends ConsumerWidget {
  const _VendorRatingAndReviewAllPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _vendorReviews = watch(vendorReviewsNotifierProvider);
    final _scrollStateNotifier =
        watch(vendorReviewsScrollNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.rating_and_reviews.tr()),
        actions: [
          IconButton(
              onPressed: () {
                context
                    .read(vendorReviewsNotifierProvider.notifier)
                    .getMoreVendorReviews();
              },
              icon: const Icon(Icons.sync)),
        ],
      ),
      body: _vendorReviews is VendorFeedbackLoadedState
          ? ProviderListener<ScrollState>(
              onChange: (context, state) {
                if (state is ScrollReachedBottomState) {
                  context
                      .read(vendorReviewsNotifierProvider.notifier)
                      .getMoreVendorReviews();
                }
              },
              provider: vendorReviewsScrollNotifierProvider,
              child: ListView(
                controller: _scrollStateNotifier.controller,
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  for (var feedBack in _vendorReviews.vendorFeedback)
                    _RatingAndReviewSection(feedBack: feedBack),
                ],
              ),
            )
          : const Center(child: LoadingWidget()),
    );
  }
}

class _RatingAndReviewSection extends StatelessWidget {
  final dynamic feedBack;
  const _RatingAndReviewSection({
    Key? key,
    required this.feedBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.unknown.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  feedBack.updatedAt ?? '',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            RatingBar.builder(
              initialRating: feedBack.rating?.toDouble() ?? 0.0,
              minRating: 0,
              direction: Axis.horizontal,
              wrapAlignment: WrapAlignment.center,
              allowHalfRating: true,
              ignoreGestures: true,
              itemCount: 5,
              itemSize: 12,
              unratedColor: kFadeColor,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: kDarkPriceColor),
              onRatingUpdate: (rating) => debugPrint(rating.toString()),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          feedBack.comment ?? "",
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

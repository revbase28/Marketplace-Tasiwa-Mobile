import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/vendors/vendor_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'components/vendors_activity_card.dart';
import 'components/vendors_card.dart';

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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      tooltip: "Contact Shop",
                      onPressed: onPressedContact,
                      icon: const Icon(CupertinoIcons.bubble_left),
                    ),
                  ),
                )
              ],
            ),
            VendorsActivityCard(
              activeListCount: vendorDetails!.activeListingsCount ?? 0,
              rating: vendorDetails!.rating ?? '0',
              itemsSold: vendorDetails!.soldItemCount ?? 0,
            ),
            VendorRatingsAndReview(feedbacks: vendorDetails!.feedbacks ?? [])
                .cornerRadius(10)
                .pSymmetric(h: 10),
            Container(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.description.tr(),
                          style: context.textTheme.bodyText2)
                      .py(5),
                  ResponsiveTextWidget(
                      title: vendorDetails!.description,
                      textStyle: context.textTheme.caption!)
                ],
              ),
            ).cornerRadius(10).p(10),
          ],
        ),
      ),
    );
  }
}

class VendorRatingsAndReview extends StatelessWidget {
  final List<VendorDetailsFeedback> feedbacks;
  const VendorRatingsAndReview({
    Key? key,
    required this.feedbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _feedbacks =
        feedbacks.length < 3 ? feedbacks : feedbacks.sublist(0, 3);
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
                'Ratings & Reviews (${feedbacks.length})',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: _feedbacks.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => _RatingAndReviewAllPage(
                                      feedbacks: feedbacks)));
                        },
                  child: Text(LocaleKeys.view_all.tr(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: _feedbacks.isEmpty ? null : kPrimaryColor,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          _feedbacks.isEmpty
              ? const SizedBox()
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 0,
                  ),
                ),
          _feedbacks.isEmpty ? const SizedBox() : const SizedBox(height: 10),
          for (var feedBack in _feedbacks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _RatingAndReviewSection(feedBack: feedBack),
            ),
        ],
      ),
    );
  }
}

class _RatingAndReviewAllPage extends StatelessWidget {
  final List<VendorDetailsFeedback> feedbacks;
  const _RatingAndReviewAllPage({
    Key? key,
    required this.feedbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
        title: const Text('Ratings & Reviews'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var feedBack in feedbacks)
            _RatingAndReviewSection(feedBack: feedBack),
        ],
      ),
    );
  }
}

class _RatingAndReviewSection extends StatelessWidget {
  const _RatingAndReviewSection({
    Key? key,
    required this.feedBack,
  }) : super(key: key);

  final VendorDetailsFeedback feedBack;

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
                  'Unknown',
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
                  Icon(Icons.star, color: kPrimaryColor),
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

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductRatingsAndReview extends StatelessWidget {
  final List<FeedBack> feedbacks;
  const ProductRatingsAndReview({
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RatingAndReviewAllPage(feedbacks: feedbacks)));
                  },
                  child: Text(LocaleKeys.view_all.tr(),
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: kPrimaryColor, fontWeight: FontWeight.bold))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              height: 0,
            ),
          ),
          const SizedBox(height: 10),
          for (var feedBack in _feedbacks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: RatingAndReviewSection(feedBack: feedBack),
            ),
        ],
      ),
    );
  }
}

class RatingAndReviewAllPage extends StatelessWidget {
  final List<FeedBack> feedbacks;
  const RatingAndReviewAllPage({
    Key? key,
    required this.feedbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var feedBack in feedbacks)
            RatingAndReviewSection(feedBack: feedBack),
        ],
      ),
    );
  }
}

class RatingAndReviewSection extends StatelessWidget {
  const RatingAndReviewSection({
    Key? key,
    required this.feedBack,
  }) : super(key: key);

  final FeedBack feedBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                feedBack.customer?.avatar == null
                    ? const SizedBox()
                    : CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            NetworkImage(feedBack.customer?.avatar ?? ''),
                      ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedBack.customer?.name ?? 'Unknown',
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

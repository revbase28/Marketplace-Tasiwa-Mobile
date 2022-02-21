import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/product_reviews_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/product/product_reviews_state.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class ProductRatingsAndReview extends StatelessWidget {
  final String productSlug;
  final List<ProductDetailsFeedBack> feedbacks;
  final int feedBackCount;
  const ProductRatingsAndReview({
    Key? key,
    required this.productSlug,
    required this.feedbacks,
    required this.feedBackCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.rating_and_reviews.tr(),
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    context
                        .read(productReviewsNotifierProvider.notifier)
                        .getProductReviews(productSlug);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ProductRatingAndReviewAllPage()));
                  },
                  child: Text(LocaleKeys.view_all.tr() + ' ($feedBackCount)',
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
          for (var feedBack in feedbacks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: RatingAndReviewSection(feedBack: feedBack),
            ),
        ],
      ),
    );
  }
}

class ProductRatingAndReviewAllPage extends ConsumerWidget {
  const ProductRatingAndReviewAllPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _productReviews = watch(productReviewsNotifierProvider);

    final _scrollControllerProvider =
        watch(productReviewsScrollNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.rating_and_reviews.tr()),
        actions: [
          IconButton(
              onPressed: () {
                context
                    .read(productReviewsNotifierProvider.notifier)
                    .getMoreProductReviews();
              },
              icon: const Icon(Icons.sync)),
        ],
      ),
      body: _productReviews is ProductReviewsLoadedState
          ? ProviderListener<ScrollState>(
              onChange: (context, state) {
                if (state is ScrollReachedBottomState) {
                  context
                      .read(productReviewsNotifierProvider.notifier)
                      .getMoreProductReviews();
                }
              },
              provider: productReviewsScrollNotifierProvider,
              child: ListView(
                controller: _scrollControllerProvider.controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  for (var feedBack in _productReviews.reviews)
                    RatingAndReviewSection(feedBack: feedBack),
                ],
              ),
            )
          : const Center(child: LoadingWidget()),
    );
  }
}

class RatingAndReviewSection extends StatelessWidget {
  final dynamic feedBack;
  const RatingAndReviewSection({
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
                      feedBack.customer?.name ?? LocaleKeys.unknown.tr(),
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

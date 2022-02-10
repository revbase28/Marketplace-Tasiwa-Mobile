import 'package:zcart/data/models/product/product_reviews_model.dart';

abstract class ProductReviewsState {
  const ProductReviewsState();
}

class ProductReviewsInitialState extends ProductReviewsState {
  const ProductReviewsInitialState();
}

class ProductReviewsLoadingState extends ProductReviewsState {
  const ProductReviewsLoadingState();
}

class RandomMoreItemLoadingState extends ProductReviewsState {
  const RandomMoreItemLoadingState();
}

class ProductReviewsLoadedState extends ProductReviewsState {
  final List<ProductReview> reviews;

  const ProductReviewsLoadedState(this.reviews);
}

class ProductReviewsErrorState extends ProductReviewsState {
  final String message;

  const ProductReviewsErrorState(this.message);
}

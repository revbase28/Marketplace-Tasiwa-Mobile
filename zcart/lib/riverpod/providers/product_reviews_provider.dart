import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/repository/product/product_feedback_repository.dart';
import 'package:zcart/riverpod/notifier/product/product_review_state_notifier.dart';
import 'package:zcart/riverpod/state/product/product_reviews_state.dart';

final productReviewsRepositoryProvider =
    Provider<IProductReviewsRepository>((ref) {
  return ProductReviewsRepository();
});

final productReviewsNotifierProvider =
    StateNotifierProvider<ProductReviewsNotifier, ProductReviewsState>((ref) {
  return ProductReviewsNotifier(ref.read(productReviewsRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/product/product_reviews_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class ProductReviewsNotifier extends StateNotifier<ProductReviewsState> {
  final IProductReviewsRepository _iProductReviewsRepository;

  ProductReviewsNotifier(this._iProductReviewsRepository)
      : super(const ProductReviewsInitialState());

  Future<void> getProductReviews(String slug) async {
    try {
      state = const ProductReviewsLoadingState();
      final _reviews = await _iProductReviewsRepository.fetchReviews(slug);
      state = ProductReviewsLoadedState(_reviews);
    } on NetworkException {
      state = ProductReviewsErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> getMoreProductReviews() async {
    try {
      final _reviews = await _iProductReviewsRepository.fetchMoreReviews();
      state = ProductReviewsLoadedState(_reviews);
    } on NetworkException {
      state = ProductReviewsErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_vendors_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/vendors_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class VendorReviewsNotifier extends StateNotifier<VendorFeedbackState> {
  final IVendorReviewsRepository _iVendorReviewsRepository;

  VendorReviewsNotifier(this._iVendorReviewsRepository)
      : super(const VendorFeedbackInitialState());

  Future<void> getVendorReviews(String slug) async {
    try {
      state = const VendorFeedbackLoadingState();
      final vendorReviews =
          await _iVendorReviewsRepository.fetchVendorReviews(slug);
      state = VendorFeedbackLoadedState(vendorReviews);
    } on NetworkException {
      state = VendorFeedbackErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> getMoreVendorReviews() async {
    try {
      final vendorReviews =
          await _iVendorReviewsRepository.fetchMoreVendorReviews();
      state = VendorFeedbackLoadedState(vendorReviews);
    } on NetworkException {
      state = VendorFeedbackErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

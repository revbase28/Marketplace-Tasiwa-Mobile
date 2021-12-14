import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/riverpod/state/product/recently_viewed_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class RecentlyViewdNotifier extends StateNotifier<RecentlyViewedState> {
  final IRecentlyViewedRepository _iRecentlyViewdRepository;

  RecentlyViewdNotifier(this._iRecentlyViewdRepository)
      : super(const RecentlyViewedInitialState());

  Future<void> getRecentlyViwedItems(List<String> productList) async {
    try {
      state = const RecentlyViewedLoadingState();
      final recentItems =
          await _iRecentlyViewdRepository.fetchRecentlyViewedItems(productList);
      state = RecentlyViewedLoadedState(recentItems);
    } on NetworkException {
      state = RecentlyViewedErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

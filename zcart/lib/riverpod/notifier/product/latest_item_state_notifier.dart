import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/product/latest_item_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class LatestItemNotifier extends StateNotifier<LatestItemState> {
  final ILatestItemRepository _iLatestItemRepository;

  LatestItemNotifier(this._iLatestItemRepository)
      : super(const LatestItemInitialState());

  Future<void> getLatestItem() async {
    try {
      state = const LatestItemLoadingState();
      final latestItems = await _iLatestItemRepository.fetchLatestItems();
      state = LatestItemLoadedState(latestItems);
    } on NetworkException {
      state = LatestItemErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

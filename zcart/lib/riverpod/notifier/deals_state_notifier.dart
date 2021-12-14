import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_deals_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/deals_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class DealsUnderThePriceNotifier
    extends StateNotifier<DealsUnderThePriceState> {
  final IDealsRepository _iDealsRepository;

  DealsUnderThePriceNotifier(this._iDealsRepository)
      : super(const DealsUnderThePriceStateInitialState());

  Future<void> getAllDealsUnderThePrice() async {
    try {
      state = const DealsUnderThePriceStateLoadingState();
      final deals = await _iDealsRepository.fetchDealsUnderThePrice();
      state = DealsUnderThePriceStateLoadedState(deals);
    } on NetworkException {
      state = DealsUnderThePriceStateErrorState(
          LocaleKeys.something_went_wrong.tr());
    }
  }
}

class DealOfTheDayNotifier extends StateNotifier<DealOfTheDayState> {
  final IDealsRepository _iDealsRepository;

  DealOfTheDayNotifier(this._iDealsRepository)
      : super(const DealOfTheDayStateInitialState());

  Future<void> getDealOfTheDay() async {
    try {
      state = const DealOfTheDayStateLoadingState();
      final deal = await _iDealsRepository.fetchDealOfTheDay();
      state = DealOfTheDayStateLoadedState(deal);
    } on NetworkException {
      state = DealOfTheDayStateErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

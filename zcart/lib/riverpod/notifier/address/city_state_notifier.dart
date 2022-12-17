import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_address_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/address/city_state.dart';
import 'package:zcart/riverpod/state/address/country_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/translations/locale_keys.g.dart';

class CityNotifier extends StateNotifier<CityState> {
  final IAddressRepository _iAddressRepository;

  CityNotifier(this._iAddressRepository)
      : super(const CityInitialState());

  Future getCities(int? stateId) async {
    try {
      state = const CityLoadingState();
      final cities = await _iAddressRepository.fetchCity(stateId);
      state = CityLoadedState(cities);
    } on NetworkException {
      state = CityErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

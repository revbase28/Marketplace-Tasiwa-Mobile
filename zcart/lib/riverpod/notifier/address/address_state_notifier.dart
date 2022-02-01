import 'package:zcart/data/interface/i_address_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

// class ShippingNotifier extends StateNotifier<ShippingState> {
//   final IAddressRepository _iAddressRepository;

//   ShippingNotifier(this._iAddressRepository)
//       : super(const ShippingInitialState());

//   Future fetchShippingInfo(
//       {required String shopId, required String zoneId}) async {
//     try {
//       state = const ShippingLoadingState();
//       final shippingInfo =
//           await _iAddressRepository.fetchShippingInfo(shopId, zoneId);
//       state = ShippingLoadedState(shippingInfo);
//     } on NetworkException {
//       state = ShippingErrorState(LocaleKeys.something_went_wrong.tr());
//     }
//   }

//   Future fetchShippingOptions(id, countryId, stateId) async {
//     try {
//       state = const ShippingLoadingState();
//       final shippingOptions = await _iAddressRepository.fetchShippingOptions(
//           id, countryId, stateId);
//       state = ShippingOptionsLoadedState(shippingOptions);
//     } on NetworkException {
//       state = ShippingErrorState(LocaleKeys.something_went_wrong.tr());
//     }
//   }
// }

class PaymentOptionsNotifier extends StateNotifier<PaymentOptionsState> {
  final IAddressRepository _iAddressRepository;

  PaymentOptionsNotifier(this._iAddressRepository)
      : super(const PaymentOptionsInitialState());

  Future fetchPaymentMethod({required String cartId}) async {
    try {
      state = const PaymentOptionsLoadingState();
      final paymentOptions =
          await _iAddressRepository.fetchPaymentMethods(cartId: cartId);
      state = PaymentOptionsLoadedState(paymentOptions);
    } on NetworkException {
      state = PaymentOptionsErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

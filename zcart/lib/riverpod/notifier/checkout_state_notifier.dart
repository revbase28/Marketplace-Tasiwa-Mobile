import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/iCheckout_repository.dart';
import 'package:zcart/riverpod/state/checkout_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ICheckoutRepository _iCheckoutRepository;

  CheckoutNotifier(this._iCheckoutRepository)
      : super(const CheckoutInitialState());

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  int? cartId;
  int? shipTo;
  dynamic paymentMethod;
  dynamic shippingOptionId;
  dynamic packagingId;
  dynamic buyerNote;
  dynamic deviceId;
  String? email;
  bool? agreeToTerms;
  bool? createAccount;
  File? prescription;
  String? password;
  String? passwordConfirm;
  String? addressTitle;
  String? addressLine1;
  String? addressLine2;
  int? countryId;
  int? stateId;
  String? city;
  String? zipCode;
  String? phone;

  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo _androidInfo = await _deviceInfo.androidInfo;
      return _androidInfo.androidId;
    } else {
      IosDeviceInfo _iosInfo = await _deviceInfo.iosInfo;
      return _iosInfo.identifierForVendor;
    }
  }

  Future checkout() async {
    deviceId = await _getDeviceId();
    var requestBody = {
      "ship_to": shipTo.toString(),
      "payment_method": paymentMethod.toString(),
      "shipping_option_id": shippingOptionId.toString(),
      "packaging_id": packagingId.toString(),
      "agree": "1",
      "device_id": deviceId.toString(),
      if (prescription != null) "prescription": prescription.toString(),
      if (buyerNote != null) "buyer_note": buyerNote
    };
    try {
      // ignore: prefer_const_constructors
      state = CheckoutLoadingState();
      await _iCheckoutRepository.checkout(cartId!, requestBody);

      state = CheckoutLoadedState();
    } catch (e) {
      state = CheckoutErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> guestCheckout() async {
    deviceId = await _getDeviceId();
    var requestBody = {
      "payment_method": paymentMethod.toString(),
      "shipping_option_id": shippingOptionId.toString(),
      "packaging_id": packagingId.toString(),
      "device_id": deviceId.toString(),
      if (prescription != null) "prescription": prescription.toString(),
      if (buyerNote != null) "buyer_note": buyerNote,
      "email": email!.toString().toLowerCase().trim(),
      "agree": agreeToTerms ?? false ? "1" : "1",
      if (createAccount != null)
        "create-account": createAccount ?? false ? "1" : "0",
      if (password != null) "password": password.toString().trim(),
      if (passwordConfirm != null)
        "password_confirmation": passwordConfirm.toString().trim(),
      "address_title": addressTitle.toString(),
      "address_line_1": addressLine1.toString(),
      "address_line_2": addressLine2.toString(),
      "country_id": countryId.toString(),
      "state": stateId.toString(),
      "city": city.toString(),
      "zip_code": zipCode.toString(),
      "phone": phone.toString()
    };
    try {
      // ignore: prefer_const_constructors
      state = CheckoutLoadingState();
      String? _accessToken =
          await _iCheckoutRepository.guestCheckout(cartId!, requestBody);
      state = CheckoutLoadedState(accessToken: _accessToken);
    } catch (e) {
      state = CheckoutErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

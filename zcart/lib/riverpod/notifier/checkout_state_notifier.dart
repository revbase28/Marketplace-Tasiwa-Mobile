import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/iCheckout_repository.dart';
import 'package:zcart/riverpod/state/checkout_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/startup/loading_screen.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ICheckoutRepository _iCheckoutRepository;

  CheckoutNotifier(this._iCheckoutRepository)
      : super(const CheckoutInitialState());

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

  Future checkout() async {
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
      state = const CheckoutLoadingState();
      await _iCheckoutRepository.checkout(cartId!, requestBody);

      state = const CheckoutLoadedState();
    } catch (e) {
      state = CheckoutErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> guestCheckout() async {
    var requestBody = {
      "payment_method": paymentMethod.toString(),
      "shipping_option_id": shippingOptionId.toString(),
      "packaging_id": packagingId.toString(),
      "device_id": "123456",
      if (prescription != null) "prescription": prescription.toString(),
      if (buyerNote != null) "buyer_note": buyerNote,
      "email": email,
      "agree": agreeToTerms ?? false ? "1" : "1",
      if (createAccount != null)
        "create_account": createAccount ?? false ? "1" : "0",
      if (password != null) "password": password.toString(),
      if (passwordConfirm != null)
        "password_confirmation": passwordConfirm.toString(),
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
      state = const CheckoutLoadingState();
      await _iCheckoutRepository.guestCheckout(cartId!, requestBody);
      state = const CheckoutLoadedState();
    } catch (e) {
      state = CheckoutErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_address_repository.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/data/repository/address_repository.dart';
import 'package:zcart/riverpod/notifier/address/address_state_notifier.dart';
import 'package:zcart/riverpod/notifier/address/country_state_notifier.dart';
import 'package:zcart/riverpod/notifier/address/states_state_notifier.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:zcart/riverpod/state/address/country_state.dart'
    as country_state;
import 'package:zcart/riverpod/state/address/states_state.dart';

final addressRepositoryProvider =
    Provider<IAddressRepository>((ref) => AddressRepository());

final countryNotifierProvider =
    StateNotifierProvider<CountryNotifier, country_state.CountryState>(
        (ref) => CountryNotifier(ref.watch(addressRepositoryProvider)));

final statesNotifierProvider =
    StateNotifierProvider<StatesNotifier, StatesState>(
        (ref) => StatesNotifier(ref.watch(addressRepositoryProvider)));

final paymentOptionsNotifierProvider =
    StateNotifierProvider<PaymentOptionsNotifier, PaymentOptionsState>(
        (ref) => PaymentOptionsNotifier(ref.watch(addressRepositoryProvider)));

final getAddressFutureProvider = FutureProvider<List<Addresses>?>((ref) async {
  dynamic responseBody;
  AddressModel addressModel;
  try {
    responseBody = await handleResponse(
        await getRequest(API.addresses, bearerToken: true));
    addressModel = AddressModel.fromJson(responseBody);
  } catch (e) {
    return null;
  }
  if (responseBody.runtimeType == int && responseBody > 206) {
    return null;
  }
  return addressModel.data;
});

final addressProvider = Provider<AddressProvider>((ref) {
  return AddressProvider();
});

class AddressProvider {
  Future<bool> createAddress({
    String? addressType,
    String? contactPerson,
    String? contactNumber,
    int? countryId,
    int? stateId,
    String? cityId,
    String? zipCode,
    String? addressLine1,
    String? addressLine2,
  }) async {
    var requestBody = {
      'address_type': addressType,
      'address_title': contactPerson,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': cityId,
      if (stateId != null) 'state_id': stateId.toString(),
      'country_id': countryId.toString(),
      'zip_code': zipCode,
      'phone': contactNumber,
    };
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await postRequest(API.createAddress, requestBody, bearerToken: true));
    } catch (e) {
      return false;
    }

    if (responseBody.runtimeType == int) {
      if (responseBody > 206) {
        return false;
      }
    }
    return true;
  }

  Future<bool> editAddress({
    int? addressId,
    String? addressType,
    String? contactPerson,
    String? contactNumber,
    String? countryId,
    String? stateId,
    String? cityId,
    String? zipCode,
    String? addressLine1,
    String? addressLine2,
  }) async {
    var requestBody = {
      'address_type': addressType,
      'address_title': contactPerson,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': cityId,
      if (stateId != null) 'state_id': stateId,
      'country_id': countryId,
      'zip_code': zipCode,
      'phone': contactNumber,
    };
    dynamic responseBody;

    try {
      responseBody = await handleResponse(await putRequest(
          API.editAddress(addressId), requestBody,
          bearerToken: true));
    } catch (e) {
      return false;
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      return false;
    }
    return true;
  }

  Future<bool> deleteAddress(int? addressId) async {
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await deleteRequest(API.deleteAddress(addressId), bearerToken: true));
    } catch (e) {
      return false;
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      return false;
    }
    return true;
  }
}

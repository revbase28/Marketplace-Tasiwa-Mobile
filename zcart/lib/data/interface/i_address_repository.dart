import 'package:zcart/data/models/address/country_model.dart';
import 'package:zcart/data/models/address/payment_options_model.dart';
import 'package:zcart/data/models/address/states_model.dart';

abstract class IAddressRepository {
  // Future<List<Addresses>?> fetchAddresses();

  // Future createAddress(
  //   String? addressType,
  //   String? contactPerson,
  //   String? contactNumber,
  //   String? countryId,
  //   String? stateId,
  //   String? cityId,
  //   String? zipCode,
  //   String? addressLine1,
  //   String? addressLine2,
  // );

  // Future editAddress(
  //   int? addressId,
  //   String? addressType,
  //   String? contactPerson,
  //   String? contactNumber,
  //   String? countryId,
  //   String? stateId,
  //   String? cityId,
  //   String? zipCode,
  //   String? addressLine1,
  //   String? addressLine2,
  // );

  // Future deleteAddress(
  //   int? addressId,
  // );

  Future<List<Countries>?> fetchCountries();

  Future<List<States>?> fetchStates(int? countryId);

  // Future<List<ShippingOptions>?> fetchShippingInfo(shopId, zoneId);

  // Future<List<ShippingOption>?> fetchShippingOptions(id, countryId, stateId);

  // Future<List<PackagingModel>> fetchPackagingInfo(String? shopSlug);

  Future<List<PaymentOptions>?> fetchPaymentMethods({required String cartId});
}

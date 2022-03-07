import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/models/address/packaging_model.dart';
import 'package:zcart/data/models/address/states_model.dart';
import 'package:zcart/data/models/product/product_variant_details_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/data/repository/product/product_repository.dart';
import 'package:zcart/helper/get_recently_viewed.dart';
import 'package:zcart/helper/set_recently_viewed.dart';
import 'package:zcart/riverpod/notifier/product/product_state_notifier.dart';
import 'package:zcart/riverpod/state/product/product_state.dart';
import 'package:zcart/data/models/product/product_details_model.dart';

final productRepositoryProvider =
    Provider<IProductRepository>((ref) => ProductRepository());

// final productNotifierProvider =
//     StateNotifierProvider<ProductNotifier, ProductState>(
//         (ref) => ProductNotifier(ref.watch(productRepositoryProvider)));
// final productVariantNotifierProvider =
//     StateNotifierProvider<ProductVariantNotifier, ProductVariantState>(
//         (ref) => ProductVariantNotifier(ref.watch(productRepositoryProvider)));
final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>(
        (ref) => ProductListNotifier(ref.watch(productRepositoryProvider)));

///
///
///
///
///
///
///Product Details Providers

final productDetailsFutureProvider = FutureProvider.autoDispose
    .family<ProductDetailsModel?, String>((ref, slug) async {
  final _product = await GetProductDetailsModel.getProductDetails(slug);
  if (_product?.data?.id != null) {
    await setRecentlyViewedItems(_product!.data!.id!);
    debugPrint("Saving product to recently viewed");
    getRecentlyViewedItems(ref: ref);
  }
  //  print("Saving product to recently viewed");
  return _product;
});

final shopPackagingFutureProvider =
    FutureProvider.family<List<PackagingModel>?, String>((ref, shopSlug) async {
  @override
  dynamic responseBody;
  List<PackagingModel> packagingModelList;
  try {
    responseBody =
        await handleResponse(await getRequest(API.packaging(shopSlug)));

    packagingModelList = (responseBody as List<dynamic>)
        .map((e) => PackagingModel.fromJson(e))
        .toList();
  } catch (e) {
    return null;
  }

  if (responseBody.runtimeType == int) {
    if ((responseBody as int) > 206) {
      return null;
    }
  }
  return packagingModelList;
});

final cartShippingOptionsFutureProvider =
    FutureProvider.family<List<ShippingOption>?, String>((ref, url) async {
  return await GetProductDetailsModel.getCartShippingOptions(url);
});

final getProductDetailsModelProvider = Provider<GetProductDetailsModel>((ref) {
  return GetProductDetailsModel();
});

class GetProductDetailsModel {
  static Future<ProductDetailsModel?> getProductDetails(String slug) async {
    final _responseBody =
        await handleResponse(await getRequest(API.productDetails(slug)));

    if (_responseBody.runtimeType == int && _responseBody > 206) {
      return null;
    }

    ProductDetailsModel _productModel =
        ProductDetailsModel.fromJson(_responseBody);

    return _productModel;
  }

  Future<ProductVariantDetailsModel?> getProductVariantDetails(
      String slug, Map<dynamic, dynamic> requestBody) async {
    final _responseBody = await handleResponse(
        await postRequest(API.productVariantDetails(slug), requestBody));

    if (_responseBody.runtimeType == int && _responseBody > 206) {
      return null;
    }
    ProductVariantDetailsModel productVariantDetailsModel =
        ProductVariantDetailsModel.fromJson(_responseBody);
    return productVariantDetailsModel;
  }

  Future<List<ShippingOption>?> getProductShippingOptions({
    required int countryId,
    required int listingId,
    int? stateId,
  }) async {
    dynamic _responseBody;
    var requestBody = {
      'country_id': countryId.toString(),
      'state_id': stateId.toString()
    };
    List<ShippingOption> _shippingOptions;
    try {
      _responseBody = await handleResponse(
          await postRequest(API.shippingOptions(listingId), requestBody));
      _shippingOptions = List<ShippingOption>.from(
          _responseBody["shipping_options"]
              .map((x) => ShippingOption.fromJson(x)));
    } catch (e) {
      return null;
    }
    if (_responseBody.runtimeType == int) {
      if (_responseBody > 206) {
        return null;
      }
    }

    return _shippingOptions;
  }

  Future<List<States>?> getStatesFromSelectedCountry(int countryID) async {
    dynamic responseBody;
    StatesModel statesModel;
    try {
      responseBody = await handleResponse(
          await getRequest(API.states(countryID), bearerToken: true));
      statesModel = StatesModel.fromJson(responseBody);
    } catch (e) {
      return null;
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      return null;
    }
    return statesModel.data;
  }

  static Future<List<ShippingOption>?> getCartShippingOptions(url) async {
    dynamic _responseBody;

    List<ShippingOption> _shippingOptions;
    try {
      _responseBody = await handleResponse(await getRequest(url));
      _shippingOptions = List<ShippingOption>.from(
          _responseBody["data"].map((x) => ShippingOption.fromJson(x)));
    } catch (e) {
      return null;
    }
    if (_responseBody.runtimeType == int) {
      if (_responseBody > 206) {
        return null;
      }
    }

    return _shippingOptions;
  }
}

String cartUrl(int cartId, int? countryId, int? stateId) {
  var params = {
    'ship_to_acountry_id': countryId.toString(),
    'ship_to_state_id': stateId.toString(),
  };

  String _url = API.shippingOptionsForCart(cartId) +
      "?" +
      params.entries.map((e) => e.key + "=" + e.value.toString()).join("&");

  return _url;
}

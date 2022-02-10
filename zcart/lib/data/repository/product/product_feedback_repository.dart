import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/models/product/product_reviews_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductReviewsRepository implements IProductReviewsRepository {
  late ProductReviewsModel _productReviewsModel;
  List<ProductReview> productReviewsList = [];
  @override
  Future<List<ProductReview>> fetchReviews(String slug) async {
    productReviewsList.clear();
    var responseBody =
        await handleResponse(await getRequest(API.productReviews(slug)));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    _productReviewsModel = ProductReviewsModel.fromJson(responseBody);
    productReviewsList.addAll(_productReviewsModel.data ?? []);
    return productReviewsList;
  }

  @override
  Future<List<ProductReview>> fetchMoreReviews() async {
    dynamic responseBody;
    debugPrint("fetchMoreReviewsItems (before): ${productReviewsList.length}");

    if (_productReviewsModel.links!.next != null) {
      toast(LocaleKeys.loading.tr());
      responseBody = await handleResponse(await getRequest(
          _productReviewsModel.links!.next!.split('api/').last));

      _productReviewsModel = ProductReviewsModel.fromJson(responseBody);
      productReviewsList.addAll(_productReviewsModel.data ?? []);
      debugPrint("fetchMoreReviewsItems (after): ${productReviewsList.length}");
      return productReviewsList;
    } else {
      toast(LocaleKeys.reached_to_the_end.tr());
      return productReviewsList;
    }
  }
}

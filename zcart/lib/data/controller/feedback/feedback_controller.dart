import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/feedback/feedback_state.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

final sellerFeedbackProvider =
    StateNotifierProvider<SellerFeedbackRepository, SellerFeedbackState>(
        (ref) => SellerFeedbackRepository());

class SellerFeedbackRepository extends StateNotifier<SellerFeedbackState> {
  SellerFeedbackRepository() : super(const SellerFeedbackInitialState());

  Future<bool> postFeedback(orderId, rating, comment) async {
    state = const SellerFeedbackLoadingState();

    dynamic responseBody;

    var requestBody = {
      'rating': rating,
      'comment': comment,
    };
    try {
      responseBody = await handleResponse(await postRequest(
          API.sellerFeedback(orderId), requestBody,
          bearerToken: true));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      state = const SellerFeedbackLoadedState();
      return true;
    } on NetworkException {
      state = const SellerFeedbackErrorState('Something went wrong');
      return false;
    }
  }
}

final productFeedbackProvider =
    StateNotifierProvider<ProductFeedbackRepository, ProductFeedbackState>(
        (ref) => ProductFeedbackRepository());

class ProductFeedbackRepository extends StateNotifier<ProductFeedbackState> {
  ProductFeedbackRepository() : super(const ProductFeedbackInitialState());

  Future<bool> postFeedback(
      orderId, List listingId, List ratings, List comments) async {
    state = const ProductFeedbackLoadingState();

    dynamic responseBody;

    var requestBody = {};
    for (int i = 0; i < listingId.length; i++) {
      requestBody['items[${listingId[i]}][rating]'] = ratings[i].toString();
      requestBody['items[${listingId[i]}][comment]'] = comments[i];
    }
    debugPrint(requestBody.toString());
    try {
      responseBody = await handleResponse(await postRequest(
          API.productFeedback(orderId), requestBody,
          bearerToken: true));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      state = const ProductFeedbackLoadedState();
      return true;
    } on NetworkException {
      state = const ProductFeedbackErrorState('Something went wrong');
      return false;
    }
  }
}

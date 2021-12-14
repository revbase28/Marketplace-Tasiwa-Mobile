import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/models/product/product_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

class RecentlyViewedRepository implements IRecentlyViewedRepository {
  @override
  Future<List<ProductList>?> fetchRecentlyViewedItems(
      List<String> productList) async {
    var _endPoint =
        API.recentlyViewed + "?" + 'recently_viewed_ids' + "=$productList";
    var responseBody = await handleResponse(await getRequest(_endPoint));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    if (responseBody is List) {
      return null;
    } else {
      ProductModel recentlyReviewedItemModel =
          ProductModel.fromJson(responseBody);

      return recentlyReviewedItemModel.data;
    }
  }
}

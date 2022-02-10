import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/models/product/product_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductRepository implements IProductRepository {
  /// Product List
  late ProductModel productListModel;
  List<ProductList> productList = [];

  @override
  Future<List<ProductList>> fetchProductList(String slug) async {
    productList.clear();
    dynamic responseBody;
    responseBody =
        await handleResponse(await getRequest(API.productList(slug)));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
    productListModel = ProductModel.fromJson(responseBody);
    productList.addAll(productListModel.data!);
    return productList;
  }

  @override
  Future<List<ProductList>> fetchMoreProductList() async {
    dynamic responseBody;
    if (productListModel.links!.next != null) {
      toast(LocaleKeys.loading.tr());
      responseBody = await handleResponse(
          await getRequest(productListModel.links!.next!.split('api/').last));
      productListModel = ProductModel.fromJson(responseBody);
      productList.addAll(productListModel.data!);
      return productList;
    } else {
      toast(LocaleKeys.reached_to_the_end.tr());
      return productList;
    }
  }
}

import 'package:zcart/data/models/product/product_model.dart';
import 'package:zcart/data/models/product/product_reviews_model.dart';

abstract class IProductRepository {
  Future<List<ProductList>> fetchProductList(String slug);
  Future<List<ProductList>> fetchMoreProductList();
}

abstract class IProductReviewsRepository {
  Future<List<ProductReview>> fetchReviews(String slug);
  Future<List<ProductReview>> fetchMoreReviews();
}

abstract class ILatestItemRepository {
  Future<List<ProductList>?> fetchLatestItems();
}

abstract class IPopularItemRepository {
  Future<List<ProductList>?> fetchPopularItems();
}

abstract class IRandomItemRepository {
  Future<List<ProductList>> fetchRandomItems();
  Future<List<ProductList>> fetchMoreRandomItems();
}

abstract class ITrendingNowRepository {
  Future<List<ProductList>?> fetchTrendingNowItems();
}

abstract class IRecentlyViewedRepository {
  Future<List<ProductList>?> fetchRecentlyViewedItems(List<String> productList);
}

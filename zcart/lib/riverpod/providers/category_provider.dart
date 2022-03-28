import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_category_repository.dart';
import 'package:zcart/data/models/categories/featured_categories_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/riverpod/notifier/category_state_notifier.dart';
import 'package:zcart/data/repository/category_repository.dart';
import 'package:zcart/riverpod/state/category_item_state.dart';
import 'package:zcart/riverpod/state/category_state.dart';

final categoryRepositoryProvider =
    Provider<ICategoryRepository>((ref) => CategoryRepository());

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>(
        (ref) => CategoryNotifier(ref.watch(categoryRepositoryProvider)));

final categorySubgroupNotifierProvider =
    StateNotifierProvider<CategorySubgroupNotifier, CategorySubgroupState>(
        (ref) =>
            CategorySubgroupNotifier(ref.watch(categoryRepositoryProvider)));

final subgroupCategoryNotifierProvider =
    StateNotifierProvider<SubgroupCategoryNotifier, SubgroupCategoryState>(
        (ref) =>
            SubgroupCategoryNotifier(ref.watch(categoryRepositoryProvider)));

final categoryItemRepositoryProvider =
    Provider<ICategoryItemRepository>((ref) => CategoryItemRepository());

final categoryItemNotifierProvider =
    StateNotifierProvider<CategoryItemNotifier, CategoryItemState>((ref) =>
        CategoryItemNotifier(ref.watch(categoryItemRepositoryProvider)));

final featuredCategoriesProvider =
    FutureProvider<FeaturedCategoriesModel?>((ref) async {
  final _responseBody =
      await handleResponse(await getRequest(API.featuredCategories));

  if (_responseBody.runtimeType == int && _responseBody > 206) {
    return null;
  }

  FeaturedCategoriesModel _categoriesModel =
      FeaturedCategoriesModel.fromMap(_responseBody);

  return _categoriesModel;
});

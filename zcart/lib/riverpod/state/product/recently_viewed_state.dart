import 'package:zcart/data/models/product/product_model.dart';

abstract class RecentlyViewedState {
  const RecentlyViewedState();
}

class RecentlyViewedInitialState extends RecentlyViewedState {
  const RecentlyViewedInitialState();
}

class RecentlyViewedLoadingState extends RecentlyViewedState {
  const RecentlyViewedLoadingState();
}

class RecentlyViewedLoadedState extends RecentlyViewedState {
  final List<ProductList>? recentItems;

  const RecentlyViewedLoadedState(this.recentItems);
}

class RecentlyViewedErrorState extends RecentlyViewedState {
  final String message;

  const RecentlyViewedErrorState(this.message);
}

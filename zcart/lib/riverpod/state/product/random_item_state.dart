import 'package:zcart/data/models/product/product_model.dart';

abstract class RandomItemState {
  const RandomItemState();
}

class RandomItemInitialState extends RandomItemState {
  const RandomItemInitialState();
}

class RandomItemLoadingState extends RandomItemState {
  const RandomItemLoadingState();
}

class RandomMoreItemLoadingState extends RandomItemState {
  const RandomMoreItemLoadingState();
}

class RandomItemLoadedState extends RandomItemState {
  final List<ProductList> randomItemList;
  final bool loading;

  const RandomItemLoadedState(
    this.randomItemList, {
    this.loading = false,
  });

  RandomItemLoadedState copyWith({
    List<ProductList>? randomItemList,
    bool? loading,
  }) {
    return RandomItemLoadedState(
      randomItemList ?? this.randomItemList,
      loading: loading ?? this.loading,
    );
  }
}

class RandomItemErrorState extends RandomItemState {
  final String message;

  const RandomItemErrorState(this.message);
}

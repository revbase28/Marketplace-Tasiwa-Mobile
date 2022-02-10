import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';

class RandomItemScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  RandomItemScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class VendorItemScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  VendorItemScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class CategoryDetailsScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  CategoryDetailsScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class DisputesScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  DisputesScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class WishListScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  WishListScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class OrderScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  OrderScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class CouponScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  CouponScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class WalletScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  WalletScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class ProductReviewsScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  ProductReviewsScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

class VendorReviewsScrollNotifier extends StateNotifier<ScrollState> {
  // ignore: prefer_const_constructors
  VendorReviewsScrollNotifier() : super(ScrollInitialState());

  final _scrollController = ScrollController();

  ScrollController get controller {
    _scrollController.addListener(_scrollListener);
    return _scrollController;
  }

  get scrollNotifierState => state;

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // ignore: prefer_const_constructors
      state = ScrollReachedBottomState();
    }
  }
}

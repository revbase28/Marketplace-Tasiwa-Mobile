import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_wishlist_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/wishlist_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class WishListNotifier extends StateNotifier<WishListState> {
  final IWishListRepository _iWishListRepository;

  WishListNotifier(this._iWishListRepository)
      : super(const WishListInitialState());

  Future getWishList() async {
    try {
      final _wishListItems = await _iWishListRepository.fetchWishList();
      state = WishListLoadedState(_wishListItems);
    } on NetworkException {
      state = WishListErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future getMoreWishList() async {
    try {
      final _wishListItems = await _iWishListRepository.fetchMoreWishList();
      state = WishListLoadedState(_wishListItems);
    } on NetworkException {
      state = WishListErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> addToWishList(String? slug, BuildContext context) async {
    try {
      await _iWishListRepository.addToWishList(slug, context);
      await getWishList();
    } on NetworkException {
      state = WishListErrorState(LocaleKeys.something_went_wrong.tr());
      await getWishList();
    }
  }

  Future<void> removeFromWishList(int? id) async {
    try {
      await _iWishListRepository.removeFromWishList(id);
      await getWishList();
    } on NetworkException {
      state = WishListErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

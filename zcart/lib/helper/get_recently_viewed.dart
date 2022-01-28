import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/recently_viewed_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void getRecentlyViewedItems(
    {BuildContext? context, ProviderReference? ref}) async {
  var _box = Hive.box(hiveBox);
  List<String>? _recentlyViewed = _box.get(recentlyReviewedIds);

  debugPrint("Recently Reviewd :  $_recentlyViewed");

  try {
    if (_recentlyViewed == null) {
      if (context == null) {
        await ref!
            .read(recentlyViewedNotifierProvider.notifier)
            .getRecentlyViwedItems([]);
      } else {
        await context
            .read(recentlyViewedNotifierProvider.notifier)
            .getRecentlyViwedItems([]);
      }
    } else {
      if (context == null) {
        await ref!
            .read(recentlyViewedNotifierProvider.notifier)
            .getRecentlyViwedItems(_recentlyViewed);
      } else {
        await context
            .read(recentlyViewedNotifierProvider.notifier)
            .getRecentlyViwedItems(_recentlyViewed);
      }
    }
  } catch (e) {
    debugPrint("Ancestor warning : $e");
  }
}

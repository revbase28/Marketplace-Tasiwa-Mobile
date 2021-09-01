import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/recently_viewed_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void getRecentlyViewedItems(BuildContext context) async {
  var _box = Hive.box(HIVE_BOX);
  List<String>? _recentlyViewed = _box.get(RECENTLY_VIEWED_IDS);

  print("Recently Reviewd :  $_recentlyViewed");

  if (_recentlyViewed == null) {
    await context
        .read(recentlyViewedNotifierProvider.notifier)
        .getRecentlyViwedItems([]);
  } else {
    await context
        .read(recentlyViewedNotifierProvider.notifier)
        .getRecentlyViwedItems(_recentlyViewed);
  }
}

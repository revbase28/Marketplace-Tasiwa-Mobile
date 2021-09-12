import 'package:hive/hive.dart';
import 'package:zcart/helper/constants.dart';

Future<void> setRecentlyViewedItems(int id) async {
  var _box = Hive.box(hiveBox);

  List<String>? _recentlyViewedIds = await _box.get(recentlyReviewedIds);
  if (_recentlyViewedIds == null) {
    await _box.put(recentlyReviewedIds, [id.toString()]);
  } else {
    _recentlyViewedIds.add(id.toString());
    await _box.put(recentlyReviewedIds, _recentlyViewedIds.toSet().toList());
  }
}

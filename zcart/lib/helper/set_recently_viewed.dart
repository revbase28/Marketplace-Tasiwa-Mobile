import 'package:hive/hive.dart';
import 'package:zcart/helper/constants.dart';

Future<void> setRecentlyViewedItems(int id) async {
  var _box = Hive.box(HIVE_BOX);

  List<String>? _recentlyViewedIds = await _box.get(RECENTLY_VIEWED_IDS);
  if (_recentlyViewedIds == null) {
    await _box.put(RECENTLY_VIEWED_IDS, [id.toString()]);
  } else {
    _recentlyViewedIds.add(id.toString());
    await _box.put(RECENTLY_VIEWED_IDS, _recentlyViewedIds.toSet().toList());
  }
}

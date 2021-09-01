import 'package:hive/hive.dart';
import 'package:zcart/helper/constants.dart';

Future<void> setRecentlyViewedItems(int id) async {
  var _box = Hive.box(HIVE_BOX);

  List<String>? _recently_viewed_ids = await _box.get(RECENTLY_VIEWED_IDS);
  if (_recently_viewed_ids == null) {
    await _box.put(RECENTLY_VIEWED_IDS, [id.toString()]);
  } else {
    _recently_viewed_ids.add(id.toString());
    await _box.put(RECENTLY_VIEWED_IDS, _recently_viewed_ids.toSet().toList());
  }
}

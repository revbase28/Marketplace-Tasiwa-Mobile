import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_product_repository.dart';
import 'package:zcart/data/repository/product/recently_viewed_repository.dart';
import 'package:zcart/riverpod/notifier/product/recently_viewed_state_notifier.dart';
import 'package:zcart/riverpod/state/product/recently_viewed_state.dart';

final recentlyViewedRepositoryProvider =
    Provider<IRecentlyViewedRepository>((ref) => RecentlyViewedRepository());

final recentlyViewedNotifierProvider =
    StateNotifierProvider<RecentlyViewdNotifier, RecentlyViewedState>((ref) =>
        RecentlyViewdNotifier(ref.watch(recentlyViewedRepositoryProvider)));

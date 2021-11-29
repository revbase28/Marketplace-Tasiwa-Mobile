import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/recently_viewed_provider.dart';
import 'package:zcart/riverpod/state/product/recently_viewed_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/views/shared_widgets/product_card.dart';

class RecentlyViewed extends ConsumerWidget {
  const RecentlyViewed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final recentlyViewedItemState = watch(recentlyViewedNotifierProvider);

    return recentlyViewedItemState is RecentlyViewedLoadedState
        ? recentlyViewedItemState.recentItems == null
            ? const SizedBox()
            : ProductCard(
                    willShuffle: false,
                    title: LocaleKeys.recently_viewed.tr(),
                    productList:
                        recentlyViewedItemState.recentItems!.reversed.toList())
                .pOnly(bottom: 15)
        : recentlyViewedItemState is RecentlyViewedErrorState
            ? const SizedBox()
            : const SizedBox();
  }
}

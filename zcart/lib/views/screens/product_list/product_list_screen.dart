import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/riverpod/providers/category_provider.dart';
import 'package:zcart/riverpod/state/category_item_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';

class ProductListScreen extends ConsumerWidget {
  final String? title;
  const ProductListScreen({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final categoryItemState = watch(categoryItemNotifierProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(title ?? LocaleKeys.product_list.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: categoryItemState is CategoryItemLoadingState
            ? SizedBox(
                height: context.screenHeight - 100,
                child: const Center(child: LoadingWidget()))
            : categoryItemState is CategoryItemLoadedState
                ? categoryItemState.categoryItemList!.isEmpty
                    ? SizedBox(
                        height: context.screenHeight,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline),
                            Text(LocaleKeys.no_item_found.tr())
                          ],
                        )))
                    : SingleChildScrollView(
                        child: ProductDetailsCardGridView(
                                productList:
                                    categoryItemState.categoryItemList!)
                            .px(8),
                      )
                : const SizedBox());
  }
}

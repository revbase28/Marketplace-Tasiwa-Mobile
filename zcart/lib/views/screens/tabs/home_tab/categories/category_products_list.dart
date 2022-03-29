import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/product_details_card.dart';
import 'package:zcart/views/shared_widgets/product_loading_widget.dart';

class CategoryProductsList extends ConsumerWidget {
  final String categoryName;
  const CategoryProductsList({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final productListState = watch(productListNotifierProvider);
    final scrollControllerProvider =
        watch(categoryDetailsScrollNotifierProvider.notifier);

    return ProviderListener<ScrollState>(
      provider: categoryDetailsScrollNotifierProvider,
      onChange: (context, state) {
        if (state is ScrollReachedBottomState) {
          context
              .read(productListNotifierProvider.notifier)
              .getMoreProductList();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryName),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: productListState is ProductListLoadedState
            ? productListState.productList.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Icon(Icons.info_outline),
                      Text(LocaleKeys.no_item_found.tr()),
                    ],
                  )
                : SingleChildScrollView(
                    controller: scrollControllerProvider.controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ProductDetailsCardGridView(
                            productList: productListState.productList)
                        .px(8),
                  )
            : const ProductLoadingWidget().px(10),
      ),
    );
  }
}

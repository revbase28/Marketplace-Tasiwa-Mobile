import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/controller/search/search_controller.dart';
import 'package:zcart/data/controller/search/search_state.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/product_list/recently_viewed.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: kPrimaryLightTextColor),
          cursorColor: kDarkColor,
          controller: searchController,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: LocaleKeys.search_keyword.tr(),
              hintStyle: const TextStyle(color: kPrimaryLightTextColor)),
          onChanged: (value) {
            if (value.length > 3) {
              context.read(searchProvider.notifier).search(value);
            }
          },
        ),
        actions: [
          IconButton(
              onPressed: () => searchController.text.isNotEmpty == true
                  ? context
                      .read(searchProvider.notifier)
                      .search(searchController.text)
                  : toast(LocaleKeys.type_something.tr()),
              icon: const Icon(Icons.search))
        ],
      ),
      body: Consumer(
        builder: (context, watch, _) {
          final searchState = watch(searchProvider);

          return searchState is SearchLoadedState
              ? searchState.searchedItem!.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: searchState.searchedItem!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: getColorBasedOnTheme(
                              context, kLightColor, kDarkCardBgColor),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: searchState.searchedItem![index].image!,
                              errorWidget: (context, url, error) =>
                                  const SizedBox(),
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                    value: progress.progress),
                              ),
                              width: 50,
                              height: 50,
                            ),
                            title: Text(
                              searchState.searchedItem![index].title!,
                            ),
                            trailing: Text(
                              searchState.searchedItem![index].offerPrice !=
                                      null
                                  ? searchState.searchedItem![index].offerPrice!
                                      .toString()
                                  : searchState.searchedItem![index].price!
                                      .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: getColorBasedOnTheme(
                                        context, kPriceColor, kDarkPriceColor),
                                  ),
                            ),
                            onTap: () {
                              context.nextPage(ProductDetailsScreen(
                                  productSlug:
                                      searchState.searchedItem![index].slug!));
                            },
                          ),
                        ).cornerRadius(10).pOnly(bottom: 10);
                      }).px(10)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.info_outline).pOnly(bottom: 10),
                        Text(
                          LocaleKeys.no_item_found.tr(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
              : searchState is SearchLoadingState
                  ? const LoadingWidget()
                  : searchState is SearchInitialState
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              const Icon(Icons.info_outline).pOnly(bottom: 10),
                              Text(
                                LocaleKeys.search_for_something.tr(),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 100,
                              ),
                              const RecentlyViewed().p(10),
                            ],
                          ),
                        )
                      : searchState is SearchErrorState
                          ? ErrorMessageWidget(searchState.message)
                          : const SizedBox();
        },
      ).p(10),
    );
  }
}

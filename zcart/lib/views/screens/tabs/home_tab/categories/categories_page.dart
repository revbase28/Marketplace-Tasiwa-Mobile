import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/categories/category_model.dart';
import 'package:zcart/data/models/categories/category_subgroup_model.dart';
import 'package:zcart/data/models/categories/subgroup_category_model.dart';
import 'package:zcart/helper/category_icons.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/categories/category_products_list.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class CategoriesPage extends ConsumerWidget {
  final int selectedIndex;
  const CategoriesPage({
    Key? key,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _categoryState = watch(categoryNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.categories.tr()),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _categoryState is CategoryLoadedState
          ? _categoryState.categoryList.isEmpty
              ? Center(
                  child: Text(LocaleKeys.no_item_found.tr()),
                )
              : _CategoryList(
                  categories: _categoryState.categoryList,
                  selectedIndex: selectedIndex,
                )
          : const Center(child: LoadingWidget()),
    );
  }
}

class _CategoryList extends StatefulWidget {
  final List<CategoryList> categories;
  final int selectedIndex;
  const _CategoryList({
    Key? key,
    required this.categories,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  final List<CategoryList> _categories = [];

  late int _selectedIndex;

  @override
  void initState() {
    _categories.addAll(widget.categories.sublist(1));
    _selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
          ),
          child: ListView(
            children: _categories.map((e) {
              bool _isSelected = _categories.indexOf(e) == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = _categories.indexOf(e);
                  });
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  color: _isSelected
                      ? getColorBasedOnTheme(context,
                          Theme.of(context).scaffoldBackgroundColor, kDarkColor)
                      : Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(
                        getCategoryIcon(e.icon),
                        color: getColorBasedOnTheme(
                            context,
                            _isSelected ? kPrimaryColor : kDarkCardBgColor,
                            kLightColor),
                      ).pOnly(bottom: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        child: Text(
                          e.name ?? "",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: context.textTheme.caption!.copyWith(
                            color: getColorBasedOnTheme(
                                context,
                                _isSelected ? kPrimaryColor : kDarkCardBgColor,
                                kLightColor),
                            fontWeight: _isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _CategorySideView(category: _categories[_selectedIndex]),
        )
      ],
    );
  }
}

class _CategorySideView extends ConsumerWidget {
  final CategoryList category;
  const _CategorySideView({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _categorySubgroupProvider =
        watch(categorySubgroupsProvider(category.id ?? -1));

    final _height = MediaQuery.of(context).size.height * 0.7;
    return ListView(
      children: [
        if (category.coverImage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: category.coverImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            ),
          ),
        _categorySubgroupProvider.when(
          data: (subGroup) {
            return subGroup == null ||
                    subGroup.data == null ||
                    subGroup.data!.isEmpty
                ? SizedBox(
                    height: _height,
                    child: Center(
                      child: Text(LocaleKeys.no_item_found.tr()),
                    ),
                  )
                : _CategorySubGroupsList(subGroups: subGroup.data!);
          },
          loading: () => SizedBox(
            height: _height,
            child: const Center(child: LoadingWidget()),
          ),
          error: (e, _) => SizedBox(
            height: _height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(LocaleKeys.something_went_wrong.tr()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySubGroupsList extends ConsumerWidget {
  final List<CategorySubgroup> subGroups;
  const _CategorySubGroupsList({
    Key? key,
    required this.subGroups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    return Column(
      children: subGroups.map((e) {
        return ExpansionTile(
          iconColor: getColorBasedOnTheme(context, kLightColor, kDarkColor),
          collapsedIconColor: kPrimaryColor,
          title: Text(
            e.name ?? LocaleKeys.unknown.tr(),
            style: context.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: e.description == null
              ? null
              : Text(
                  e.description ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.caption,
                ),
          childrenPadding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _SubGroupCategoriesList(subGroupId: e.id ?? -1),
          ],
        );
      }).toList(),
    );
  }
}

class _SubGroupCategoriesList extends ConsumerWidget {
  final int subGroupId;
  const _SubGroupCategoriesList({
    Key? key,
    required this.subGroupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _subGroupCategoriesProvider =
        watch(categoriesOfSubgroupProvider(subGroupId));

    return _subGroupCategoriesProvider.when(
      data: (categories) {
        return categories == null ||
                categories.data == null ||
                categories.data!.isEmpty
            ? SizedBox(
                height: 100,
                child: Center(
                  child: Text(LocaleKeys.no_item_found.tr()),
                ),
              )
            : _SubGroupCategoriesListView(categories: categories.data!);
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: LoadingWidget()),
      ),
      error: (e, _) => SizedBox(
        height: 100,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(LocaleKeys.something_went_wrong.tr()),
          ),
        ),
      ),
    );
  }
}

class _SubGroupCategoriesListView extends StatelessWidget {
  final List<SubgroupCategory> categories;
  const _SubGroupCategoriesListView({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double _height = 100;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        return GestureDetector(
          onTap: () {
            context.nextPage(CategoryProductsList(
                categoryName: category.name ?? LocaleKeys.unknown.tr()));

            context
                .read(productListNotifierProvider.notifier)
                .getProductList('category/${category.slug}');
          },
          child: SizedBox(
            width: _height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                category.featureImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: category.featureImage!,
                          fit: BoxFit.contain,
                          height: _height,
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: kFadeColor.withOpacity(0.3),
                            ),
                            height: _height,
                            child: const Center(child: Icon(Icons.image)),
                          ),
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: kFadeColor.withOpacity(0.3),
                            ),
                            height: _height,
                            child: const Center(child: LoadingWidget()),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: kFadeColor.withOpacity(0.3),
                        ),
                        height: _height,
                        child: const Center(child: Icon(Icons.image)),
                      ),
                const SizedBox(height: 4),
                Text(
                  category.name ?? "",
                  textAlign: TextAlign.center,
                  style: context.textTheme.caption!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kFadeColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

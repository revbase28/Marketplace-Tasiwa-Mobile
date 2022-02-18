import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/vendors/vendors_model.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'components/vendors_card.dart';
import 'vendors_details.dart';

class VendorsTab extends StatefulWidget {
  const VendorsTab({Key? key}) : super(key: key);

  @override
  State<VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<VendorsTab> {
  bool _showSearchBar = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final vendorsState = watch(vendorsNotifierProvider);
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Text(LocaleKeys.vendor_text.tr()),
            actions: [
              CupertinoButton(
                child: Icon(!_showSearchBar ? Icons.search : Icons.search_off,
                    color: kLightColor),
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                  });
                },
              ),
            ],
          ),
          body: vendorsState is VendorsLoadedState
              ? VendorsListBody(
                  vendors: vendorsState.vendorsList ?? [],
                  showSearchBar: _showSearchBar,
                )
              : vendorsState is VendorsErrorState
                  ? ErrorMessageWidget(vendorsState.message)
                  : const SizedBox(),
        ),
      );
    });
  }
}

class VendorsListBody extends StatefulWidget {
  final List<VendorsList> vendors;
  final bool showSearchBar;
  const VendorsListBody({
    Key? key,
    required this.vendors,
    required this.showSearchBar,
  }) : super(key: key);

  @override
  _VendorsListBodyState createState() => _VendorsListBodyState();
}

class _VendorsListBodyState extends State<VendorsListBody> {
  final _searchController = TextEditingController();
  final _vendorsList = [];

  @override
  void initState() {
    _vendorsList.addAll(widget.vendors);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearchBar) const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(sizeFactor: animation, child: child);
          },
          child: widget.showSearchBar
              ? Padding(
                  key: const ValueKey("SearchBar"),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomTextField(
                    controller: _searchController,
                    autoFocus: widget.showSearchBar,
                    hintText: LocaleKeys.search_vendor.tr(),
                    onChanged: (value) {
                      setState(() {
                        _vendorsList.clear();
                        _vendorsList.addAll(widget.vendors.where((vendor) =>
                            vendor.name!
                                .toLowerCase()
                                .contains(value.toLowerCase())));
                      });
                    },
                  ),
                )
              : const SizedBox(
                  key: ValueKey("NoSearchBar"),
                ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 5),
            itemCount: _vendorsList.length,
            itemBuilder: (context, index) {
              return VendorCard(
                logo: _vendorsList[index].image,
                verifiedText: _vendorsList[index].verifiedText,
                name: _vendorsList[index].name,
                isVerified: _vendorsList[index].verified,
                rating: _vendorsList[index].rating,
                onTap: () {
                  context
                      .read(vendorDetailsNotifierProvider.notifier)
                      .getVendorDetails(_vendorsList[index].slug);
                  context
                      .read(vendorItemsNotifierProvider.notifier)
                      .getVendorItems(_vendorsList[index].slug);
                  context.nextPage(const VendorsDetailsScreen());
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

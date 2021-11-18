import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/address_provider.dart';
import 'package:zcart/riverpod/providers/product_provider.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/custom_dropdownfield.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({
    Key? key,
    required this.productModel,
  }) : super(key: key);

  final ProductDetailsModel productModel;

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  dynamic selectedCountry;
  dynamic selectedShippingMethod;

  @override
  Widget build(BuildContext context) {
    return ProviderListener<ShippingState>(
        provider: shippingNotifierProvider,
        onChange: (context, state) {
          if (state is ShippingOptionsLoadedState) {
            widget.productModel.shippingOptions = state.shippingOptions!
                .map((e) => ShippingOption.fromJson(e.toJson()))
                .toList();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.shipping_address.tr()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
                child: Container(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.ship_to.tr(),
                          style: context.textTheme.bodyText2)
                      .pOnly(bottom: 10),
                  Container(
                    color: getColorBasedOnTheme(
                        context, kPrimaryColor.withOpacity(0.10), kDarkBgColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: context.screenWidth,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        focusColor: kLightColor,
                        value: selectedCountry ??
                            widget.productModel.countries!.values.elementAt(
                                widget.productModel.countries!.keys
                                    .toList()
                                    .indexOf(widget
                                        .productModel.shippingCountryId
                                        .toString())),
                        style: context.textTheme.subtitle2,
                        iconEnabledColor: getColorBasedOnTheme(
                            context, kDarkColor, kLightColor),
                        items: widget.productModel.countries!.entries
                            .map((e) => e.value)
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ));
                        }).toList(),
                        hint: Text(LocaleKeys.select_options.tr(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCountry = value;
                          });
                          context
                              .read(shippingNotifierProvider.notifier)
                              .fetchShippingOptions(
                                  widget.productModel.data!.id,
                                  widget.productModel.countries!.keys.elementAt(
                                      widget.productModel.countries!.values
                                          .toList()
                                          .indexOf(selectedCountry.toString())),
                                  null);
                          widget.productModel.shippingCountryId = int.parse(
                              widget.productModel.countries!.keys.elementAt(
                                  widget.productModel.countries!.values
                                      .toList()
                                      .indexOf(selectedCountry.toString())));
                          context
                              .read(productNotifierProvider.notifier)
                              .updateState(widget.productModel);
                        },
                      ),
                    ),
                  ).cornerRadius(5).pOnly(bottom: 10),
                  Text(LocaleKeys.shipping_method.tr(),
                          style: context.textTheme.bodyText2)
                      .pOnly(bottom: 10),
                  Container(
                    color: getColorBasedOnTheme(
                        context, kPrimaryColor.withOpacity(0.10), kDarkBgColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: context.screenWidth,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        focusColor: kLightColor,
                        value: selectedShippingMethod ??
                            widget.productModel.shippingOptions!.first.name,
                        style: context.textTheme.subtitle2,
                        iconEnabledColor: getColorBasedOnTheme(
                            context, kDarkColor, kLightColor),
                        items: widget.productModel.shippingOptions!
                            .map((e) => e.name)
                            .map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value!,
                              ));
                        }).toList(),
                        hint: Text(LocaleKeys.select_options.tr(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        onChanged: (String? value) {
                          setState(() {
                            selectedShippingMethod = value;
                          });

                          widget.productModel.shippingOptions!.insert(
                              0,
                              widget.productModel.shippingOptions![widget
                                  .productModel.shippingOptions!
                                  .map((e) => e.name)
                                  .toList()
                                  .indexOf(selectedShippingMethod)]);
                          widget.productModel.shippingOptions = widget
                              .productModel.shippingOptions!
                              .toSet()
                              .toList();
                          context
                              .read(productNotifierProvider.notifier)
                              .updateState(widget.productModel);
                        },
                      ),
                    ),
                  ).cornerRadius(5).pOnly(bottom: 10),
                ],
              ),
            ).p(10)),
          ),
        ));
  }
}

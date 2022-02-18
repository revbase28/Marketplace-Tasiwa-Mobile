import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/edit_address_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class AddressListBuilder extends StatefulWidget {
  final List<Addresses>? addressesList;
  final VoidCallback? onTapDisabled;
  final CartItemDetails? cartItem;
  final Function(int)? onAddressSelected;
  final int? selectedAddressIndex;
  final bool isOneCheckout;

  const AddressListBuilder({
    Key? key,
    this.addressesList,
    this.onTapDisabled,
    this.cartItem,
    this.onAddressSelected,
    this.selectedAddressIndex,
    this.isOneCheckout = false,
  }) : super(key: key);

  @override
  _AddressListBuilderState createState() => _AddressListBuilderState();
}

class _AddressListBuilderState extends State<AddressListBuilder> {
  final List<Addresses> _addressesList = [];
  int? _selectedIndex;
  bool _isOneCheckout = false;

  @override
  void initState() {
    _selectedIndex = widget.selectedAddressIndex;

    _isOneCheckout = widget.isOneCheckout;

    _addressesList.addAll(widget.addressesList!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _checkoutProvider = context.read(checkoutNotifierProvider.notifier);

    bool _isAnyAddressAvailable = false;
    if (widget.cartItem != null) {
      for (var e in _addressesList) {
        if (e.country!.id == widget.cartItem!.shipToCountryId &&
            e.state?.id == widget.cartItem!.shipToStateId) {
          _isAnyAddressAvailable = true;
          break;
        }
      }
    }
    return _addressesList.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: _isOneCheckout
                  ? Text(
                      LocaleKeys.no_delivery_address_found.tr(),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      LocaleKeys.no_address_found.tr(),
                      textAlign: TextAlign.center,
                    ),
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 5),
                  children: _addressesList.map((e) {
                    final _textColor = widget.cartItem != null
                        ? e.country!.id == widget.cartItem!.shipToCountryId &&
                                e.state?.id == widget.cartItem!.shipToStateId
                            ? getColorBasedOnTheme(context,
                                kPrimaryDarkTextColor, kPrimaryLightTextColor)
                            : widget.isOneCheckout
                                ? kFadeColor
                                : getColorBasedOnTheme(
                                    context,
                                    kPrimaryDarkTextColor,
                                    kPrimaryLightTextColor)
                        : getColorBasedOnTheme(context, kPrimaryDarkTextColor,
                            kPrimaryLightTextColor);

                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          color: getColorBasedOnTheme(
                              context, kLightColor, kDarkCardBgColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () async {
                            if (widget.cartItem != null) {
                              if (accessAllowed) {
                                if (_isOneCheckout == false) {
                                  String _url = cartUrl(widget.cartItem!.id!,
                                      e.country!.id, e.state?.id);
                                  final _shipOptions =
                                      await GetProductDetailsModel
                                          .getCartShippingOptions(_url);

                                  int? _shippingOptionId;
                                  int? _shippingZoneId;
                                  if (_shipOptions != null &&
                                      _shipOptions.isNotEmpty) {
                                    if (_shipOptions.any((element) {
                                      return element.id ==
                                              widget
                                                  .cartItem!.shippingOptionId &&
                                          element.shippingZoneId ==
                                              widget.cartItem!.shippingZoneId;
                                    })) {
                                      _shippingOptionId =
                                          widget.cartItem!.shippingOptionId;
                                      _shippingZoneId =
                                          widget.cartItem!.shippingZoneId;
                                    } else {
                                      _shippingOptionId = _shipOptions.first.id;
                                      _shippingZoneId =
                                          _shipOptions.first.shippingZoneId;
                                    }
                                  }

                                  context
                                      .read(cartItemDetailsNotifierProvider
                                          .notifier)
                                      .updateCart(
                                        widget.cartItem!.id!,
                                        countryId: e.country!.id,
                                        stateId: e.state?.id,
                                        shipTo: e.id,
                                        shippingOptionId: _shippingOptionId,
                                        shippingZoneId: _shippingZoneId,
                                      );

                                  context
                                      .read(cartNotifierProvider.notifier)
                                      .updateCart(
                                        widget.cartItem!.id!,
                                        countryId: e.country!.id,
                                        stateId: e.state?.id,
                                        shipTo: e.id,
                                        shippingOptionId: _shippingOptionId,
                                        shippingZoneId: _shippingZoneId,
                                      );

                                  _checkoutProvider.shipTo = e.id;
                                  if (widget.onAddressSelected != null) {
                                    widget.onAddressSelected!(
                                        _addressesList.indexOf(e));
                                  }

                                  setState(() {
                                    _selectedIndex = _addressesList.indexOf(e);
                                  });
                                } else {
                                  if (e.country!.id ==
                                          widget.cartItem!.shipToCountryId &&
                                      e.state?.id ==
                                          widget.cartItem!.shipToStateId) {
                                    _checkoutProvider.shipTo = e.id;
                                    if (widget.onAddressSelected != null) {
                                      widget.onAddressSelected!(
                                          _addressesList.indexOf(e));
                                    }
                                    setState(() {
                                      _selectedIndex =
                                          _addressesList.indexOf(e);
                                    });
                                  } else {
                                    if (widget.onTapDisabled != null) {
                                      widget.onTapDisabled!();
                                    }

                                    // toast("Change shipping area on cart page!");
                                  }
                                }
                              }
                            }
                          },
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.addressType!,
                                style: context.textTheme.bodyText2!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.cartItem != null
                                      ? e.country!.id ==
                                                  widget.cartItem!
                                                      .shipToCountryId &&
                                              e.state?.id ==
                                                  widget.cartItem!.shipToStateId
                                          ? kPrimaryColor
                                          : widget.isOneCheckout
                                              ? kFadeColor
                                              : getColorBasedOnTheme(
                                                  context,
                                                  kPrimaryDarkTextColor,
                                                  kPrimaryLightTextColor)
                                      : getColorBasedOnTheme(
                                          context,
                                          kPrimaryDarkTextColor,
                                          kPrimaryLightTextColor),
                                ),
                              ),
                              Text(e.addressTitle!,
                                  style: context.textTheme.subtitle2!
                                      .copyWith(color: _textColor)),
                              Text('(${e.phone})',
                                  style: context.textTheme.subtitle2!
                                      .copyWith(color: _textColor)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.addressLine1}, ${e.addressLine2}',
                                  style: context.textTheme.caption!
                                      .copyWith(color: _textColor)),
                              Text(
                                  '${e.state != null ? e.state!.name! + ',' : ''} ${e.country == null ? '' : e.country!.name! + ','} ${e.zipCode}'
                                      .trim(),
                                  style: context.textTheme.caption!
                                      .copyWith(color: _textColor)),
                            ],
                          ),
                          trailing: widget.cartItem != null
                              ? _addressesList.indexOf(e) == _selectedIndex
                                  ? Icon(Icons.check_circle,
                                      color: kPrimaryColor)
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: _textColor,
                                    )
                              : IconButton(
                                  onPressed: () {
                                    if (e.country?.id != null) {
                                      debugPrint(e.country?.id.toString());
                                      context
                                          .read(statesNotifierProvider.notifier)
                                          .getState(e.country?.id);
                                    }
                                    context.nextPage(
                                      EditAddressScreen(address: e),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                        )).py(5).cornerRadius(10);
                  }).toList(),
                ),
              ),
              if (widget.cartItem != null && !_isAnyAddressAvailable)
                ListTile(
                  tileColor: getColorBasedOnTheme(
                      context,
                      kPriceColor.withOpacity(0.2),
                      kDarkPriceColor.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  minLeadingWidth: 0,
                  leading: Icon(CupertinoIcons.info_circle,
                      color: getColorBasedOnTheme(
                        context,
                        kPriceColor.withOpacity(0.9),
                        kDarkPriceColor.withOpacity(0.9),
                      )),
                  title: Text(
                    LocaleKeys.no_delivery_address_found.tr(),
                    style: context.textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: getColorBasedOnTheme(
                          context,
                          kPriceColor.withOpacity(0.9),
                          kDarkPriceColor.withOpacity(0.9),
                        )),
                  ),
                ).pSymmetric(h: 4)
            ],
          );
  }
}

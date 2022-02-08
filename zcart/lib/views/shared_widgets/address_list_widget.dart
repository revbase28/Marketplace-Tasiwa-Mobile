import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/edit_address_screen.dart';

class AddressListBuilder extends StatefulWidget {
  final List<Addresses>? addressesList;
  final CartItemDetails? cartItem;
  final Function(int)? onAddressSelected;
  final int? selectedAddressIndex;
  final bool isOneCheckout;

  const AddressListBuilder({
    Key? key,
    this.addressesList,
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

    return _addressesList.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: _isOneCheckout
                  ? const Text(
                      "No delivery address found for your selected shipping area. Please add new address or update carts.",
                      textAlign: TextAlign.center,
                    )
                  : const Text(
                      "No address found. Please add address",
                      textAlign: TextAlign.center,
                    ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.only(top: 5),
            children: _addressesList.map((e) {
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                            final _shipOptions = await GetProductDetailsModel
                                .getCartShippingOptions(_url);
                            context
                                .read(cartItemDetailsNotifierProvider.notifier)
                                .updateCart(
                                  widget.cartItem!.id!,
                                  countryId: e.country!.id,
                                  stateId: e.state?.id,
                                  shipTo: e.id,
                                  shippingOptionId: _shipOptions != null &&
                                          _shipOptions.isNotEmpty
                                      ? _shipOptions.first.id
                                      : null,
                                  shippingZoneId: _shipOptions != null &&
                                          _shipOptions.isNotEmpty
                                      ? _shipOptions.first.shippingZoneId
                                      : null,
                                );

                            context
                                .read(cartNotifierProvider.notifier)
                                .updateCart(
                                  widget.cartItem!.id!,
                                  countryId: e.country!.id,
                                  stateId: e.state?.id,
                                  shipTo: e.id,
                                  shippingOptionId: _shipOptions != null &&
                                          _shipOptions.isNotEmpty
                                      ? _shipOptions.first.id
                                      : null,
                                  shippingZoneId: _shipOptions != null &&
                                          _shipOptions.isNotEmpty
                                      ? _shipOptions.first.shippingZoneId
                                      : null,
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
                                e.state?.id == widget.cartItem!.shipToStateId) {
                              _checkoutProvider.shipTo = e.id;
                              if (widget.onAddressSelected != null) {
                                widget.onAddressSelected!(
                                    _addressesList.indexOf(e));
                              }
                              setState(() {
                                _selectedIndex = _addressesList.indexOf(e);
                              });
                            } else {
                              toast(
                                  "This adress is not compatible with your cart. Please select another one or add new address.");
                            }
                          }
                        }
                      }
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.addressType!,
                            style: context.textTheme.bodyText2!
                                .copyWith(color: kPrimaryColor)),
                        Text(e.addressTitle!,
                            style: context.textTheme.subtitle2),
                        Text('(${e.phone})',
                            style: context.textTheme.subtitle2),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.addressLine1}, ${e.addressLine2}',
                            style: context.textTheme.caption),
                        Text(
                            '${e.state != null ? e.state!.name! + ',' : ''} ${e.country == null ? '' : e.country!.name! + ','} ${e.zipCode}'
                                .trim(),
                            style: context.textTheme.caption),
                      ],
                    ),
                    trailing: widget.cartItem != null
                        ? _addressesList.indexOf(e) == _selectedIndex
                            ? Icon(Icons.check_circle, color: kPrimaryColor)
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: getColorBasedOnTheme(
                                    context, kDarkColor, kLightColor),
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
          );
  }
}

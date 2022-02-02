import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const AddressListBuilder({
    Key? key,
    this.addressesList,
    this.cartItem,
    this.onAddressSelected,
    this.selectedAddressIndex,
  }) : super(key: key);

  @override
  _AddressListBuilderState createState() => _AddressListBuilderState();
}

class _AddressListBuilderState extends State<AddressListBuilder> {
  int? _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.selectedAddressIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _checkoutProvider = context.read(checkoutNotifierProvider.notifier);
    return ListView.builder(
        padding: const EdgeInsets.only(top: 5),
        itemCount: widget.addressesList!.length,
        itemBuilder: (context, index) {
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: getColorBasedOnTheme(
                    context, kLightColor, kDarkCardBgColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  if (widget.cartItem != null) {
                    if (accessAllowed) {
                      if (widget.onAddressSelected != null) {
                        widget.onAddressSelected!(index);
                      }
                      context
                          .read(cartItemDetailsNotifierProvider.notifier)
                          .updateCart(
                            widget.cartItem!.id!,
                            countryId: widget.addressesList![index].country!.id,
                            stateId: widget.addressesList![index].state?.id,
                            shipTo: widget.addressesList![index].id,
                          );

                      _checkoutProvider.shipTo =
                          widget.addressesList![index].id;
                    } else {
                      if (widget.onAddressSelected != null) {
                        widget.onAddressSelected!(index);
                      }
                      context
                          .read(cartItemDetailsNotifierProvider.notifier)
                          .updateCart(
                            widget.cartItem!.id!,
                            countryId: widget.addressesList![index].countryId,
                            stateId: widget.addressesList![index].stateId,
                          );

                      _checkoutProvider.addressTitle =
                          widget.addressesList![index].addressTitle;
                      _checkoutProvider.addressLine1 =
                          widget.addressesList![index].addressLine1;

                      _checkoutProvider.addressLine2 =
                          widget.addressesList![index].addressLine2;

                      _checkoutProvider.countryId =
                          widget.addressesList![index].countryId;

                      _checkoutProvider.stateId =
                          widget.addressesList![index].stateId;
                      _checkoutProvider.city =
                          widget.addressesList![index].city;
                      _checkoutProvider.zipCode =
                          widget.addressesList![index].zipCode;
                      _checkoutProvider.phone =
                          widget.addressesList![index].phone;
                    }

                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.addressesList![index].addressType!,
                        style: context.textTheme.bodyText2!
                            .copyWith(color: kPrimaryColor)),
                    Text(widget.addressesList![index].addressTitle!,
                        style: context.textTheme.subtitle2),
                    Text('(${widget.addressesList![index].phone})',
                        style: context.textTheme.subtitle2),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${widget.addressesList![index].addressLine1}, ${widget.addressesList![index].addressLine2}',
                        style: context.textTheme.caption),
                    Text(
                        '${widget.addressesList![index].state != null ? widget.addressesList![index].state!.name! + ',' : ''} ${widget.addressesList![index].country == null ? '' : widget.addressesList![index].country!.name! + ','} ${widget.addressesList![index].zipCode}'
                            .trim(),
                        style: context.textTheme.caption),
                  ],
                ),
                trailing: widget.cartItem != null
                    ? index == _selectedIndex
                        ? Icon(Icons.check_circle, color: kPrimaryColor)
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: getColorBasedOnTheme(
                                context, kDarkColor, kLightColor),
                          )
                    : IconButton(
                        onPressed: () {
                          if (widget.addressesList![index].country?.id !=
                              null) {
                            debugPrint(widget.addressesList![index].country?.id
                                .toString());
                            context
                                .read(statesNotifierProvider.notifier)
                                .getState(
                                    widget.addressesList![index].country?.id);
                          }
                          context.nextPage(
                            EditAddressScreen(
                                address: widget.addressesList![index]),
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
              )).py(5).cornerRadius(10);
        });
  }
}

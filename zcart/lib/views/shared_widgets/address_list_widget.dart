import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/edit_address_screen.dart';
import 'package:zcart/Theme/styles/colors.dart';

import 'package:velocity_x/velocity_x.dart';

class AddressListBuilder extends StatefulWidget {
  final List<Addresses>? addressesList;
  final CartItemDetails? cartItem;
  final Function(int)? onPressedCheckBox;

  const AddressListBuilder(
      {this.addressesList, this.cartItem, this.onPressedCheckBox, Key? key})
      : super(key: key);

  @override
  _AddressListBuilderState createState() => _AddressListBuilderState();
}

class _AddressListBuilderState extends State<AddressListBuilder> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                      widget.onPressedCheckBox!(index);
                      context
                          .read(cartItemDetailsNotifierProvider.notifier)
                          .updateCart(widget.cartItem!.id,
                              countryId:
                                  widget.addressesList![index].country!.id);

                      context.read(checkoutNotifierProvider.notifier).shipTo =
                          widget.addressesList![index].id;
                    } else {
                      widget.onPressedCheckBox!(index);
                      context
                          .read(cartItemDetailsNotifierProvider.notifier)
                          .updateCart(
                            widget.cartItem!.id,
                            countryId: widget.addressesList![index].countryId,
                          );

                      context
                              .read(checkoutNotifierProvider.notifier)
                              .addressTitle =
                          widget.addressesList![index].addressTitle;
                      context
                              .read(checkoutNotifierProvider.notifier)
                              .addressLine1 =
                          widget.addressesList![index].addressLine1;

                      context
                              .read(checkoutNotifierProvider.notifier)
                              .addressLine2 =
                          widget.addressesList![index].addressLine2;

                      context
                          .read(checkoutNotifierProvider.notifier)
                          .countryId = widget.addressesList![index].countryId;

                      context.read(checkoutNotifierProvider.notifier).stateId =
                          widget.addressesList![index].stateId;

                      context.read(checkoutNotifierProvider.notifier).city =
                          widget.addressesList![index].city;

                      context.read(checkoutNotifierProvider.notifier).zipCode =
                          widget.addressesList![index].zipCode;

                      context.read(checkoutNotifierProvider.notifier).phone =
                          widget.addressesList![index].phone;
                    }

                    debugPrint(selectedIndex.toString());
                    debugPrint(index.toString());
                    setState(() {
                      selectedIndex = index;
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
                    ? index == selectedIndex
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

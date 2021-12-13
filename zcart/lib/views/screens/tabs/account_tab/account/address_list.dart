import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/address_list_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'add_address_screen.dart';

class AddressList extends StatelessWidget {
  const AddressList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.your_address.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: LocaleKeys.add_address.tr(),
            onPressed: () {
              context.nextPage(const AddNewAddressScreen());
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Consumer(
        builder: (context, watch, _) {
          final addressState = watch(addressNotifierProvider);
          final cartItemDetailsState = watch(cartItemDetailsNotifierProvider);

          return addressState is AddressLoadedState
              ? addressState.addresses == null
                  ? Center(
                      child: Text(LocaleKeys.no_item_found.tr()),
                    )
                  : addressState.addresses!.isEmpty
                      ? Center(
                          child: Text(LocaleKeys.no_item_found.tr()),
                        )
                      : cartItemDetailsState is CartItemDetailsLoadedState
                          ? AddressListBuilder(
                              addressesList: addressState.addresses)
                          : AddressListBuilder(
                              addressesList: addressState.addresses)
              : addressState is AddressLoadingState
                  ? const LoadingWidget().py(100)
                  : const SizedBox();
        },
      ).p(10),
    );
  }
}

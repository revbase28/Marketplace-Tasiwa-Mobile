import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/address_list_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'add_address_screen.dart';

class AddressList extends ConsumerWidget {
  const AddressList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _addressProvider = watch(getAddressFutureProvider);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.your_address.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: LocaleKeys.add_address.tr(),
            onPressed: () async {
              final _systemConfig = context.read(systemConfigFutureProvider);

              _systemConfig.whenData((sys) async {
                int? _selectedCountryID = sys?.data?.addressDefaultCountry;

                if (_selectedCountryID != null) {
                  try {
                    context
                        .read(statesNotifierProvider.notifier)
                        .getState(_selectedCountryID);
                  } catch (e) {
                    debugPrint("Error: $e");
                  }
                }
              });

              context.nextPage(const AddNewAddressScreen());
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: _addressProvider.when(
        data: (value) {
          if (value == null || value.isEmpty) {
            return Center(
              child: Text(LocaleKeys.no_item_found.tr()),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: AddressListBuilder(addressesList: value),
            );
          }
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stackTrace) => const SizedBox(),
      ),
    );
  }
}

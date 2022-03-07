import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/address_provider.dart';
import 'package:zcart/riverpod/state/address/country_state.dart';
import 'package:zcart/riverpod/state/address/states_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/dropdown_field_loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class EditAddressScreen extends StatefulWidget {
  final Addresses address;
  const EditAddressScreen({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressTypeController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  @override
  void initState() {
    _addressTypeController.text = widget.address.addressType!;
    _contactPersonController.text = widget.address.addressTitle ?? '';
    _contactNumberController.text = widget.address.phone ?? '';
    _zipCodeController.text = widget.address.zipCode ?? '';
    _addressLine1Controller.text = widget.address.addressLine1 ?? '';
    _addressLine2Controller.text = widget.address.addressLine2 ?? '';
    _cityController.text = widget.address.city ?? '';
    _countryController.text = widget.address.country?.name ?? '';
    _stateController.text = widget.address.state?.name ?? '';

    super.initState();
  }

  int? _selectedCountryID;

  int? _selectedStateID;

  bool _isLoading = false;

  final List<String> _addressTypes = ["Primary", "Billing", "Shipping"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.edit_address.tr()),
        actions: [
          IconButton(
            onPressed: () async {
              await showCustomConfirmDialog(
                context,
                dialogAnimation: DialogAnimation.SLIDE_RIGHT_LEFT,
                dialogType: DialogType.DELETE,
                title: LocaleKeys.delete_address_warning.tr(),
                onAccept: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await context
                      .read(addressProvider)
                      .deleteAddress(widget.address.id);
                  await context.refresh(getAddressFutureProvider);
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                },
              );
            },
            icon: const Icon(
              CupertinoIcons.delete,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                      width: context.screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropDownField(
                            title: LocaleKeys.address_type.tr(),
                            optionsList: _addressTypes,
                            value: widget.address.addressType,
                            controller: _addressTypeController,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                            onChange: (value) {
                              debugPrint(_addressTypeController.text);
                            },
                          ),
                          CustomTextField(
                            title: LocaleKeys.contact_person_name.tr(),
                            hintText: LocaleKeys.contact_person_name.tr(),
                            controller: _contactPersonController,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            title: LocaleKeys.contact_number.tr(),
                            hintText: LocaleKeys.contact_number.tr(),
                            keyboardType: TextInputType.number,
                            controller: _contactNumberController,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                          ),
                          Consumer(
                            builder: (context, watch, _) {
                              final countryState =
                                  watch(countryNotifierProvider);

                              return countryState is CountryLoadedState
                                  ? CustomDropDownField(
                                      title: LocaleKeys.country.tr(),
                                      optionsList: countryState.countryList!
                                          .map((e) => e.name)
                                          .toList(),
                                      controller: _countryController,
                                      value: countryState.countryList!
                                          .firstWhere((e) =>
                                              e.id ==
                                              widget.address.country!.id)
                                          .name,
                                      isCallback: true,
                                      callbackFunction: (int countryId) {
                                        _selectedCountryID = countryState
                                            .countryList![countryId].id;
                                        context
                                            .read(
                                                statesNotifierProvider.notifier)
                                            .getState(countryState
                                                .countryList![countryId].id);
                                      },
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return LocaleKeys
                                              .please_select_a_country
                                              .tr();
                                        }
                                        return null;
                                      },
                                    )
                                  : countryState is CountryLoadingState
                                      ? const FieldLoading()
                                      : const SizedBox();
                            },
                          ),
                          Consumer(
                            builder: (context, watch, _) {
                              final statesState = watch(statesNotifierProvider);
                              if (statesState is StatesLoadedState) {
                                _selectedStateID =
                                    statesState.statesList!.isEmpty
                                        ? null
                                        : statesState.statesList![0].id;
                              }
                              return statesState is StatesLoadedState &&
                                      statesState.statesList!.isNotEmpty
                                  ? CustomDropDownField(
                                      title: LocaleKeys.states.tr(),
                                      optionsList:
                                          statesState.statesList!.isEmpty
                                              ? ["Select"]
                                              : statesState.statesList!
                                                  .map((e) => e.name)
                                                  .toList(),
                                      controller: _stateController,
                                      value: widget.address.state != null
                                          ? statesState.statesList!.isEmpty
                                              ? "Select"
                                              : widget.address.country!.name !=
                                                      _countryController.text
                                                  ? statesState
                                                      .statesList!.first.name
                                                  : statesState.statesList!.any(
                                                          (element) =>
                                                              element.id ==
                                                              widget.address
                                                                  .state!.id)
                                                      ? statesState.statesList!
                                                          .firstWhere((e) =>
                                                              e.id ==
                                                              widget.address
                                                                  .state!.id)
                                                          .name
                                                      : "Select"
                                          : statesState.statesList!.isEmpty
                                              ? "Select"
                                              : statesState
                                                  .statesList!.first.name,
                                      isCallback: true,
                                      callbackFunction:
                                          statesState.statesList!.isNotEmpty
                                              ? (int stateId) {
                                                  _selectedStateID = statesState
                                                      .statesList![stateId].id;
                                                }
                                              : null,
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return LocaleKeys
                                              .please_select_a_state
                                              .tr();
                                        }
                                        return null;
                                      },
                                    )
                                  : statesState is StatesLoadingState
                                      ? const FieldLoading()
                                      : const SizedBox();
                            },
                          ),
                          CustomTextField(
                            title: LocaleKeys.zip_code.tr(),
                            hintText: LocaleKeys.zip_code.tr(),
                            keyboardType: TextInputType.number,
                            controller: _zipCodeController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                              title: LocaleKeys.address_line_1.tr(),
                              hintText: LocaleKeys.address_line_1.tr(),
                              controller: _addressLine1Controller,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  if (_addressLine2Controller.text.isEmpty) {
                                    return LocaleKeys.field_required.tr();
                                  }
                                }
                                return null;
                              }),
                          CustomTextField(
                            title: LocaleKeys.address_line_2.tr(),
                            hintText: LocaleKeys.address_line_2.tr(),
                            controller: _addressLine2Controller,
                            validator: (text) {
                              if (_addressLine1Controller.text.isEmpty) {
                                if (text == null || text.isEmpty) {
                                  return LocaleKeys.field_required.tr();
                                }
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            title: LocaleKeys.city.tr(),
                            hintText: LocaleKeys.city.tr(),
                            controller: _cityController,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                          ),
                          CustomButton(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  toast(
                                    LocaleKeys.please_wait.tr(),
                                  );
                                  await context
                                      .read(addressProvider)
                                      .editAddress(
                                        addressId: widget.address.id,
                                        addressType:
                                            _addressTypeController.text,
                                        contactPerson:
                                            _contactPersonController.text,
                                        contactNumber:
                                            _contactNumberController.text,
                                        countryId: _selectedCountryID == null
                                            ? widget.address.country!.id
                                                .toString()
                                            : _selectedCountryID.toString(),
                                        stateId: _selectedStateID?.toString(),
                                        cityId: _cityController.text,
                                        addressLine1:
                                            _addressLine1Controller.text,
                                        addressLine2:
                                            _addressLine2Controller.text,
                                        zipCode: _zipCodeController.text,
                                      );
                                  await context
                                      .refresh(getAddressFutureProvider);
                                  context.pop();
                                }
                              },
                              buttonText: LocaleKeys.update_address.tr()),
                        ],
                      ).p(10),
                    ).cornerRadius(10).p(10),
                  ],
                ),
              ),
            ),
    );
  }
}

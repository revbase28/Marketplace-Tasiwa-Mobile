import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/address_provider.dart';
import 'package:zcart/riverpod/state/address/country_state.dart';
import 'package:zcart/riverpod/state/address/states_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/custom_dropdownfield.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'package:zcart/views/shared_widgets/dropdown_field_loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isAccessed;
  const AddNewAddressScreen({
    Key? key,
    this.isAccessed = true,
  }) : super(key: key);
  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController addressTypeController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController statesController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int? selectedCountryID;

  int? selectedStateID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.add_address.tr()),
      ),
      body: SingleChildScrollView(
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
                    widget.isAccessed
                        ? CustomDropDownField(
                            title: LocaleKeys.address_type.tr(),
                            optionsList: const [
                              "Primary",
                              "Billing",
                              "Shipping"
                            ],
                            hintText: LocaleKeys.address_type.tr(),
                            value: "Primary",
                            controller: addressTypeController,
                            validator: (text) {
                              if (text == null || text.isEmpty || text == "") {
                                return LocaleKeys.field_required.tr();
                              }
                              return null;
                            },
                          )
                        : const SizedBox(),
                    CustomTextField(
                      title: LocaleKeys.contact_person_name.tr(),
                      hintText: LocaleKeys.contact_person_name.tr(),
                      controller: contactPersonController,
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
                      controller: contactNumberController,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return LocaleKeys.field_required.tr();
                        }
                        return null;
                      },
                    ),
                    Consumer(
                      builder: (context, watch, _) {
                        final countryState = watch(countryNotifierProvider);

                        return countryState is CountryLoadedState
                            ? CustomDropDownField(
                                title: LocaleKeys.country.tr(),
                                optionsList: countryState.countryList!
                                    .map((e) => e.name)
                                    .toList(),
                                //value: "Select",
                                controller: countryController,
                                hintText: LocaleKeys.country.tr(),
                                isCallback: true,
                                callbackFunction: (int countryId) {
                                  selectedCountryID =
                                      countryState.countryList![countryId].id;
                                  context
                                      .read(statesNotifierProvider.notifier)
                                      .getState(countryState
                                          .countryList![countryId].id);
                                },
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please select a country';
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
                          selectedStateID = statesState.statesList!.isEmpty
                              ? null
                              : statesState.statesList![0].id;
                        }
                        return statesState is StatesLoadedState &&
                                statesState.statesList!.isNotEmpty
                            ? CustomDropDownField(
                                title: LocaleKeys.states.tr(),
                                optionsList: statesState.statesList!.isEmpty
                                    ? ["Select"]
                                    : statesState.statesList!
                                        .map((e) => e.name)
                                        .toList(),
                                //value: "Select",
                                controller: statesController,
                                hintText: LocaleKeys.states.tr(),
                                isCallback: true,
                                callbackFunction: (int stateId) {
                                  selectedStateID =
                                      statesState.statesList!.isEmpty
                                          ? null
                                          : statesState.statesList![stateId].id;
                                },
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please select a state';
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
                      controller: zipCodeController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        controller: addressLine1Controller,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            if (addressLine1Controller.text.isEmpty) {
                              return LocaleKeys.field_required.tr();
                            }
                          }
                          return null;
                        }),
                    CustomTextField(
                      title: LocaleKeys.address_line_2.tr(),
                      hintText: LocaleKeys.address_line_2.tr(),
                      controller: addressLine2Controller,
                      validator: (text) {
                        if (addressLine2Controller.text.isEmpty) {
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
                      controller: cityController,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return LocaleKeys.field_required.tr();
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                toast(
                                  LocaleKeys.please_wait.tr(),
                                );
                                if (widget.isAccessed) {
                                  await context
                                      .read(addressProvider)
                                      .createAddress(
                                        addressType: addressTypeController
                                                    .text.isEmpty ||
                                                addressTypeController.text == ""
                                            ? "Shipping"
                                            : addressTypeController.text,
                                        contactPerson:
                                            contactPersonController.text,
                                        contactNumber:
                                            contactNumberController.text,
                                        countryId: selectedCountryID ?? 4,
                                        stateId: selectedStateID,
                                        cityId: cityController.text,
                                        addressLine1:
                                            addressLine1Controller.text,
                                        addressLine2:
                                            addressLine2Controller.text,
                                        zipCode: zipCodeController.text,
                                      );
                                  await context
                                      .refresh(getAddressFutureProvider);
                                  context.pop();
                                } else {
                                  Addresses _newAddress = Addresses(
                                    addressType:
                                        addressTypeController.text.isEmpty ||
                                                addressTypeController.text == ""
                                            ? "Shipping"
                                            : addressTypeController.text,
                                    addressTitle: contactPersonController.text,
                                    phone: contactNumberController.text,
                                    countryId: selectedCountryID ?? 4,
                                    stateId: selectedStateID,
                                    city: cityController.text,
                                    addressLine1: addressLine1Controller.text,
                                    addressLine2: addressLine2Controller.text,
                                    zipCode: zipCodeController.text,
                                    id: DateTime.now().millisecondsSinceEpoch,
                                  );
                                  Navigator.pop(context, _newAddress);
                                }
                              }
                            },
                            child: Text(LocaleKeys.add_address.tr())),
                      ],
                    ),
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

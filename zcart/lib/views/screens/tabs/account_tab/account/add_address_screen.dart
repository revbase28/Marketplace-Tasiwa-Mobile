import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/address_provider.dart';
import 'package:zcart/riverpod/state/address/country_state.dart';
import 'package:zcart/riverpod/state/address/states_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/dropdown_field_loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({
    Key? key,
  }) : super(key: key);
  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressTypeController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController statesController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int? _selectedCountryID;

  int? _selectedStateID;

  final List<String> _addressTypes = ["Primary", "Billing", "Shipping"];

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
                    CustomDropDownField(
                      title: LocaleKeys.address_type.tr(),
                      optionsList: _addressTypes,
                      hintText: LocaleKeys.address_type.tr(),
                      controller: _addressTypeController,
                      validator: (text) {
                        if (text == null || text.isEmpty || text == "") {
                          return LocaleKeys.field_required.tr();
                        }
                        return null;
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
                        final countryState = watch(countryNotifierProvider);

                        return countryState is CountryLoadedState
                            ? CustomDropDownField(
                                title: LocaleKeys.country.tr(),
                                optionsList: countryState.countryList!
                                    .map((e) => e.name)
                                    .toList(),
                                controller: countryController,
                                hintText: LocaleKeys.country.tr(),
                                isCallback: true,
                                callbackFunction: (int index) {
                                  _selectedCountryID =
                                      countryState.countryList![index].id;

                                  context
                                      .read(statesNotifierProvider.notifier)
                                      .getState(
                                          countryState.countryList![index].id);
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

                        return statesState is StatesLoadedState &&
                                statesState.statesList!.isNotEmpty
                            ? CustomDropDownField(
                                title: LocaleKeys.states.tr(),
                                optionsList: statesState.statesList!.isEmpty
                                    ? ["Select"]
                                    : statesState.statesList!
                                        .map((e) => e.name)
                                        .toList(),
                                controller: statesController,
                                hintText: LocaleKeys.states.tr(),
                                isCallback: true,
                                callbackFunction: statesState
                                        .statesList!.isNotEmpty
                                    ? (int index) {
                                        _selectedStateID =
                                            statesState.statesList![index].id;
                                      }
                                    : null,
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
                      controller: _zipCodeController,
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
                        controller: _addressLine1Controller,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            if (_addressLine1Controller.text.isEmpty) {
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
                        if (_addressLine2Controller.text.isEmpty) {
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

                          await context.read(addressProvider).createAddress(
                                addressType: _addressTypeController.text,
                                contactPerson: _contactPersonController.text,
                                contactNumber: _contactNumberController.text,
                                countryId: _selectedCountryID ?? 4,
                                stateId: _selectedStateID,
                                cityId: _cityController.text,
                                addressLine1: _addressLine1Controller.text,
                                addressLine2: _addressLine2Controller.text,
                                zipCode: _zipCodeController.text,
                              );
                          await context.refresh(getAddressFutureProvider);
                          context.pop();
                        }
                      },
                      buttonText: LocaleKeys.add_address.tr(),
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

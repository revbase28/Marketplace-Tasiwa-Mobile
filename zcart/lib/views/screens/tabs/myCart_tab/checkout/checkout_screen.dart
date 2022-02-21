import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/models/address/address_model.dart';
import 'package:zcart/data/models/address/payment_options_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart'
    as cart_item_details_model;
import 'package:zcart/data/models/product/product_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/pick_image_helper.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:zcart/riverpod/state/address/country_state.dart';
import 'package:zcart/riverpod/state/address/states_state.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/riverpod/state/checkout_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/add_address_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/terms_and_conditions_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/order_placed_page.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/address_list_widget.dart';
import 'package:zcart/views/shared_widgets/currency_widget.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/dropdown_field_loading_widget.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final String? customerEmail;
  final bool isOneCheckout;
  const CheckoutScreen({
    Key? key,
    this.customerEmail,
    this.isOneCheckout = false,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  final _guestAddressFormKey = GlobalKey<FormState>();
  late PageController _pageController;
  Addresses? _selectedAddress;
  bool _keyboardVisible = false;

  int _currentIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);

    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.round() ?? 0;
      });
    });
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _keyboardVisible) {
      setState(() {
        _keyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page == 0) {
          return true;
        } else {
          _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
          return false;
        }
      },
      child: ProviderListener<CheckoutState>(
        provider: checkoutNotifierProvider,
        onChange: (context, state) async {
          if (state is CheckoutLoadedState) {
            toast(LocaleKeys.order_place_confirmation.tr());
            context.read(checkoutNotifierProvider.notifier).password = null;
            context.read(checkoutNotifierProvider.notifier).passwordConfirm =
                null;
            context.read(checkoutNotifierProvider.notifier).createAccount =
                false;
            context.read(checkoutNotifierProvider.notifier).email = null;
            context.nextReplacementPage(
                OrderPlacedPage(accessToken: state.accessToken));
          }
        },
        child: ProviderListener<CartItemDetailsState>(
          provider: cartItemDetailsNotifierProvider,
          onChange: (context, state) {
            if (state is CartItemDetailsLoadedState) {
              context.read(checkoutNotifierProvider.notifier).cartId =
                  state.cartItemDetails!.data!.id;

              context.read(checkoutNotifierProvider.notifier).shippingOptionId =
                  state.cartItemDetails!.data!.shippingOptionId;
              context.read(checkoutNotifierProvider.notifier).packagingId =
                  state.cartItemDetails!.data!.packagingId;
              context.read(checkoutNotifierProvider.notifier).countryId =
                  state.cartItemDetails!.data!.shipToCountryId;
              context.read(checkoutNotifierProvider.notifier).stateId =
                  state.cartItemDetails!.data!.shipToStateId;

              context
                  .read(statesNotifierProvider.notifier)
                  .getState(state.cartItemDetails!.data!.shipToCountryId);
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SafeArea(
              top: false,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 4,
                  shadowColor: getColorBasedOnTheme(
                      context, kDarkColor.withOpacity(0.3), kDarkColor),
                  backgroundColor: getColorBasedOnTheme(
                      context, kLightBgColor, kDarkBgColor),
                  iconTheme: IconThemeData(
                      color: getColorBasedOnTheme(
                          context, kDarkColor, kLightColor)),
                  title: Text(
                    (accessAllowed
                            ? LocaleKeys.checkout.tr()
                            : LocaleKeys.guest_checkout.tr()) +
                        (widget.isOneCheckout ? " ${LocaleKeys.all.tr()}" : ""),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
                  bottomOpacity: 0.8,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _progressItems.map((e) {
                            bool _isDone =
                                _currentIndex >= _progressItems.indexOf(e);
                            return Expanded(
                              child: CheckOutProgressItem(
                                onTap: () {
                                  if (!_isDone) {
                                    return;
                                  } else {
                                    _pageController.animateToPage(
                                        _progressItems.indexOf(e),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                isFirst: _progressItems.indexOf(e) == 0,
                                isLast: _progressItems.indexOf(e) ==
                                    _progressItems.length - 1,
                                title: e.title,
                                icon: e.icon,
                                progressColor:
                                    _isDone ? kPrimaryColor : kFadeColor,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16)
                      ],
                    ),
                  ),
                ),
                body: Consumer(builder: (context, watch, child) {
                  final _cartDetailsProvider =
                      watch(cartItemDetailsNotifierProvider);
                  return _cartDetailsProvider is CartItemDetailsLoadedState
                      ? Column(
                          children: [
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: accessAllowed
                                            ? CheckoutLoggedInAddressScreen(
                                                selectedAddress:
                                                    _selectedAddress,
                                                isOneCheckout:
                                                    widget.isOneCheckout,
                                                onSelectedAddress: (address) {
                                                  setState(() {
                                                    _selectedAddress = address;
                                                  });
                                                },
                                              )
                                            : CheckOutGuestAddressForm(
                                                isOneCheckout:
                                                    widget.isOneCheckout,
                                                countryId: _cartDetailsProvider
                                                    .cartItemDetails!
                                                    .data!
                                                    .shipToCountryId!,
                                                stateId: _cartDetailsProvider
                                                    .cartItemDetails!
                                                    .data!
                                                    .shipToStateId,
                                                formKey: _guestAddressFormKey,
                                                cartId: _cartDetailsProvider
                                                    .cartItemDetails!.data!.id!,
                                              ),
                                      ),
                                      if (!_keyboardVisible)
                                        ShippingDetails(
                                          cartItem: _cartDetailsProvider
                                              .cartItemDetails!.data!,
                                          isOneCheckout: widget.isOneCheckout,
                                          onPressedNext: accessAllowed
                                              ? () {
                                                  if (_selectedAddress !=
                                                      null) {
                                                    _pageController.nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeIn,
                                                    );
                                                  } else {
                                                    toast(LocaleKeys
                                                        .select_shipping_address_continue
                                                        .tr());
                                                  }
                                                }
                                              : () {
                                                  if (_guestAddressFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    final _checkoutProvider =
                                                        context.read(
                                                            checkoutNotifierProvider
                                                                .notifier);
                                                    Addresses _newAddress =
                                                        Addresses(
                                                      addressLine1:
                                                          _checkoutProvider
                                                              .addressLine1,
                                                      addressLine2:
                                                          _checkoutProvider
                                                              .addressLine2,
                                                      addressTitle:
                                                          _checkoutProvider
                                                              .addressTitle,
                                                      city: _checkoutProvider
                                                          .city,
                                                      countryId:
                                                          _checkoutProvider
                                                              .countryId,
                                                      stateId: _checkoutProvider
                                                          .stateId,
                                                      id: DateTime.now()
                                                          .millisecondsSinceEpoch,
                                                      phone: _checkoutProvider
                                                          .phone,
                                                      zipCode: _checkoutProvider
                                                          .zipCode,
                                                    );

                                                    setState(() {
                                                      _selectedAddress =
                                                          _newAddress;
                                                    });

                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    _pageController.nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeIn,
                                                    );
                                                  }
                                                },
                                        )
                                    ],
                                  ),
                                  CheckOutItemDetailsPage(
                                      isKeyboardVisible: _keyboardVisible,
                                      isOneCheckout: widget.isOneCheckout,
                                      onPressedBack: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      onPressedNext: () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      }),
                                  CheckoutPaymentPage(
                                    isKeyboardVisible: _keyboardVisible,
                                    customerEmail: widget.customerEmail,
                                    isOneCheckout: widget.isOneCheckout,
                                    cartItemDetails:
                                        _cartDetailsProvider.cartItemDetails,
                                    address: _selectedAddress,
                                  ),
                                ],
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                            ),
                          ],
                        )
                      : const Center(child: LoadingWidget());
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutLoggedInAddressScreen extends StatelessWidget {
  final bool isOneCheckout;
  final Function(Addresses) onSelectedAddress;
  final Addresses? selectedAddress;
  const CheckoutLoggedInAddressScreen({
    Key? key,
    required this.isOneCheckout,
    required this.onSelectedAddress,
    this.selectedAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final _userAddressProvider =
            accessAllowed ? watch(getAddressFutureProvider) : null;
        final _cartDetailsProvider = watch(cartItemDetailsNotifierProvider);

        return _cartDetailsProvider is CartItemDetailsLoadedState
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: getColorBasedOnTheme(
                            context, kLightColor, kDarkCardBgColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddNewAddressScreen()),
                          );
                        },
                        dense: true,
                        minLeadingWidth: 0,
                        title: Text(
                          LocaleKeys.add_address.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        leading: const Icon(CupertinoIcons.add_circled_solid),
                      ),
                    ),
                    Expanded(
                        child: _userAddressProvider!.when(
                      data: (value) {
                        if (value == null) {
                          return const SizedBox();
                        } else {
                          return AddressListBuilder(
                            addressesList: value,
                            isOneCheckout: isOneCheckout,
                            cartItem:
                                _cartDetailsProvider.cartItemDetails?.data,
                            onAddressSelected: (index) {
                              onSelectedAddress(value[index]);
                            },
                            onTapDisabled: () {
                              showCustomConfirmDialog(context,
                                  dialogAnimation: DialogAnimation.DEFAULT,
                                  transitionDuration:
                                      const Duration(milliseconds: 0),
                                  dialogType: DialogType.UPDATE,
                                  primaryColor: kPrimaryColor,
                                  title: LocaleKeys.shipping_address.tr(),
                                  subTitle: LocaleKeys.shipping_address_warning
                                      .tr(), onAccept: () {
                                context.pop();
                              }, positiveText: LocaleKeys.change.tr());
                            },
                            selectedAddressIndex: selectedAddress != null
                                ? value.indexOf(selectedAddress!)
                                : null,
                          );
                        }
                      },
                      loading: () => const Center(child: LoadingWidget()),
                      error: (error, stackTrace) => const SizedBox(),
                    )),
                  ],
                ),
              )
            : _cartDetailsProvider is CartItemDetailsErrorState
                ? Center(
                    child: Text(LocaleKeys.something_went_wrong.tr()),
                  )
                : const Center(child: LoadingWidget());
      },
    );
  }
}

class CheckOutGuestAddressForm extends StatefulWidget {
  final int cartId;
  final int countryId;
  final int? stateId;
  final GlobalKey<FormState> formKey;
  final bool isOneCheckout;
  const CheckOutGuestAddressForm({
    Key? key,
    required this.cartId,
    required this.countryId,
    this.stateId,
    required this.formKey,
    this.isOneCheckout = false,
  }) : super(key: key);

  @override
  _CheckOutGuestAddressFormState createState() =>
      _CheckOutGuestAddressFormState();
}

class _CheckOutGuestAddressFormState extends State<CheckOutGuestAddressForm> {
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

  int? _selectedCountryID;

  @override
  void initState() {
    final _checkoutProvider = context.read(checkoutNotifierProvider.notifier);

    _contactPersonController.text = _checkoutProvider.addressTitle ?? '';
    _contactNumberController.text = _checkoutProvider.phone ?? '';
    _zipCodeController.text = _checkoutProvider.zipCode ?? '';
    _addressLine1Controller.text = _checkoutProvider.addressLine1 ?? '';
    _addressLine2Controller.text = _checkoutProvider.addressLine2 ?? '';
    _cityController.text = _checkoutProvider.city ?? '';
    _selectedCountryID = widget.countryId;

    super.initState();
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _checkoutProvider = context.read(checkoutNotifierProvider.notifier);
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Container(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              width: context.screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    title: LocaleKeys.contact_person_name.tr(),
                    hintText: LocaleKeys.contact_person_name.tr(),
                    controller: _contactPersonController,
                    onChanged: (value) {
                      _checkoutProvider.addressTitle = value;
                    },
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
                    onChanged: (value) {
                      _checkoutProvider.phone = value;
                    },
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
                              isReadOnly: widget.isOneCheckout ? true : false,
                              title: LocaleKeys.country.tr(),
                              optionsList: countryState.countryList!
                                  .map((e) => e.name)
                                  .toList(),
                              controller: _countryController,
                              value: countryState.countryList!
                                  .firstWhere((e) => e.id == widget.countryId)
                                  .name,
                              isCallback: true,
                              callbackFunction: (int countryId) async {
                                setState(() {
                                  _selectedCountryID =
                                      countryState.countryList![countryId].id;
                                });
                                context
                                    .read(statesNotifierProvider.notifier)
                                    .getState(countryState
                                        .countryList![countryId].id);

                                String _url = cartUrl(
                                    widget.cartId,
                                    countryState.countryList![countryId].id,
                                    null);

                                final _shipOptions =
                                    await GetProductDetailsModel
                                        .getCartShippingOptions(_url);

                                context
                                    .read(cartItemDetailsNotifierProvider
                                        .notifier)
                                    .updateCart(
                                      widget.cartId,
                                      countryId: _selectedCountryID,
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
                                      widget.cartId,
                                      countryId: _selectedCountryID,
                                      shippingOptionId: _shipOptions != null &&
                                              _shipOptions.isNotEmpty
                                          ? _shipOptions.first.id
                                          : null,
                                      shippingZoneId: _shipOptions != null &&
                                              _shipOptions.isNotEmpty
                                          ? _shipOptions.first.shippingZoneId
                                          : null,
                                    );
                              },
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return LocaleKeys.please_select_a_country
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

                      return statesState is StatesLoadedState &&
                              statesState.statesList!.isNotEmpty
                          ? CustomDropDownField(
                              isReadOnly: widget.isOneCheckout ? true : false,
                              title: LocaleKeys.states.tr(),
                              optionsList: statesState.statesList!.isEmpty
                                  ? ["Select"]
                                  : statesState.statesList!
                                      .map((e) => e.name)
                                      .toList(),
                              controller: _stateController,
                              value: widget.stateId != null
                                  ? statesState.statesList!.any((element) =>
                                          element.id == widget.stateId)
                                      ? statesState.statesList!
                                          .firstWhere(
                                              (e) => e.id == widget.stateId)
                                          .name
                                      : statesState.statesList!.first.name
                                  : statesState.statesList!.isEmpty
                                      ? "Select"
                                      : statesState.statesList!.first.name,
                              isCallback: true,
                              callbackFunction: statesState
                                      .statesList!.isNotEmpty
                                  ? (int index) async {
                                      String _url = cartUrl(
                                          widget.cartId,
                                          _selectedCountryID,
                                          statesState.statesList![index].id);

                                      final _shipOptions =
                                          await GetProductDetailsModel
                                              .getCartShippingOptions(_url);
                                      context
                                          .read(cartItemDetailsNotifierProvider
                                              .notifier)
                                          .updateCart(
                                            widget.cartId,
                                            countryId: _selectedCountryID,
                                            stateId: statesState
                                                .statesList![index].id,
                                            shippingOptionId:
                                                _shipOptions != null &&
                                                        _shipOptions.isNotEmpty
                                                    ? _shipOptions.first.id
                                                    : null,
                                            shippingZoneId:
                                                _shipOptions != null &&
                                                        _shipOptions.isNotEmpty
                                                    ? _shipOptions
                                                        .first.shippingZoneId
                                                    : null,
                                          );

                                      context
                                          .read(cartNotifierProvider.notifier)
                                          .updateCart(
                                            widget.cartId,
                                            countryId: _selectedCountryID,
                                            stateId: statesState
                                                .statesList![index].id,
                                            shippingOptionId:
                                                _shipOptions != null &&
                                                        _shipOptions.isNotEmpty
                                                    ? _shipOptions.first.id
                                                    : null,
                                            shippingZoneId:
                                                _shipOptions != null &&
                                                        _shipOptions.isNotEmpty
                                                    ? _shipOptions
                                                        .first.shippingZoneId
                                                    : null,
                                          );
                                    }
                                  : null,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return LocaleKeys.please_select_a_state.tr();
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
                    onChanged: (value) {
                      _checkoutProvider.zipCode = value;
                    },
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
                      onChanged: (value) {
                        _checkoutProvider.addressLine1 = value;
                      },
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
                    onChanged: (value) {
                      _checkoutProvider.addressLine2 = value;
                    },
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
                    onChanged: (value) {
                      _checkoutProvider.city = value;
                    },
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return LocaleKeys.field_required.tr();
                      }
                      return null;
                    },
                  ),
                ],
              ).p(10),
            ).cornerRadius(10).p(10),
          ],
        ),
      ),
    );
  }
}

class ShippingDetails extends ConsumerWidget {
  final cart_item_details_model.CartItemDetails cartItem;
  final VoidCallback onPressedNext;
  final bool isOneCheckout;

  const ShippingDetails({
    Key? key,
    required this.cartItem,
    required this.onPressedNext,
    this.isOneCheckout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    String _url =
        cartUrl(cartItem.id!, cartItem.shipToCountryId, cartItem.shipToStateId);
    final _shippingOptions = watch(cartShippingOptionsFutureProvider(_url));

    return _shippingOptions.when(
      data: (value) {
        if (value == null || value.isEmpty) {
          return isOneCheckout
              ? const SizedBox()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    title: Text(
                      LocaleKeys.shipping.tr() + ':',
                      style: context.textTheme.caption!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryFadeTextColor),
                    ),
                    subtitle: Text(
                      LocaleKeys.seller_doesnt_ship_this_area.tr(),
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
        } else {
          ShippingOption? _shippingOption;
          if (value.any((element) => element.id == cartItem.shippingOptionId)) {
            _shippingOption = value.firstWhere(
              (element) => element.id == cartItem.shippingOptionId,
            );
          } else {
            _shippingOption = value.first;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isOneCheckout ? const SizedBox() : const Divider(height: 0),
              isOneCheckout
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        onTap: () {
                          _onTapSelectShippingOption(
                              context, value, _shippingOption);
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.shipping.tr() + ':',
                              style: context.textTheme.caption!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryFadeTextColor),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              alignment: Alignment.centerRight,
                              onPressed: () {
                                _onTapSelectShippingOption(
                                    context, value, _shippingOption);
                              },
                              child: Text(
                                LocaleKeys.change.tr(),
                                style: context.textTheme.caption!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kFadeColor),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (_shippingOption.name ??
                                        LocaleKeys.unknown.tr()) +
                                    " by " +
                                    (_shippingOption.carrierName ??
                                        LocaleKeys.unknown.tr()),
                                style: context.textTheme.subtitle2!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              double.parse(_shippingOption.costRaw ?? "0") <=
                                      0.0
                                  ? ""
                                  : (_shippingOption.cost ?? "0"),
                              style: context.textTheme.subtitle2!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: getColorBasedOnTheme(
                                      context, kPriceColor, kDarkPriceColor)),
                            )
                          ],
                        ).pOnly(top: 8),
                      ),
                    ),
              isOneCheckout ? const SizedBox() : const Divider(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: onPressedNext,
                  child: Text(LocaleKeys.next.tr()),
                ),
              ),
            ],
          );
        }
      },
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }

  Future<dynamic> _onTapSelectShippingOption(BuildContext context,
      List<ShippingOption> value, ShippingOption? _shippingOption) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: context.screenHeight * 0.7,
          child: ProductPageDefaultContainer(
            padding: 24,
            isFullPadding: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LocaleKeys.select_shipping.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: value
                        .map(
                          (e) => ListTile(
                            title: Text(
                              (e.name ?? LocaleKeys.unknown.tr()) +
                                  " by " +
                                  (e.carrierName ?? LocaleKeys.unknown.tr()),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              e.deliveryTakes ?? "",
                              style: Theme.of(context).textTheme.caption!,
                            ),
                            trailing: Text(
                              e.cost ?? "0",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: getColorBasedOnTheme(
                                        context, kPriceColor, kDarkPriceColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              context
                                  .read(cartNotifierProvider.notifier)
                                  .updateCart(
                                    cartItem.id!,
                                    shippingOptionId: e.id,
                                    shippingZoneId: e.shippingZoneId,
                                  );
                              context
                                  .read(
                                      cartItemDetailsNotifierProvider.notifier)
                                  .updateCart(
                                    cartItem.id!,
                                    shippingOptionId: e.id,
                                    shippingZoneId: e.shippingZoneId,
                                  );
                            },
                            minLeadingWidth: 0,
                            contentPadding: EdgeInsets.zero,
                            leading: _shippingOption?.id == e.id
                                ? const Icon(Icons.check_circle)
                                : const Icon(Icons.circle_outlined),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CheckOutItemDetailsPage extends ConsumerWidget {
  final bool isOneCheckout;
  final VoidCallback onPressedNext;
  final VoidCallback onPressedBack;
  final bool isKeyboardVisible;
  const CheckOutItemDetailsPage({
    Key? key,
    required this.isOneCheckout,
    required this.onPressedNext,
    required this.onPressedBack,
    required this.isKeyboardVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _cartDetailsProvider = watch(cartItemDetailsNotifierProvider);
    final _allCartsProvider = watch(cartNotifierProvider);

    String _cartCount = "0";
    String _itemCount = "0";
    String _itemCountSubtitle = "";
    String _quantity = "0";
    String _quantitySubtitle = "";
    String _subTotal = "0";
    String _subTotalSubtitle = "";
    String _shipping = "0";
    String _shippingSubtitle = "";
    String _handling = "0";
    String _handlingSubtitle = "";
    String _packaging = "0";
    String _packagingSubtitle = "";
    String _discount = "0";
    String _discountSubtitle = "";
    String _total = "0";
    if (_allCartsProvider is CartLoadedState) {
      _cartCount = _allCartsProvider.cartList!.length.toString();
      _itemCount = _allCartsProvider.cartList!
          .fold(
            0,
            (int previousValue, element) =>
                previousValue + element.items!.length,
          )
          .toString();
      _itemCountSubtitle = _allCartsProvider.cartList!
          .map((e) => e.items!.length)
          .toList()
          .join('+');

      int _totalQuantity = 0;
      for (var e in _allCartsProvider.cartList!) {
        _totalQuantity += e.items!.fold(
          0,
          (int previousValue, element) => previousValue + element.quantity!,
        );
      }
      _quantity = _totalQuantity.toString();

      _quantitySubtitle = _allCartsProvider.cartList!
          .map((e) => e.items!.fold(
                0,
                (int previousValue, element) =>
                    previousValue + element.quantity!,
              ))
          .toList()
          .join('+');

      _subTotal = _allCartsProvider.cartList!
          .fold(
              0.0,
              (double previousValue, element) =>
                  previousValue + double.parse(element.totalRaw ?? "0"))
          .toStringAsFixed(2);
      _subTotalSubtitle =
          _allCartsProvider.cartList!.map((e) => e.total!).toList().join('+');

      _shipping = _allCartsProvider.cartList!
          .fold(
              0.0,
              (double previousValue, element) =>
                  previousValue + double.parse(element.shippingRaw ?? "0"))
          .toStringAsFixed(2);
      _shippingSubtitle = _allCartsProvider.cartList!
          .map((e) => e.shipping!)
          .toList()
          .join('+');
      _handling = _allCartsProvider.cartList!
          .fold(
              0.0,
              (double previousValue, element) =>
                  previousValue + double.parse(element.handlingRaw ?? "0"))
          .toStringAsFixed(2);
      _handlingSubtitle = _allCartsProvider.cartList!
          .map((e) => e.handling!)
          .toList()
          .join('+');
      _packaging = _allCartsProvider.cartList!
          .fold(
              0.0,
              (double previousValue, element) =>
                  previousValue + double.parse(element.packagingRaw ?? "0"))
          .toStringAsFixed(2);

      _packagingSubtitle = _allCartsProvider.cartList!
          .map((e) => e.packaging!)
          .toList()
          .join('+');
      _discount = "- " +
          _allCartsProvider.cartList!
              .fold(
                  0.0,
                  (double previousValue, element) =>
                      previousValue + double.parse(element.discountRaw ?? "0"))
              .toStringAsFixed(2);
      _discountSubtitle = _allCartsProvider.cartList!
          .map((e) => e.discount!)
          .toList()
          .join('+');
      _total = _allCartsProvider.cartList!
          .fold(
              0.0,
              (double previousValue, element) =>
                  previousValue + double.parse(element.grandTotalRaw ?? "0"))
          .toStringAsFixed(2);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: isOneCheckout
          ? _allCartsProvider is CartLoadedState
              ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "${LocaleKeys.sold_by.tr()}:",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children:
                                      _allCartsProvider.cartList!.map((e) {
                                    return e.shop!.image != null
                                        ? Container(
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            width: context.screenWidth * 0.15,
                                            height: context.screenWidth * 0.10,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Tooltip(
                                              message: e.shop!.name,
                                              child: CachedNetworkImage(
                                                imageUrl: e.shop!.image!,
                                                fit: BoxFit.contain,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const SizedBox(),
                                                progressIndicatorBuilder:
                                                    (context, url, progress) =>
                                                        Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value: progress
                                                              .progress),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox();
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Divider(height: 8),

                            //1%&>RUz@

                            ..._allCartsProvider.cartList!
                                .map((e) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: CheckoutDetailsSingleCartItemCard(
                                          cartItems: e.items!),
                                    ))
                                .toList(),

                            CheckOutDetailsPriceWidget(
                                title: LocaleKeys.cart_count.tr(),
                                price: _cartCount),

                            CheckOutDetailsPriceWidget(
                              title: LocaleKeys.item_count.tr(),
                              price: _itemCount,
                              subtitle: _itemCountSubtitle,
                            ),
                            CheckOutDetailsPriceWidget(
                              title: LocaleKeys.total_quantity.tr(),
                              price: _quantity,
                              subtitle: _quantitySubtitle,
                            ),

                            CurrencySymbolWidget(
                              builder: (context, symbol) => symbol == null
                                  ? CheckOutDetailsPriceWidget(
                                      title: LocaleKeys.subtotal.tr(),
                                      price: _subTotal,
                                      subtitle: _subTotalSubtitle,
                                    )
                                  : CheckOutDetailsPriceWidget(
                                      title: LocaleKeys.subtotal.tr(),
                                      price: symbol + _subTotal,
                                      subtitle: _subTotalSubtitle,
                                    ),
                            ),

                            if (double.parse(_shipping) > 0)
                              CurrencySymbolWidget(
                                builder: (context, symbol) => symbol == null
                                    ? CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.shipping.tr(),
                                        price: _shipping,
                                        subtitle: _shippingSubtitle,
                                      )
                                    : CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.shipping.tr(),
                                        price: symbol + _shipping,
                                        subtitle: _shippingSubtitle,
                                      ),
                              ),

                            if (double.parse(_handling) > 0)
                              CurrencySymbolWidget(
                                builder: (context, symbol) => symbol == null
                                    ? CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.handling.tr(),
                                        price: _handling,
                                        subtitle: _handlingSubtitle,
                                      )
                                    : CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.handling.tr(),
                                        price: symbol + _handling,
                                        subtitle: _handlingSubtitle,
                                      ),
                              ),

                            if (double.parse(_packaging) > 0)
                              CurrencySymbolWidget(
                                builder: (context, symbol) => symbol == null
                                    ? CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.packaging.tr(),
                                        price: _packaging,
                                        subtitle: _packagingSubtitle,
                                      )
                                    : CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.packaging.tr(),
                                        price: symbol + _packaging,
                                        subtitle: _packagingSubtitle,
                                      ),
                              ),

                            if (double.parse(_discount.substring(2)) > 0)
                              CurrencySymbolWidget(
                                builder: (context, symbol) => symbol == null
                                    ? CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.discount.tr(),
                                        price: _discount,
                                        subtitle: _discountSubtitle,
                                      )
                                    : CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.discount.tr(),
                                        price: _discount.insert(symbol, 2),
                                        subtitle: _discountSubtitle,
                                      ),
                              ),

                            const Divider(),
                            CurrencySymbolWidget(
                                builder: (context, symbol) => symbol == null
                                    ? CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.total.tr(),
                                        price: _total,
                                        isGrandTotal: true,
                                      )
                                    : CheckOutDetailsPriceWidget(
                                        title: LocaleKeys.total.tr(),
                                        price: symbol + _total,
                                        isGrandTotal: true,
                                      )),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (!isKeyboardVisible)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                onPressed: onPressedBack,
                                child: Text(
                                  LocaleKeys.back.tr(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                onPressed: onPressedNext,
                                child: Text(
                                  LocaleKeys.next.tr(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : const SizedBox()
          : _cartDetailsProvider is CartItemDetailsLoadedState
              ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomShopCard(
                              image: _cartDetailsProvider
                                  .cartItemDetails!.data!.shop!.image,
                              title: _cartDetailsProvider
                                      .cartItemDetails!.data!.shop!.name ??
                                  LocaleKeys.unknown.tr(),
                              verifiedText: _cartDetailsProvider
                                      .cartItemDetails!
                                      .data!
                                      .shop!
                                      .verifiedText ??
                                  "",
                            ),

                            ApplyCouponSection(
                                cartId: _cartDetailsProvider
                                    .cartItemDetails!.data!.id!),
                            const SizedBox(height: 8),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              child: CheckoutDetailsSingleCartItemCard(
                                  cartItems: _cartDetailsProvider
                                      .cartItemDetails!.data!.items!),
                            ),
                            CheckOutDetailsPriceWidget(
                                title: LocaleKeys.sub_total.tr(),
                                price: _cartDetailsProvider
                                        .cartItemDetails!.data!.total ??
                                    "0"),
                            if (double.parse(_cartDetailsProvider
                                        .cartItemDetails!.data!.shippingRaw ??
                                    "0") >
                                0)
                              CheckOutDetailsPriceWidget(
                                  title: LocaleKeys.shipping.tr(),
                                  price: _cartDetailsProvider
                                          .cartItemDetails!.data!.shipping ??
                                      "0"),
                            if (double.parse(_cartDetailsProvider
                                        .cartItemDetails!.data!.handlingRaw ??
                                    "0") >
                                0)
                              CheckOutDetailsPriceWidget(
                                  title: LocaleKeys.handling.tr(),
                                  price: _cartDetailsProvider
                                          .cartItemDetails!.data!.handling ??
                                      "0"),
                            if (double.parse(_cartDetailsProvider
                                        .cartItemDetails!.data!.packagingRaw ??
                                    "0") >
                                0)
                              CheckOutDetailsPriceWidget(
                                  title: LocaleKeys.packaging.tr(),
                                  price: _cartDetailsProvider
                                          .cartItemDetails!.data!.packaging ??
                                      "0"),
                            if (double.parse(_cartDetailsProvider
                                        .cartItemDetails!.data!.taxesRaw ??
                                    "0") >
                                0)
                              CheckOutDetailsPriceWidget(
                                  title: LocaleKeys.taxes.tr(),
                                  price: _cartDetailsProvider
                                          .cartItemDetails!.data!.taxes ??
                                      "0"),
                            if (double.parse(_cartDetailsProvider
                                        .cartItemDetails!.data!.discountRaw ??
                                    "0") >
                                0)
                              CheckOutDetailsPriceWidget(
                                  title: LocaleKeys.discount.tr(),
                                  price: "- " +
                                      (_cartDetailsProvider.cartItemDetails!
                                              .data!.discount ??
                                          "0")),
                            const Divider(),
                            //Grand Total
                            CheckOutDetailsPriceWidget(
                                isGrandTotal: true,
                                title: LocaleKeys.grand_total.tr(),
                                price: _cartDetailsProvider
                                        .cartItemDetails!.data!.grandTotal ??
                                    "0"),
                          ],
                        ),
                      ),
                    ),
                    if (!isKeyboardVisible)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                onPressed: onPressedBack,
                                child: Text(LocaleKeys.back.tr()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                onPressed: onPressedNext,
                                child: Text(LocaleKeys.next.tr()),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : const Center(child: LoadingWidget()),
    );
  }
}

class ApplyCouponSection extends StatefulWidget {
  final int cartId;
  const ApplyCouponSection({
    Key? key,
    required this.cartId,
  }) : super(key: key);

  @override
  State<ApplyCouponSection> createState() => _ApplyCouponSectionState();
}

class _ApplyCouponSectionState extends State<ApplyCouponSection> {
  final _couponCodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoTextField(
        controller: _couponCodeController,
        placeholder: LocaleKeys.enter_coupon_code.tr(),
        style:
            context.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
        suffixMode: OverlayVisibilityMode.editing,
        suffix: CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            LocaleKeys.apply_coupon.tr(),
            style: context.textTheme.subtitle2!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          borderRadius: BorderRadius.circular(0),
          onPressed: () async {
            if (_couponCodeController.text.isNotEmpty) {
              await context
                  .read(applyCouponProvider.notifier)
                  .applyCoupon(widget.cartId, _couponCodeController.text.trim())
                  .then((value) {
                if (value) {
                  _couponCodeController.text = "";
                  context
                      .read(cartItemDetailsNotifierProvider.notifier)
                      .getCartItemDetails(widget.cartId);
                }
              });
            } else {
              toast(LocaleKeys.enter_coupon_code.tr());
            }
          },
        ),
        prefix: CupertinoButton.filled(
          borderRadius: const BorderRadius.only(
              topRight: Radius.zero, bottomRight: Radius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.confirmation_num,
              color:
                  getColorBasedOnTheme(context, kDarkBgColor, kLightBgColor)),
          onPressed: null,
        ),
      ),
    );
  }
}

class CustomShopCard extends StatelessWidget {
  final String? image;
  final String title;
  final String verifiedText;
  const CustomShopCard({
    Key? key,
    required this.image,
    required this.title,
    required this.verifiedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: image != null
            ? CachedNetworkImage(
                imageUrl: image!,
                width: context.screenWidth * 0.15,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => const SizedBox(),
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(value: progress.progress),
                ),
              ).p(5)
            : const SizedBox(),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: context.textTheme.headline6,
              ),
            ),
            const Icon(Icons.check_circle, color: kGreenColor, size: 15)
                .px(4)
                .pOnly(top: 3)
                .onInkTap(() {
              toast(verifiedText);
            })
          ],
        ),
      ),
    );
  }
}

class CheckOutDetailsPriceWidget extends StatelessWidget {
  final String title;
  final String price;
  final bool isGrandTotal;
  final String? subtitle;
  const CheckOutDetailsPriceWidget({
    Key? key,
    required this.title,
    required this.price,
    this.isGrandTotal = false,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: isGrandTotal
            ? context.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold)
            : context.textTheme.subtitle2!.copyWith(),
      ),
      subtitle: subtitle != null ? Text("(${subtitle!})") : null,
      trailing: Text(
        price,
        style: context.textTheme.subtitle2!.copyWith(
            fontWeight: FontWeight.bold,
            color: getColorBasedOnTheme(context, kPriceColor, kDarkPriceColor)),
      ),
    );
  }
}

class CheckoutDetailsSingleCartItemCard extends StatelessWidget {
  final List<dynamic> cartItems;
  const CheckoutDetailsSingleCartItemCard({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: cartItems.map((cartItem) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: cartItem.image!,
                      width: 80,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const SizedBox(),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child:
                            CircularProgressIndicator(value: progress.progress),
                      ),
                    ),
                  ).pOnly(right: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cartItem.description!,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.subtitle2!.copyWith())
                            .pOnly(right: 10),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.unitPrice!,
                              style: context.textTheme.bodyText2!.copyWith(
                                  color: getColorBasedOnTheme(
                                      context, kPriceColor, kDarkPriceColor),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              " x " + cartItem.quantity!.toString(),
                              style: context.textTheme.bodyText2!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 0)
                  .visible(cartItems.length != 1)
                  .visible(cartItems.indexOf(cartItem) != cartItems.length - 1),
              const SizedBox(height: 12)
                  .visible(cartItems.length != 1)
                  .visible(cartItems.indexOf(cartItem) != cartItems.length - 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class CheckoutPaymentPage extends StatefulWidget {
  final String? customerEmail;
  final cart_item_details_model.CartItemDetailsModel? cartItemDetails;
  final Addresses? address;
  final bool isKeyboardVisible;
  final bool isOneCheckout;
  const CheckoutPaymentPage({
    Key? key,
    this.customerEmail,
    this.cartItemDetails,
    required this.address,
    required this.isKeyboardVisible,
    this.isOneCheckout = false,
  }) : super(key: key);

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  String _selectedPaymentMethod = "";
  String? _prescriptionImage;
  final _aditionalNotesController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  final TextEditingController _confirmPassWordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  bool _createNewAccount = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Consumer(
        builder: (context, watch, _) {
          final _paymentOptionsState = watch(paymentOptionsNotifierProvider);
          final _pharmacyCheckProvider = watch(checkPharmacyPluginProvider);
          int _grandTotal = 0;
          final List<CartItemForPayment> _cartItems = [];
          String _packaging = "";
          String _shipping = "";
          String _handling = "";
          String _subtotal = "";
          String _tax = "";
          String _discount = "";

          final _cartProvider = watch(cartNotifierProvider);

          if (widget.isOneCheckout) {
            if (_cartProvider is CartLoadedState) {
              String _total = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.grandTotalRaw ?? " 0.0"))
                  .toStringAsFixed(2);

              _grandTotal = (double.parse(_total) * 100).toInt();

              _packaging = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.packagingRaw ?? " 0.0"))
                  .toStringAsFixed(2);
              _shipping = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.shippingRaw ?? " 0.0"))
                  .toStringAsFixed(2);
              _handling = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.handlingRaw ?? " 0.0"))
                  .toStringAsFixed(2);
              String _sub = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.totalRaw ?? " 0.0"))
                  .toStringAsFixed(2);
              _subtotal = (double.parse(_sub) * 100).toInt().toString();

              _tax = _cartProvider.cartList!
                  .fold(
                      0.0,
                      (double previousValue, element) =>
                          previousValue +
                          double.parse(element.taxesRaw ?? " 0.0"))
                  .toStringAsFixed(2);
              _discount = "-" +
                  _cartProvider.cartList!
                      .fold(
                          0.0,
                          (double previousValue, element) =>
                              previousValue +
                              double.parse(element.discountRaw ?? " 0.0"))
                      .toStringAsFixed(2);
              for (var element in _cartProvider.cartList!) {
                for (var item in element.items!) {
                  var _cartItem = CartItemForPayment(
                    name: item.slug ?? " ",
                    description: item.description ?? " ",
                    quantity: item.quantity ?? 1,
                    price: item.unitPrice ?? "0.0",
                    sku: item.id.toString(),
                  );
                  _cartItems.add(_cartItem);
                }
              }
            }
          } else {
            String _total = double.parse(
                    widget.cartItemDetails!.data!.grandTotalRaw ?? " 0.0")
                .toStringAsFixed(2);

            _grandTotal = (double.parse(_total) * 100).toInt();

            _packaging = double.parse(
                    widget.cartItemDetails!.data!.packagingRaw ?? " 0.0")
                .toStringAsFixed(2);

            _shipping = double.parse(
                    widget.cartItemDetails!.data!.shippingRaw ?? " 0.0")
                .toStringAsFixed(2);

            _handling = double.parse(
                    widget.cartItemDetails!.data!.handlingRaw ?? " 0.0")
                .toStringAsFixed(2);

            String _sub =
                double.parse(widget.cartItemDetails!.data!.totalRaw ?? " 0.0")
                    .toStringAsFixed(2);

            _subtotal = (double.parse(_sub) * 100).toInt().toString();

            _tax =
                double.parse(widget.cartItemDetails!.data!.taxesRaw ?? " 0.0")
                    .toStringAsFixed(2);

            _discount = "-" +
                double.parse(
                        widget.cartItemDetails!.data!.discountRaw ?? " 0.0")
                    .toStringAsFixed(2);

            for (var item in widget.cartItemDetails!.data!.items!) {
              var _cartItem = CartItemForPayment(
                name: item.slug ?? " ",
                description: item.description ?? " ",
                quantity: item.quantity ?? 1,
                price: item.unitPrice ?? "0.0",
                sku: item.id.toString(),
              );
              _cartItems.add(_cartItem);
            }
          }

          // print("Grand Total: " + _grandTotal.toString());
          // print("Packaging: " + _packaging);
          // print("Shipping: " + _shipping);
          // print("Handling: " + _handling);
          // print("Subtotal: " + _subtotal);
          // print("Tax: " + _tax);
          // print("Discount: " + _discount);
          // print("Cart Items: " + _cartItems.length.toString());

          if (_paymentOptionsState is PaymentOptionsLoadedState) {
            List<PaymentOptions>? _paymentOptions =
                _paymentOptionsState.paymentOptions;

            List<PaymentOptions>? _implementedPaymentOptions =
                _paymentOptions?.where((element) {
              if (paymentMethods.contains(element.code)) {
                if (element.code! == zcartWallet) {
                  if (accessAllowed) {
                    return true;
                  } else {
                    return false;
                  }
                } else {
                  return true;
                }
              } else {
                return false;
              }
            }).toList();

            _implementedPaymentOptions!
                .sort((a, b) => a.order!.compareTo(b.order!));

            return _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const LoadingWidget(),
                        const SizedBox(height: 10),
                        Text(
                          LocaleKeys.order_is_being_processed.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: getColorBasedOnTheme(
                                      context, kLightColor, kDarkCardBgColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        LocaleKeys.payment_method.tr(),
                                        style: context.textTheme.headline6!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    ListView(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children:
                                            _implementedPaymentOptions.map((e) {
                                          String _code = e.code!;
                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(0),
                                            onTap: () async {
                                              setState(() {
                                                _selectedPaymentMethod = _code;
                                              });

                                              context
                                                  .read(checkoutNotifierProvider
                                                      .notifier)
                                                  .paymentMethod = e.code;
                                            },
                                            title: Text(
                                              e.name!,
                                              style: context
                                                  .textTheme.subtitle2!
                                                  .copyWith(
                                                fontWeight: _code ==
                                                        _selectedPaymentMethod
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            trailing: _code ==
                                                    _selectedPaymentMethod
                                                ? Icon(Icons.check_circle,
                                                    color: kPrimaryColor)
                                                : Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: getColorBasedOnTheme(
                                                        context,
                                                        kDarkColor,
                                                        kLightColor),
                                                  ),
                                          );
                                        }).toList()),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _pharmacyCheckProvider.when(
                                data: (value) {
                                  if (value) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(LocaleKeys.prescription.tr(),
                                                style: context
                                                    .textTheme.bodyText2),
                                          ],
                                        ).pOnly(top: 10, bottom: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            await pickImageToBase64()
                                                .then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  _prescriptionImage = value;
                                                });

                                                context
                                                    .read(
                                                        checkoutNotifierProvider
                                                            .notifier)
                                                    .prescription = value;
                                              }
                                            });
                                          },
                                          child: Container(
                                            color: getColorBasedOnTheme(context,
                                                kLightColor, kDarkCardBgColor),
                                            padding: const EdgeInsets.all(10),
                                            height: 200,
                                            child: _prescriptionImage != null
                                                ? Image.memory(
                                                    base64Decode(
                                                        _prescriptionImage!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      const Icon(Icons.image)
                                                          .pOnly(bottom: 5),
                                                      Text(
                                                        LocaleKeys.choose_image
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                          ).cornerRadius(10),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                                loading: () {
                                  return const SizedBox();
                                },
                                error: (error, stackTrace) {
                                  return Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                        LocaleKeys.something_went_wrong.tr()),
                                  ));
                                },
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: getColorBasedOnTheme(
                                      context, kLightColor, kDarkCardBgColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      LocaleKeys.note_for_seller.tr(),
                                      style:
                                          context.textTheme.headline6!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    CustomTextField(
                                      controller: _aditionalNotesController,
                                      maxLines: 5,
                                      hintText: LocaleKeys.note_for_seller.tr(),
                                      onChanged: (value) {
                                        context
                                            .read(checkoutNotifierProvider
                                                .notifier)
                                            .buyerNote = value;
                                      },
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              accessAllowed
                                  ? const SizedBox()
                                  : Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: getColorBasedOnTheme(context,
                                              kLightColor, kDarkCardBgColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 10),
                                            ),
                                          ]),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(LocaleKeys.guest_checkout.tr(),
                                                    style: context
                                                        .textTheme.headline6)
                                                .pOnly(bottom: 10),
                                            Form(
                                              key: _emailFormKey,
                                              child: CustomTextField(
                                                hintText:
                                                    LocaleKeys.your_email.tr(),
                                                controller: _emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator: (value) {
                                                  if (value != null) {
                                                    if (!value.contains('@') ||
                                                        !value.contains('.')) {
                                                      return LocaleKeys
                                                          .invalid_email
                                                          .tr();
                                                    }
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  context
                                                      .read(
                                                          checkoutNotifierProvider
                                                              .notifier)
                                                      .email = value;
                                                },
                                              ),
                                            ),
                                            ListTile(
                                              title: Text(LocaleKeys
                                                  .create_account
                                                  .tr()),
                                              minLeadingWidth: 0,
                                              onTap: () {
                                                setState(() {
                                                  _createNewAccount =
                                                      !_createNewAccount;
                                                });
                                                context
                                                        .read(
                                                            checkoutNotifierProvider
                                                                .notifier)
                                                        .createAccount =
                                                    _createNewAccount;
                                              },
                                              leading: Icon(_createNewAccount
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked),
                                            ),
                                            Visibility(
                                              visible: _createNewAccount,
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  children: [
                                                    CustomTextField(
                                                      isPassword: true,
                                                      title: LocaleKeys
                                                          .your_password
                                                          .tr(),
                                                      hintText: LocaleKeys
                                                          .your_password
                                                          .tr(),
                                                      keyboardType:
                                                          TextInputType
                                                              .visiblePassword,
                                                      controller:
                                                          _passWordController,
                                                      validator: (value) {
                                                        if (value != null) {
                                                          if (value.length <
                                                              6) {
                                                            return LocaleKeys
                                                                .password_validation
                                                                .tr();
                                                          }
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (value) {
                                                        context
                                                            .read(
                                                                checkoutNotifierProvider
                                                                    .notifier)
                                                            .password = value;
                                                      },
                                                    ),
                                                    CustomTextField(
                                                      isPassword: true,
                                                      title: LocaleKeys
                                                          .your_confirm_password
                                                          .tr(),
                                                      hintText: LocaleKeys
                                                          .your_confirm_password
                                                          .tr(),
                                                      keyboardType:
                                                          TextInputType
                                                              .visiblePassword,
                                                      controller:
                                                          _confirmPassWordController,
                                                      validator: (value) {
                                                        if (value != null) {
                                                          if (value.length <
                                                              6) {
                                                            return LocaleKeys
                                                                .password_validation
                                                                .tr();
                                                          }
                                                          {
                                                            if (value !=
                                                                _passWordController
                                                                    .text) {
                                                              return LocaleKeys
                                                                  .dont_match_password
                                                                  .tr();
                                                            }
                                                          }
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (value) {
                                                        context
                                                            .read(
                                                                checkoutNotifierProvider
                                                                    .notifier)
                                                            .passwordConfirm = value;
                                                      },
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        setState(() {
                                                          _agreedToTerms =
                                                              !_agreedToTerms;
                                                        });
                                                        context
                                                                .read(checkoutNotifierProvider
                                                                    .notifier)
                                                                .agreeToTerms =
                                                            _agreedToTerms;
                                                      },
                                                      minLeadingWidth: 0,
                                                      leading: Icon(_agreedToTerms
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .radio_button_unchecked),
                                                      title: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const TermsAndConditionScreen()));
                                                        },
                                                        child: Text(LocaleKeys
                                                            .agree_terms
                                                            .tr()),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      if (!widget.isKeyboardVisible)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_selectedPaymentMethod.isEmpty) {
                                      toast(LocaleKeys
                                          .select_payment_method_continue
                                          .tr());
                                    } else {
                                      if (!accessAllowed) {
                                        if (_createNewAccount) {
                                          if (_emailFormKey.currentState!
                                              .validate()) {
                                            if (_agreedToTerms) {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                await PaymentMethods.pay(
                                                  context,
                                                  _selectedPaymentMethod,
                                                  email: _emailController.text
                                                      .trim(),
                                                  grandTotal: _grandTotal,
                                                  invoiceNumber: widget
                                                      .cartItemDetails!
                                                      .data!
                                                      .id!
                                                      .toString(),
                                                  shippingId: widget
                                                      .cartItemDetails!
                                                      .data!
                                                      .shippingOptionId,
                                                  address: widget.address,
                                                  cartId: widget.isOneCheckout
                                                      ? null
                                                      : widget.cartItemDetails!
                                                          .data!.id,
                                                  currency: widget
                                                      .cartItemDetails!
                                                      .meta!
                                                      .currency,
                                                  cartItems: _cartItems,
                                                  discount: _discount,
                                                  handling: _handling,
                                                  packaging: _packaging,
                                                  shipping: _shipping,
                                                  subtotal: _subtotal,
                                                  taxes: _tax,
                                                ).then((value) async {
                                                  if (value) {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    await context
                                                        .read(
                                                            checkoutNotifierProvider
                                                                .notifier)
                                                        .guestCheckout(
                                                            isOneCheckout: widget
                                                                .isOneCheckout);
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    if (_selectedPaymentMethod ==
                                                        zcartWallet) {
                                                      context.refresh(
                                                          walletBalanceProvider);
                                                      context.refresh(
                                                          walletTransactionFutureProvider);
                                                    }
                                                  } else {
                                                    toast(LocaleKeys
                                                        .payment_failed
                                                        .tr());
                                                  }
                                                });
                                              }
                                            } else {
                                              toast(LocaleKeys
                                                  .please_agree_terms
                                                  .tr());
                                            }
                                          } else {
                                            toast(
                                                LocaleKeys.invalid_email.tr());
                                          }
                                        } else {
                                          if (_emailFormKey.currentState!
                                              .validate()) {
                                            await PaymentMethods.pay(
                                              context,
                                              _selectedPaymentMethod,
                                              email:
                                                  _emailController.text.trim(),
                                              grandTotal: _grandTotal,
                                              invoiceNumber: widget
                                                  .cartItemDetails!.data!.id!
                                                  .toString(),
                                              shippingId: widget
                                                  .cartItemDetails!
                                                  .data!
                                                  .shippingOptionId,
                                              address: widget.address,
                                              cartId: widget.isOneCheckout
                                                  ? null
                                                  : widget.cartItemDetails!
                                                      .data!.id,
                                              currency: widget.cartItemDetails!
                                                  .meta!.currency,
                                              cartItems: _cartItems,
                                              discount: _discount,
                                              handling: _handling,
                                              packaging: _packaging,
                                              shipping: _shipping,
                                              subtotal: _subtotal,
                                              taxes: _tax,
                                            ).then((value) async {
                                              if (value) {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                await context
                                                    .read(
                                                        checkoutNotifierProvider
                                                            .notifier)
                                                    .guestCheckout(
                                                        isOneCheckout: widget
                                                            .isOneCheckout);
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                if (_selectedPaymentMethod ==
                                                    zcartWallet) {
                                                  context.refresh(
                                                      walletBalanceProvider);
                                                  context.refresh(
                                                      walletTransactionFutureProvider);
                                                }
                                              } else {
                                                toast(LocaleKeys.payment_failed
                                                    .tr());
                                              }
                                            });
                                          } else {
                                            toast(
                                                LocaleKeys.invalid_email.tr());
                                          }
                                        }
                                      } else {
                                        await PaymentMethods.pay(
                                          context,
                                          _selectedPaymentMethod,
                                          email: widget.customerEmail!,
                                          grandTotal: _grandTotal,
                                          shippingId: widget.cartItemDetails!
                                              .data!.shippingOptionId,
                                          invoiceNumber: widget
                                              .cartItemDetails!.data!.id!
                                              .toString(),
                                          address: widget.address,
                                          cartId: widget.isOneCheckout
                                              ? null
                                              : widget
                                                  .cartItemDetails!.data!.id,
                                          currency: widget
                                              .cartItemDetails!.meta!.currency,
                                          cartItems: _cartItems,
                                          discount: _discount,
                                          handling: _handling,
                                          packaging: _packaging,
                                          shipping: _shipping,
                                          subtotal: _subtotal,
                                          taxes: _tax,
                                        ).then((value) async {
                                          if (value) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            await context
                                                .read(checkoutNotifierProvider
                                                    .notifier)
                                                .checkout(
                                                    isOneCheckout:
                                                        widget.isOneCheckout);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            if (_selectedPaymentMethod ==
                                                zcartWallet) {
                                              context.refresh(
                                                  walletBalanceProvider);
                                              context.refresh(
                                                  walletTransactionFutureProvider);
                                            }
                                          } else {
                                            toast(
                                                LocaleKeys.payment_failed.tr());
                                          }
                                        });
                                      }
                                    }
                                  },
                            child: Text(LocaleKeys.proceed_to_checkout.tr()),
                          ),
                        ),
                    ],
                  );
          } else {
            return Center(
              child: Text(LocaleKeys.something_went_wrong.tr()),
            );
          }
        },
      ),
    );
  }
}

class CheckOutProgressItem extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  final Color progressColor;
  const CheckOutProgressItem({
    Key? key,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.icon,
    required this.progressColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _strokeWidth = 2.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: isFirst
                    ? const SizedBox()
                    : Container(height: _strokeWidth, color: progressColor),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: progressColor, width: _strokeWidth),
                ),
                child: Icon(icon, color: progressColor, size: 14),
              ),
              Expanded(
                child: isLast
                    ? const SizedBox()
                    : Container(height: _strokeWidth, color: progressColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: context.textTheme.overline!
                .copyWith(fontWeight: FontWeight.bold, color: progressColor),
          ),
        ],
      ),
    );
  }
}

class CheckOutProgress {
  String title;
  IconData icon;
  CheckOutProgress({
    required this.title,
    required this.icon,
  });
}

List<CheckOutProgress> _progressItems = [
  CheckOutProgress(
    title: LocaleKeys.shipping.tr(),
    icon: Icons.local_shipping,
  ),
  CheckOutProgress(
    title: LocaleKeys.order_details.tr(),
    icon: Icons.receipt,
  ),
  CheckOutProgress(
    title: LocaleKeys.payment.tr(),
    icon: Icons.payment,
  ),
];

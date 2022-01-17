import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/dark_theme.dart';
import 'package:zcart/Theme/light_theme.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/models/address/payment_options_model.dart';
import 'package:zcart/data/models/address/shipping_model.dart';
import 'package:zcart/data/models/cart/cart_item_details_model.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/get_amount_from_string.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/riverpod/state/checkout_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/startup/loading_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/add_address_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/terms_and_conditions_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/address_list_widget.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'package:zcart/views/shared_widgets/dropdown_field_loading_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final String? customerEmail;
  const CheckoutScreen({
    Key? key,
    this.customerEmail,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final StepperType _stepperType = StepperType.vertical;

  //Conditions
  int? _selectedAddressIndex;
  int? _selectedShippingOptionsIndex;
  int? _selectedPackagingIndex;
  int? _selectedPaymentIndex;
  String _paymentMethodCode = "";

  /// Coupon
  bool _showApplyButton = false;
  final TextEditingController _couponController = TextEditingController();
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
    return ProviderListener<CheckoutState>(
      provider: checkoutNotifierProvider,
      onChange: (context, state) async {
        if (state is CheckoutLoadedState) {
          toast(LocaleKeys.order_place_confirmation.tr());
          if (state.accessToken != null) {
            toast(LocaleKeys.register_successful.tr());
            await setValue(loggedIn, true);
            await setValue(access, state.accessToken).then((value) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const LoadingScreen()),
                  (Route<dynamic> route) => false);
            });
          } else {
            context.pop();
          }
        }
      },
      child: ProviderListener<CartItemDetailsState>(
        provider: cartItemDetailsNotifierProvider,
        onChange: (context, state) {
          if (state is CartItemDetailsLoadedState) {
            context.read(checkoutNotifierProvider.notifier).cartId =
                state.cartItemDetails!.data!.id;
          }
        },
        child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: Text(LocaleKeys.checkout.tr()),
            ),
            body: Consumer(builder: (context, watch, _) {
              final cartItemDetailsState =
                  watch(cartItemDetailsNotifierProvider);
              final addressState = watch(addressNotifierProvider);

              return Column(
                children: [
                  Expanded(
                    child: Theme(
                      data: ThemeData(
                        textTheme: EasyDynamicTheme.of(context).themeMode ==
                                ThemeMode.dark
                            ? darkTextTheme(context)
                            : EasyDynamicTheme.of(context).themeMode ==
                                    ThemeMode.system
                                ? SchedulerBinding.instance!.window
                                            .platformBrightness ==
                                        Brightness.dark
                                    ? darkTextTheme(context)
                                    : lightTextTheme(context)
                                : lightTextTheme(context),
                        colorScheme: ColorScheme.light(
                            primary: kPrimaryColor, secondary: kAccentColor),
                      ),
                      child: Stepper(
                        controlsBuilder: (context, details) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: getColorBasedOnTheme(context,
                                        kDarkCardBgColor, kLightCardBgColor),
                                    onPrimary: kLightColor,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: details.onStepCancel,
                                  child: const Text("Back"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryColor,
                                    onPrimary: kLightColor,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: details.onStepContinue,
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          );
                        },
                        type: _stepperType,
                        physics: const BouncingScrollPhysics(),
                        currentStep: _currentStep,
                        onStepTapped: (step) => tapped(step),
                        onStepContinue: _isLoading
                            ? null
                            : () {
                                continued(cartItemDetailsState, addressState);
                              },
                        onStepCancel: cancel,
                        steps: <Step>[
                          /// Shipping
                          _shipping(context, cartItemDetailsState),

                          /// Order options
                          _orderOptions(cartItemDetailsState),

                          /// Place order
                          _placeOrder(cartItemDetailsState, context),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            })),
      ),
    );
  }

  Step _placeOrder(
      CartItemDetailsState cartItemDetailsState, BuildContext context) {
    return Step(
      title: Text(
        LocaleKeys.place_order.tr(),
        style: context.textTheme.subtitle2,
      ),
      content: Container(
        color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
        padding: const EdgeInsets.all(10),
        child: cartItemDetailsState is CartItemDetailsLoadedState
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItemDetailsState
                          .cartItemDetails!.data!.items!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: cartItemDetailsState
                                .cartItemDetails!.data!.items![index].image!,
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: CircularProgressIndicator(
                                  value: progress.progress),
                            ),
                            width: 40,
                            height: 40,
                          ),
                          title: Text(cartItemDetailsState.cartItemDetails!
                              .data!.items![index].description!),
                          subtitle: Text(
                              cartItemDetailsState.cartItemDetails!.data!
                                  .items![index].unitPrice!,
                              style: context.textTheme.subtitle2!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: getColorBasedOnTheme(
                                    context, kPriceColor, kDarkPriceColor),
                              )),
                          trailing: Text('x ' +
                              cartItemDetailsState
                                  .cartItemDetails!.data!.items![index].quantity
                                  .toString()),
                        );
                      }),
                  Text('\n${LocaleKeys.order_summary.tr()}\n',
                      style: context.textTheme.subtitle2),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.sub_total.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.total!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.discount.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.discount!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.packaging.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.packaging!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.shipping.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.shipping!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.handling.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.handling!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.taxes.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  '${cartItemDetailsState.cartItemDetails!.data!.taxes} (${cartItemDetailsState.cartItemDetails!.data!.taxrate})',
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                      Divider(
                        endIndent: MediaQuery.of(context).size.width * 0.3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text("${LocaleKeys.grand_total.tr()}: ")),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  cartItemDetailsState
                                      .cartItemDetails!.data!.grandTotal!,
                                  style: context.textTheme.subtitle2)),
                        ],
                      ),
                    ],
                  ).pOnly(bottom: 10),
                  const Divider(
                    height: 16,
                    thickness: 2,
                  ),
                  CustomTextField(
                    title: LocaleKeys.apply_coupon.tr(),
                    hintText: LocaleKeys.enter_coupon_code.tr(),
                    controller: _couponController,
                    onChanged: (value) {
                      if (!_showApplyButton) {
                        setState(() {
                          _showApplyButton = true;
                        });
                      }
                    },
                  ),
                  Visibility(
                    visible: _showApplyButton,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            context
                                .read(applyCouponProvider.notifier)
                                .applyCoupon(
                                    cartItemDetailsState
                                        .cartItemDetails!.data!.id,
                                    _couponController.text)
                                .then((value) => context
                                    .read(cartItemDetailsNotifierProvider
                                        .notifier)
                                    .getCartItemDetails(cartItemDetailsState
                                        .cartItemDetails!.data!.id));
                          },
                          child: Text(LocaleKeys.apply.tr(),
                              style: TextStyle(color: kPrimaryColor)),
                        ),
                      ],
                    ),
                  ),
                  CustomTextField(
                      title: LocaleKeys.buyers_note.tr(),
                      hintText: LocaleKeys.note_for_seller.tr(),
                      maxLines: null,
                      onChanged: (value) => context
                          .read(checkoutNotifierProvider.notifier)
                          .buyerNote = value).pOnly(bottom: 5),
                  accessAllowed
                      ? const SizedBox()
                      : Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: getColorBasedOnTheme(
                                  context, kLightBgColor, kDarkBgColor),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 10),
                                ),
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Guest Checkout",
                                        style: context.textTheme.headline6)
                                    .pOnly(bottom: 10),
                                Form(
                                  key: _emailFormKey,
                                  child: CustomTextField(
                                    hintText: LocaleKeys.your_email.tr(),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value != null) {
                                        if (!value.contains('@') ||
                                            !value.contains('.')) {
                                          return LocaleKeys.invalid_email.tr();
                                        }
                                      }
                                    },
                                    onChanged: (value) {
                                      context
                                          .read(
                                              checkoutNotifierProvider.notifier)
                                          .email = value;
                                    },
                                  ),
                                ),
                                CheckboxListTile(
                                  checkColor: kLightColor,
                                  activeColor: kPrimaryColor,
                                  value: _createNewAccount,
                                  onChanged: (value) {
                                    setState(() {
                                      _createNewAccount = value!;
                                    });
                                    context
                                        .read(checkoutNotifierProvider.notifier)
                                        .createAccount = value;
                                  },
                                  title: Text(LocaleKeys.create_account.tr()),
                                ),
                                Visibility(
                                  visible: _createNewAccount,
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        CustomTextField(
                                          isPassword: true,
                                          title: LocaleKeys.your_password.tr(),
                                          hintText:
                                              LocaleKeys.your_password.tr(),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          controller: _passWordController,
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.length < 6) {
                                                return LocaleKeys
                                                    .password_validation
                                                    .tr();
                                              }
                                            }
                                          },
                                          onChanged: (value) {
                                            context
                                                .read(checkoutNotifierProvider
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
                                              TextInputType.visiblePassword,
                                          controller:
                                              _confirmPassWordController,
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.length < 6) {
                                                return LocaleKeys
                                                    .password_validation
                                                    .tr();
                                              }
                                              {
                                                if (value !=
                                                    _passWordController.text) {
                                                  return LocaleKeys
                                                      .dont_match_password
                                                      .tr();
                                                }
                                              }
                                            }
                                          },
                                          onChanged: (value) {
                                            context
                                                .read(checkoutNotifierProvider
                                                    .notifier)
                                                .passwordConfirm = value;
                                          },
                                        ),
                                        CheckboxListTile(
                                          checkColor: kLightColor,
                                          activeColor: kPrimaryColor,
                                          value: _agreedToTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _agreedToTerms = value!;
                                            });
                                            context
                                                .read(checkoutNotifierProvider
                                                    .notifier)
                                                .agreeToTerms = value;
                                          },
                                          title: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const TermsAndConditionScreen()));
                                            },
                                            child: Text(
                                                LocaleKeys.agree_terms.tr()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                ],
              )
            : const SizedBox(),
      ).cornerRadius(10),
      isActive: _currentStep >= 0,
      state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
    );
  }

  Step _orderOptions(CartItemDetailsState cartItemDetailsState) {
    return Step(
      title: Text(
        LocaleKeys.order_options.tr(),
        style: context.textTheme.subtitle2,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(LocaleKeys.shipping_options.tr(),
                  style: context.textTheme.bodyText2),
            ],
          ).pOnly(bottom: 10),
          Consumer(
            builder: (context, watch, _) {
              final shippingState = watch(shippingNotifierProvider);
              return shippingState is ShippingLoadedState
                  ? cartItemDetailsState is CartItemDetailsLoadedState
                      ? shippingState.shippingOptions!.isNotEmpty
                          ? ShippingOptionsBuilder(
                              shippingOptions: shippingState.shippingOptions,
                              cartItem:
                                  cartItemDetailsState.cartItemDetails!.data,
                              onPressedCheckBox: (value) {
                                setState(() {
                                  _selectedShippingOptionsIndex = value;
                                });
                              },
                            ).cornerRadius(10)
                          : Container(
                              color: getColorBasedOnTheme(
                                  context, kLightColor, kDarkCardBgColor),
                              padding: const EdgeInsets.all(10),
                              width: context.screenWidth,
                              child: Column(
                                children: [
                                  const Icon(Icons.info_outline)
                                      .pOnly(bottom: 5),
                                  Text(
                                    LocaleKeys.no_shipping_zone.tr(),
                                    textAlign: TextAlign.center,
                                  ).pOnly(bottom: 5)
                                ],
                              ),
                            ).cornerRadius(10)
                      : ShippingOptionsBuilder(
                              onPressedCheckBox: (value) {},
                              shippingOptions: shippingState.shippingOptions)
                          .cornerRadius(10)
                  : const SizedBox();
            },
          ),
          Row(
            children: [
              Text(LocaleKeys.packaging.tr(),
                  style: context.textTheme.bodyText2),
            ],
          ).pOnly(top: 10, bottom: 10),
          Container(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: cartItemDetailsState is CartItemDetailsLoadedState
                ? PackagingListBuilder(
                    cartItem: cartItemDetailsState.cartItemDetails!.data,
                    onPressedCheckBox: (value) {
                      setState(() {
                        _selectedPackagingIndex = value;
                      });
                    },
                  )
                : const PackagingListBuilder(),
          ).cornerRadius(10),
          Row(
            children: [
              Text(LocaleKeys.payment.tr(), style: context.textTheme.bodyText2),
            ],
          ).pOnly(top: 10, bottom: 10),
          PaymentOptionsListBuilder(
            onPressedCheckBox: (value, code) {
              setState(() {
                _selectedPaymentIndex = value;
                _paymentMethodCode = code;
              });
            },
          ).cornerRadius(10)
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
    );
  }

  Step _shipping(
      BuildContext context, CartItemDetailsState cartItemDetailsState) {
    return Step(
      title: Text(
        LocaleKeys.shipping.tr(),
        style: context.textTheme.subtitle2,
      ),
      content: Column(
        children: <Widget>[
          Row(
            children: [
              Text(LocaleKeys.select_shipping_address.tr(),
                  style: context.textTheme.subtitle1),
            ],
          ).pOnly(bottom: 10),
          Container(
            color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.add_circle_outlined, color: kPrimaryColor)
                    .pOnly(right: 10),
                Text(LocaleKeys.add_address.tr(),
                    style: context.textTheme.subtitle2)
              ],
            ),
          ).onInkTap(() {
            context.read(countryNotifierProvider.notifier).getCountries();
            context.read(statesNotifierProvider.notifier).resetState();
            context.nextPage(AddNewAddressScreen(
              isAccessed: accessAllowed,
            ));
          }).cornerRadius(10),
          Consumer(
            builder: (context, watch, _) {
              final addressState = watch(addressNotifierProvider);

              return addressState is AddressLoadedState
                  ? addressState.addresses == null
                      ? const SizedBox()
                      : addressState.addresses!.isEmpty
                          ? const SizedBox()
                          : cartItemDetailsState is CartItemDetailsLoadedState
                              ? AddressListBuilder(
                                  addressesList: addressState.addresses,
                                  cartItem: cartItemDetailsState
                                      .cartItemDetails!.data,
                                  onPressedCheckBox: (value) {
                                    setState(() {
                                      _selectedAddressIndex = value;
                                    });
                                  },
                                )
                              : AddressListBuilder(
                                  addressesList: addressState.addresses)
                  : addressState is AddressLoadingState
                      ? const FieldLoading().py(5)
                      : addressState is AddressErrorState
                          ? ListTile(
                              title: Text(addressState.message,
                                  style: TextStyle(color: kPrimaryColor)),
                              leading: const Icon(Icons.dangerous),
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 0,
                            )
                          : addressState is AddressInitialState
                              ? const SizedBox()
                              : const SizedBox();
            },
          )
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued(CartItemDetailsState cartItemDetailsState,
      AddressState addressState) async {
    int _grandTotal = cartItemDetailsState is CartItemDetailsLoadedState
        ? getAmountFromString(
            cartItemDetailsState.cartItemDetails!.data!.grandTotal!)
        : 0;

    if (_currentStep == 0 && _selectedAddressIndex == null) {
      toast(
        LocaleKeys.select_shipping_address_continue.tr(),
      );
    } else if (_currentStep == 1 && _selectedShippingOptionsIndex == null) {
      toast(
        LocaleKeys.select_shipping_option_continue.tr(),
      );
    } else if (_currentStep == 1 && _selectedPackagingIndex == null) {
      toast(
        LocaleKeys.select_packaging_method_continue.tr(),
      );
    } else if (_currentStep == 1 && _selectedPaymentIndex == null) {
      toast(
        LocaleKeys.select_payment_method_continue.tr(),
      );
    } else if (_currentStep == 2) {
      if (!accessAllowed) {
        if (_createNewAccount) {
          if (_emailFormKey.currentState!.validate()) {
            if (_agreedToTerms) {
              if (_formKey.currentState!.validate()) {
                await PaymentMethods.pay(
                  context,
                  _paymentMethodCode,
                  email: _emailController.text.trim(),
                  price: _grandTotal,
                  shippingId: _selectedAddressIndex!,
                  addresses: addressState is AddressLoadedState
                      ? addressState.addresses!
                      : null,
                  cartItemDetails:
                      cartItemDetailsState is CartItemDetailsLoadedState
                          ? cartItemDetailsState.cartItemDetails!.data
                          : null,
                  cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
                      ? cartItemDetailsState.cartItemDetails!.meta
                      : null,
                ).then((value) async {
                  if (value) {
                    setState(() {
                      _isLoading = true;
                    });
                    await context
                        .read(checkoutNotifierProvider.notifier)
                        .guestCheckout();
                    setState(() {
                      _isLoading = false;
                    });
                  } else {
                    toast("Payment Failed");
                  }
                });
              }
            } else {
              toast(LocaleKeys.please_agree_terms.tr());
            }
          }
        } else {
          if (_emailFormKey.currentState!.validate()) {
            await PaymentMethods.pay(
              context,
              _paymentMethodCode,
              email: _emailController.text.trim(),
              price: _grandTotal,
              shippingId: _selectedShippingOptionsIndex!,
              addresses: addressState is AddressLoadedState
                  ? addressState.addresses!
                  : null,
              cartItemDetails:
                  cartItemDetailsState is CartItemDetailsLoadedState
                      ? cartItemDetailsState.cartItemDetails!.data
                      : null,
              cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
                  ? cartItemDetailsState.cartItemDetails!.meta
                  : null,
            ).then((value) async {
              if (value) {
                setState(() {
                  _isLoading = true;
                });
                await context
                    .read(checkoutNotifierProvider.notifier)
                    .guestCheckout();
                setState(() {
                  _isLoading = false;
                });
              } else {
                toast("Payment Failed");
              }
            });
          }
        }
      } else {
        await PaymentMethods.pay(
          context,
          _paymentMethodCode,
          shippingId: _selectedAddressIndex!,
          email: widget.customerEmail!,
          price: _grandTotal,
          addresses: addressState is AddressLoadedState
              ? addressState.addresses!
              : null,
          cartItemDetails: cartItemDetailsState is CartItemDetailsLoadedState
              ? cartItemDetailsState.cartItemDetails!.data
              : null,
          cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
              ? cartItemDetailsState.cartItemDetails!.meta
              : null,
        ).then((value) async {
          if (value) {
            setState(() {
              _isLoading = true;
            });
            await context.read(checkoutNotifierProvider.notifier).checkout();
            setState(() {
              _isLoading = false;
            });
          } else {
            toast("Payment Failed");
          }
        });
      }
    } else if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    }
  }

  cancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }
}

class PaymentOptionsListBuilder extends StatefulWidget {
  final Function(int index, String code)? onPressedCheckBox;
  const PaymentOptionsListBuilder({
    Key? key,
    this.onPressedCheckBox,
  }) : super(key: key);
  @override
  _PaymentOptionsListBuilderState createState() =>
      _PaymentOptionsListBuilderState();
}

class _PaymentOptionsListBuilderState extends State<PaymentOptionsListBuilder> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Consumer(
        builder: (context, watch, _) {
          final paymentOptionsState = watch(paymentOptionsNotifierProvider);
          if (paymentOptionsState is PaymentOptionsLoadedState) {
            List<PaymentOptions>? _paymentOptions =
                paymentOptionsState.paymentOptions;

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

            return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _implementedPaymentOptions.map((e) {
                  int _index = _implementedPaymentOptions.indexOf(e);
                  return ListTile(
                    onTap: () async {
                      widget.onPressedCheckBox!(_index, e.code!);

                      context
                          .read(checkoutNotifierProvider.notifier)
                          .paymentMethod = e.code;

                      setState(() {
                        selectedIndex = _index;
                      });
                    },
                    title: Text(e.name!),
                    trailing: _index == selectedIndex
                        ? Icon(Icons.check_circle, color: kPrimaryColor)
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: getColorBasedOnTheme(
                                context, kDarkColor, kLightColor),
                          ),
                  );
                }).toList());
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class PackagingListBuilder extends StatefulWidget {
  final CartItemDetails? cartItem;
  final Function(int)? onPressedCheckBox;

  const PackagingListBuilder({Key? key, this.cartItem, this.onPressedCheckBox})
      : super(key: key);

  @override
  _PackagingListBuilderState createState() => _PackagingListBuilderState();
}

class _PackagingListBuilderState extends State<PackagingListBuilder> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final packagingState = watch(packagingNotifierProvider);
        return packagingState is PackagingLoadedState
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packagingState.packagingList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      widget.onPressedCheckBox!(index);
                      context
                          .read(cartItemDetailsNotifierProvider.notifier)
                          .updateCart(widget.cartItem!.id,
                              packagingId:
                                  packagingState.packagingList[index].id);
                      context
                          .read(checkoutNotifierProvider.notifier)
                          .packagingId = packagingState.packagingList[index].id;
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    title: Text(packagingState.packagingList[index].cost!
                        .substring(
                            0,
                            (packagingState.packagingList[index].cost!
                                    .indexOf('.') +
                                3))),
                    subtitle: Text(packagingState.packagingList[index].name!),
                    trailing: index == selectedIndex
                        ? Icon(Icons.check_circle, color: kPrimaryColor)
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: getColorBasedOnTheme(
                                context, kDarkColor, kLightColor),
                          ),
                  );
                })
            : const SizedBox();
      },
    );
  }
}

class ShippingOptionsBuilder extends StatefulWidget {
  const ShippingOptionsBuilder({
    Key? key,
    required this.shippingOptions,
    this.cartItem,
    required this.onPressedCheckBox,
  }) : super(key: key);

  final List<ShippingOptions>? shippingOptions;
  final CartItemDetails? cartItem;
  final Function(int) onPressedCheckBox;

  @override
  _ShippingOptionsBuilderState createState() => _ShippingOptionsBuilderState();
}

class _ShippingOptionsBuilderState extends State<ShippingOptionsBuilder> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.shippingOptions!.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                widget.onPressedCheckBox(index);
                context
                    .read(cartItemDetailsNotifierProvider.notifier)
                    .updateCart(
                      widget.cartItem!.id,
                      shippingZoneId:
                          widget.shippingOptions![index].shippingZoneId,
                      shippingOptionId: widget.shippingOptions![index].id,
                    );
                context
                    .read(checkoutNotifierProvider.notifier)
                    .shippingOptionId = widget.shippingOptions![index].id;

                setState(() {
                  selectedIndex = index;
                });
              },
              title: Text(
                widget.shippingOptions![index].name!,
              ),
              trailing: Text(
                widget.shippingOptions![index].cost!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shippingOptions![index].carrierName ?? "Unknown",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    widget.shippingOptions![index].deliveryTakes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ).pOnly(right: 10),
              leading: index == selectedIndex
                  ? Icon(Icons.check_circle, color: kPrimaryColor)
                  : Icon(
                      Icons.radio_button_unchecked,
                      color: getColorBasedOnTheme(
                          context, kDarkColor, kLightColor),
                    ),
            );
          }),
    );
  }
}

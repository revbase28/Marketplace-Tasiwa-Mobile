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
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/helper/get_amount_from_string.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/pick_image_helper.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/address/address_state.dart';
import 'package:zcart/riverpod/state/cart_state.dart';
import 'package:zcart/riverpod/state/checkout_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/product_details/product_details_screen.dart';
import 'package:zcart/views/screens/startup/loading_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/account/add_address_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/terms_and_conditions_screen.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/checkout/payments/payment_methods.dart';
import 'package:zcart/views/shared_widgets/address_list_widget.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

// class CheckoutScreen extends StatefulWidget {
//   final String? customerEmail;
//   const CheckoutScreen({
//     Key? key,
//     this.customerEmail,
//   }) : super(key: key);

//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   int _currentStep = 0;
//   final StepperType _stepperType = StepperType.vertical;

//   //Conditions
//   int? _selectedAddressIndex;
//   int? _selectedShippingOptionsIndex;
//   int? _selectedPackagingIndex;
//   int? _selectedPaymentIndex;
//   String _paymentMethodCode = "";
//   String? _prescriptionImage;

//   /// Coupon
//   bool _showApplyButton = false;
//   final TextEditingController _couponController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passWordController = TextEditingController();
//   final TextEditingController _confirmPassWordController =
//       TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   final _emailFormKey = GlobalKey<FormState>();

//   bool _createNewAccount = false;
//   bool _agreedToTerms = false;

//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return ProviderListener<CheckoutState>(
//       provider: checkoutNotifierProvider,
//       onChange: (context, state) async {
//         if (state is CheckoutLoadedState) {
//           toast(LocaleKeys.order_place_confirmation.tr());
//           if (state.accessToken != null) {
//             toast(LocaleKeys.register_successful.tr());
//             await setValue(loggedIn, true);
//             await setValue(access, state.accessToken).then((value) {
//               Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (context) => const LoadingScreen()),
//                   (Route<dynamic> route) => false);
//             });
//           } else {
//             context.pop();
//           }
//         }
//       },
//       child: ProviderListener<CartItemDetailsState>(
//         provider: cartItemDetailsNotifierProvider,
//         onChange: (context, state) {
//           if (state is CartItemDetailsLoadedState) {
//             context.read(checkoutNotifierProvider.notifier).cartId =
//                 state.cartItemDetails!.data!.id;
//           }
//         },
//         child: Scaffold(
//             appBar: AppBar(
//               systemOverlayStyle: SystemUiOverlayStyle.light,
//               title: Text(LocaleKeys.checkout.tr()),
//             ),
//             body: Consumer(builder: (context, watch, _) {
//               final cartItemDetailsState =
//                   watch(cartItemDetailsNotifierProvider);
//               final addressState = watch(addressNotifierProvider);

//               final _pharmacyPluginProvider =
//                   watch(checkPharmacyPluginProvider);

//               return Column(
//                 children: [
//                   Expanded(
//                     child: Theme(
//                       data: ThemeData(
//                         textTheme: EasyDynamicTheme.of(context).themeMode ==
//                                 ThemeMode.dark
//                             ? darkTextTheme(context)
//                             : EasyDynamicTheme.of(context).themeMode ==
//                                     ThemeMode.system
//                                 ? SchedulerBinding.instance!.window
//                                             .platformBrightness ==
//                                         Brightness.dark
//                                     ? darkTextTheme(context)
//                                     : lightTextTheme(context)
//                                 : lightTextTheme(context),
//                         colorScheme: ColorScheme.light(
//                             primary: kPrimaryColor, secondary: kAccentColor),
//                       ),
//                       child: Stepper(
//                         controlsBuilder: (context, details) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     primary: getColorBasedOnTheme(context,
//                                         kDarkCardBgColor, kLightCardBgColor),
//                                     onPrimary: kLightColor,
//                                     textStyle: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   onPressed: details.onStepCancel,
//                                   child: const Text("Back"),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     primary: kPrimaryColor,
//                                     onPrimary: kLightColor,
//                                     textStyle: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     elevation: 0,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   onPressed: details.onStepContinue,
//                                   child: const Text("Next"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         type: _stepperType,
//                         physics: const BouncingScrollPhysics(),
//                         currentStep: _currentStep,
//                         onStepTapped: (step) => tapped(step),
//                         onStepContinue: _isLoading
//                             ? null
//                             : () {
//                                 continued(cartItemDetailsState, addressState,
//                                     _pharmacyPluginProvider);
//                               },
//                         onStepCancel: cancel,
//                         steps: <Step>[
//                           /// Shipping
//                           _shipping(context, cartItemDetailsState),

//                           /// Order options
//                           _orderOptions(cartItemDetailsState),

//                           /// Place order
//                           _placeOrder(cartItemDetailsState, context),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             })),
//       ),
//     );
//   }

//   Step _placeOrder(
//       CartItemDetailsState cartItemDetailsState, BuildContext context) {
//     return Step(
//       title: Text(
//         LocaleKeys.place_order.tr(),
//         style: context.textTheme.subtitle2,
//       ),
//       content: Container(
//         color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
//         padding: const EdgeInsets.all(10),
//         child: cartItemDetailsState is CartItemDetailsLoadedState
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: cartItemDetailsState
//                           .cartItemDetails!.data!.items!.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           leading: CachedNetworkImage(
//                             imageUrl: cartItemDetailsState
//                                 .cartItemDetails!.data!.items![index].image!,
//                             errorWidget: (context, url, error) =>
//                                 const SizedBox(),
//                             progressIndicatorBuilder:
//                                 (context, url, progress) => Center(
//                               child: CircularProgressIndicator(
//                                   value: progress.progress),
//                             ),
//                             width: 40,
//                             height: 40,
//                           ),
//                           title: Text(cartItemDetailsState.cartItemDetails!
//                               .data!.items![index].description!),
//                           subtitle: Text(
//                               cartItemDetailsState.cartItemDetails!.data!
//                                   .items![index].unitPrice!,
//                               style: context.textTheme.subtitle2!.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: getColorBasedOnTheme(
//                                     context, kPriceColor, kDarkPriceColor),
//                               )),
//                           trailing: Text('x ' +
//                               cartItemDetailsState
//                                   .cartItemDetails!.data!.items![index].quantity
//                                   .toString()),
//                         );
//                       }),
//                   Text('\n${LocaleKeys.order_summary.tr()}\n',
//                       style: context.textTheme.subtitle2),
//                   Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.sub_total.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.total!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       const SizedBox(height: 9),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.discount.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.discount!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       const SizedBox(height: 9),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.packaging.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.packaging!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       const SizedBox(height: 9),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.shipping.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.shipping!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       const SizedBox(height: 9),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.handling.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.handling!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       const SizedBox(height: 9),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.taxes.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   '${cartItemDetailsState.cartItemDetails!.data!.taxes} (${cartItemDetailsState.cartItemDetails!.data!.taxrate})',
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                       Divider(
//                         endIndent: MediaQuery.of(context).size.width * 0.3,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               flex: 2,
//                               child: Text("${LocaleKeys.grand_total.tr()}: ")),
//                           Expanded(
//                               flex: 3,
//                               child: Text(
//                                   cartItemDetailsState
//                                       .cartItemDetails!.data!.grandTotal!,
//                                   style: context.textTheme.subtitle2)),
//                         ],
//                       ),
//                     ],
//                   ).pOnly(bottom: 10),
//                   const Divider(
//                     height: 16,
//                     thickness: 2,
//                   ),
//                   CustomTextField(
//                     title: LocaleKeys.apply_coupon.tr(),
//                     hintText: LocaleKeys.enter_coupon_code.tr(),
//                     controller: _couponController,
//                     onChanged: (value) {
//                       if (!_showApplyButton) {
//                         setState(() {
//                           _showApplyButton = true;
//                         });
//                       }
//                     },
//                   ),
//                   Visibility(
//                     visible: _showApplyButton,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         OutlinedButton(
//                           onPressed: () {
//                             context
//                                 .read(applyCouponProvider.notifier)
//                                 .applyCoupon(
//                                     cartItemDetailsState
//                                         .cartItemDetails!.data!.id,
//                                     _couponController.text)
//                                 .then((value) => context
//                                     .read(cartItemDetailsNotifierProvider
//                                         .notifier)
//                                     .getCartItemDetails(cartItemDetailsState
//                                         .cartItemDetails!.data!.id));
//                           },
//                           child: Text(LocaleKeys.apply.tr(),
//                               style: TextStyle(color: kPrimaryColor)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   CustomTextField(
//                       title: LocaleKeys.buyers_note.tr(),
//                       hintText: LocaleKeys.note_for_seller.tr(),
//                       maxLines: null,
//                       onChanged: (value) => context
//                           .read(checkoutNotifierProvider.notifier)
//                           .buyerNote = value).pOnly(bottom: 5),
//                   accessAllowed
//                       ? const SizedBox()
//                       : Container(
//                           margin: const EdgeInsets.only(bottom: 10),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                               color: getColorBasedOnTheme(
//                                   context, kLightBgColor, kDarkBgColor),
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   blurRadius: 10,
//                                   color: Colors.black.withOpacity(0.1),
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ]),
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Guest Checkout",
//                                         style: context.textTheme.headline6)
//                                     .pOnly(bottom: 10),
//                                 Form(
//                                   key: _emailFormKey,
//                                   child: CustomTextField(
//                                     hintText: LocaleKeys.your_email.tr(),
//                                     controller: _emailController,
//                                     keyboardType: TextInputType.emailAddress,
//                                     validator: (value) {
//                                       if (value != null) {
//                                         if (!value.contains('@') ||
//                                             !value.contains('.')) {
//                                           return LocaleKeys.invalid_email.tr();
//                                         }
//                                       }
//                                     },
//                                     onChanged: (value) {
//                                       context
//                                           .read(
//                                               checkoutNotifierProvider.notifier)
//                                           .email = value;
//                                     },
//                                   ),
//                                 ),
//                                 CheckboxListTile(
//                                   checkColor: kLightColor,
//                                   activeColor: kPrimaryColor,
//                                   value: _createNewAccount,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _createNewAccount = value!;
//                                     });
//                                     context
//                                         .read(checkoutNotifierProvider.notifier)
//                                         .createAccount = value;
//                                   },
//                                   title: Text(LocaleKeys.create_account.tr()),
//                                 ),
//                                 Visibility(
//                                   visible: _createNewAccount,
//                                   child: Form(
//                                     key: _formKey,
//                                     child: Column(
//                                       children: [
//                                         CustomTextField(
//                                           isPassword: true,
//                                           title: LocaleKeys.your_password.tr(),
//                                           hintText:
//                                               LocaleKeys.your_password.tr(),
//                                           keyboardType:
//                                               TextInputType.visiblePassword,
//                                           controller: _passWordController,
//                                           validator: (value) {
//                                             if (value != null) {
//                                               if (value.length < 6) {
//                                                 return LocaleKeys
//                                                     .password_validation
//                                                     .tr();
//                                               }
//                                             }
//                                           },
//                                           onChanged: (value) {
//                                             context
//                                                 .read(checkoutNotifierProvider
//                                                     .notifier)
//                                                 .password = value;
//                                           },
//                                         ),
//                                         CustomTextField(
//                                           isPassword: true,
//                                           title: LocaleKeys
//                                               .your_confirm_password
//                                               .tr(),
//                                           hintText: LocaleKeys
//                                               .your_confirm_password
//                                               .tr(),
//                                           keyboardType:
//                                               TextInputType.visiblePassword,
//                                           controller:
//                                               _confirmPassWordController,
//                                           validator: (value) {
//                                             if (value != null) {
//                                               if (value.length < 6) {
//                                                 return LocaleKeys
//                                                     .password_validation
//                                                     .tr();
//                                               }
//                                               {
//                                                 if (value !=
//                                                     _passWordController.text) {
//                                                   return LocaleKeys
//                                                       .dont_match_password
//                                                       .tr();
//                                                 }
//                                               }
//                                             }
//                                           },
//                                           onChanged: (value) {
//                                             context
//                                                 .read(checkoutNotifierProvider
//                                                     .notifier)
//                                                 .passwordConfirm = value;
//                                           },
//                                         ),
//                                         CheckboxListTile(
//                                           checkColor: kLightColor,
//                                           activeColor: kPrimaryColor,
//                                           value: _agreedToTerms,
//                                           onChanged: (value) {
//                                             setState(() {
//                                               _agreedToTerms = value!;
//                                             });
//                                             context
//                                                 .read(checkoutNotifierProvider
//                                                     .notifier)
//                                                 .agreeToTerms = value;
//                                           },
//                                           title: GestureDetector(
//                                             onTap: () {
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           const TermsAndConditionScreen()));
//                                             },
//                                             child: Text(
//                                                 LocaleKeys.agree_terms.tr()),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ]),
//                         ),
//                 ],
//               )
//             : const SizedBox(),
//       ).cornerRadius(10),
//       isActive: _currentStep >= 0,
//       state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
//     );
//   }

//   Step _orderOptions(CartItemDetailsState cartItemDetailsState) {
//     return Step(
//       title: Text(
//         LocaleKeys.order_options.tr(),
//         style: context.textTheme.subtitle2,
//       ),
//       content: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Row(
//             children: [
//               Text(LocaleKeys.shipping_options.tr(),
//                   style: context.textTheme.bodyText2),
//             ],
//           ).pOnly(bottom: 10),
//           Consumer(
//             builder: (context, watch, _) {
//               final shippingState = watch(shippingNotifierProvider);
//               return shippingState is ShippingLoadedState
//                   ? cartItemDetailsState is CartItemDetailsLoadedState
//                       ? shippingState.shippingOptions!.isNotEmpty
//                           ? ShippingOptionsBuilder(
//                               shippingOptions: shippingState.shippingOptions,
//                               cartItem:
//                                   cartItemDetailsState.cartItemDetails!.data,
//                               onPressedCheckBox: (value) {
//                                 setState(() {
//                                   _selectedShippingOptionsIndex = value;
//                                 });
//                               },
//                             ).cornerRadius(10)
//                           : Container(
//                               color: getColorBasedOnTheme(
//                                   context, kLightColor, kDarkCardBgColor),
//                               padding: const EdgeInsets.all(10),
//                               width: context.screenWidth,
//                               child: Column(
//                                 children: [
//                                   const Icon(Icons.info_outline)
//                                       .pOnly(bottom: 5),
//                                   Text(
//                                     LocaleKeys.no_shipping_zone.tr(),
//                                     textAlign: TextAlign.center,
//                                   ).pOnly(bottom: 5)
//                                 ],
//                               ),
//                             ).cornerRadius(10)
//                       : ShippingOptionsBuilder(
//                               onPressedCheckBox: (value) {},
//                               shippingOptions: shippingState.shippingOptions)
//                           .cornerRadius(10)
//                   : const SizedBox();
//             },
//           ),
//           Row(
//             children: [
//               Text(LocaleKeys.packaging.tr(),
//                   style: context.textTheme.bodyText2),
//             ],
//           ).pOnly(top: 10, bottom: 10),
//           Container(
//             color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: cartItemDetailsState is CartItemDetailsLoadedState
//                 ? PackagingListBuilder(
//                     cartItem: cartItemDetailsState.cartItemDetails!.data,
//                     onPressedCheckBox: (value) {
//                       setState(() {
//                         _selectedPackagingIndex = value;
//                       });
//                     },
//                   )
//                 : const PackagingListBuilder(),
//           ).cornerRadius(10),
//           Consumer(
//             builder: (context, watch, child) {
//               final _pharmacyPluginProvider =
//                   watch(checkPharmacyPluginProvider);
//               return _pharmacyPluginProvider.when(
//                 data: (value) {
//                   if (value) {
//                     return Column(
//                       children: [
//                         Row(
//                           children: [
//                             Text("Prescription",
//                                 style: context.textTheme.bodyText2),
//                           ],
//                         ).pOnly(top: 10, bottom: 10),
//                         GestureDetector(
//                           onTap: () async {
//                             await pickImageToBase64().then((value) {
//                               if (value != null) {
//                                 setState(() {
//                                   _prescriptionImage = value;
//                                 });

//                                 context
//                                     .read(checkoutNotifierProvider.notifier)
//                                     .prescription = value;
//                               }
//                             });
//                           },
//                           child: Container(
//                             color: getColorBasedOnTheme(
//                                 context, kLightColor, kDarkCardBgColor),
//                             padding: const EdgeInsets.all(10),
//                             height: 200,
//                             child: _prescriptionImage != null
//                                 ? Image.memory(
//                                     base64Decode(_prescriptionImage!),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                       const Icon(Icons.image).pOnly(bottom: 5),
//                                       const Text(
//                                         "Choose Image",
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ],
//                                   ),
//                           ).cornerRadius(10),
//                         )
//                       ],
//                     );
//                   } else {
//                     return const SizedBox();
//                   }
//                 },
//                 loading: () {
//                   return const SizedBox();
//                 },
//                 error: (error, stackTrace) {
//                   return Center(
//                       child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Text(LocaleKeys.something_went_wrong.tr()),
//                   ));
//                 },
//               );
//             },
//           ),
//           Row(
//             children: [
//               Text(LocaleKeys.payment.tr(), style: context.textTheme.bodyText2),
//             ],
//           ).pOnly(top: 10, bottom: 10),
//           PaymentOptionsListBuilder(
//             onPressedCheckBox: (value, code) {
//               setState(() {
//                 _selectedPaymentIndex = value;
//                 _paymentMethodCode = code;
//               });
//             },
//           ).cornerRadius(10)
//         ],
//       ),
//       isActive: _currentStep >= 0,
//       state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
//     );
//   }

//   Step _shipping(
//       BuildContext context, CartItemDetailsState cartItemDetailsState) {
//     return Step(
//       title: Text(
//         LocaleKeys.shipping.tr(),
//         style: context.textTheme.subtitle2,
//       ),
//       content: Column(
//         children: <Widget>[
//           Row(
//             children: [
//               Text(LocaleKeys.select_shipping_address.tr(),
//                   style: context.textTheme.subtitle1),
//             ],
//           ).pOnly(bottom: 10),
//           Container(
//             color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Icon(Icons.add_circle_outlined, color: kPrimaryColor)
//                     .pOnly(right: 10),
//                 Text(LocaleKeys.add_address.tr(),
//                     style: context.textTheme.subtitle2)
//               ],
//             ),
//           ).onInkTap(() {
//             context.read(statesNotifierProvider.notifier).resetState();
//             context.nextPage(AddNewAddressScreen(
//               isAccessed: accessAllowed,
//             ));
//           }).cornerRadius(10),
//           Consumer(
//             builder: (context, watch, _) {
//               final addressState = watch(addressNotifierProvider);

//               return addressState is AddressLoadedState
//                   ? addressState.addresses == null
//                       ? const SizedBox()
//                       : addressState.addresses!.isEmpty
//                           ? const SizedBox()
//                           : cartItemDetailsState is CartItemDetailsLoadedState
//                               ? AddressListBuilder(
//                                   addressesList: addressState.addresses,
//                                   cartItem: cartItemDetailsState
//                                       .cartItemDetails!.data,
//                                   onPressedCheckBox: (value) {
//                                     setState(() {
//                                       _selectedAddressIndex = value;
//                                     });
//                                   },
//                                 )
//                               : AddressListBuilder(
//                                   addressesList: addressState.addresses)
//                   : addressState is AddressLoadingState
//                       ? const FieldLoading().py(5)
//                       : addressState is AddressErrorState
//                           ? ListTile(
//                               title: Text(addressState.message,
//                                   style: TextStyle(color: kPrimaryColor)),
//                               leading: const Icon(Icons.dangerous),
//                               contentPadding: EdgeInsets.zero,
//                               horizontalTitleGap: 0,
//                             )
//                           : addressState is AddressInitialState
//                               ? const SizedBox()
//                               : const SizedBox();
//             },
//           )
//         ],
//       ),
//       isActive: _currentStep >= 0,
//       state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
//     );
//   }

//   tapped(int step) {
//     setState(() => _currentStep = step);
//   }

//   continued(
//     CartItemDetailsState cartItemDetailsState,
//     AddressState addressState,
//     AsyncValue<bool> pharmacyPluginProvider,
//   ) async {
//     int _grandTotal = cartItemDetailsState is CartItemDetailsLoadedState
//         ? getAmountFromString(
//             cartItemDetailsState.cartItemDetails!.data!.grandTotal!)
//         : 0;

//     bool _isPharmacyPluginEnabled = false;

//     pharmacyPluginProvider.whenData((value) {
//       _isPharmacyPluginEnabled = value;
//     });

//     if (_currentStep == 0 && _selectedAddressIndex == null) {
//       toast(
//         LocaleKeys.select_shipping_address_continue.tr(),
//       );
//     } else if (_currentStep == 1 && _selectedShippingOptionsIndex == null) {
//       toast(
//         LocaleKeys.select_shipping_option_continue.tr(),
//       );
//     } else if (_currentStep == 1 && _selectedPackagingIndex == null) {
//       toast(
//         LocaleKeys.select_packaging_method_continue.tr(),
//       );
//     } else if (_isPharmacyPluginEnabled &&
//         _currentStep == 1 &&
//         _prescriptionImage == null) {
//       toast("Please upload prescription");
//     } else if (_currentStep == 1 && _selectedPaymentIndex == null) {
//       toast(
//         LocaleKeys.select_payment_method_continue.tr(),
//       );
//     } else if (_currentStep == 2) {
//       if (!accessAllowed) {
//         if (_createNewAccount) {
//           if (_emailFormKey.currentState!.validate()) {
//             if (_agreedToTerms) {
//               if (_formKey.currentState!.validate()) {
//                 await PaymentMethods.pay(
//                   context,
//                   _paymentMethodCode,
//                   email: _emailController.text.trim(),
//                   price: _grandTotal,
//                   shippingId: _selectedAddressIndex!,
//                   addresses: addressState is AddressLoadedState
//                       ? addressState.addresses!
//                       : null,
//                   cartItemDetails:
//                       cartItemDetailsState is CartItemDetailsLoadedState
//                           ? cartItemDetailsState.cartItemDetails!.data
//                           : null,
//                   cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
//                       ? cartItemDetailsState.cartItemDetails!.meta
//                       : null,
//                 ).then((value) async {
//                   if (value) {
//                     setState(() {
//                       _isLoading = true;
//                     });
//                     await context
//                         .read(checkoutNotifierProvider.notifier)
//                         .guestCheckout();
//                     setState(() {
//                       _isLoading = false;
//                     });
//                     if (_paymentMethodCode == zcartWallet) {
//                       context.refresh(walletBalanceProvider);
//                       context.refresh(walletTransactionFutureProvider);
//                     }
//                   } else {
//                     toast("Payment Failed");
//                   }
//                 });
//               }
//             } else {
//               toast(LocaleKeys.please_agree_terms.tr());
//             }
//           }
//         } else {
//           if (_emailFormKey.currentState!.validate()) {
//             await PaymentMethods.pay(
//               context,
//               _paymentMethodCode,
//               email: _emailController.text.trim(),
//               price: _grandTotal,
//               shippingId: _selectedShippingOptionsIndex!,
//               addresses: addressState is AddressLoadedState
//                   ? addressState.addresses!
//                   : null,
//               cartItemDetails:
//                   cartItemDetailsState is CartItemDetailsLoadedState
//                       ? cartItemDetailsState.cartItemDetails!.data
//                       : null,
//               cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
//                   ? cartItemDetailsState.cartItemDetails!.meta
//                   : null,
//             ).then((value) async {
//               if (value) {
//                 setState(() {
//                   _isLoading = true;
//                 });
//                 await context
//                     .read(checkoutNotifierProvider.notifier)
//                     .guestCheckout();
//                 setState(() {
//                   _isLoading = false;
//                 });
//                 if (_paymentMethodCode == zcartWallet) {
//                   context.refresh(walletBalanceProvider);
//                   context.refresh(walletTransactionFutureProvider);
//                 }
//               } else {
//                 toast("Payment Failed");
//               }
//             });
//           }
//         }
//       } else {
//         await PaymentMethods.pay(
//           context,
//           _paymentMethodCode,
//           shippingId: _selectedAddressIndex!,
//           email: widget.customerEmail!,
//           price: _grandTotal,
//           addresses: addressState is AddressLoadedState
//               ? addressState.addresses!
//               : null,
//           cartItemDetails: cartItemDetailsState is CartItemDetailsLoadedState
//               ? cartItemDetailsState.cartItemDetails!.data
//               : null,
//           cartMeta: cartItemDetailsState is CartItemDetailsLoadedState
//               ? cartItemDetailsState.cartItemDetails!.meta
//               : null,
//         ).then((value) async {
//           if (value) {
//             setState(() {
//               _isLoading = true;
//             });
//             await context.read(checkoutNotifierProvider.notifier).checkout();
//             setState(() {
//               _isLoading = false;
//             });
//             if (_paymentMethodCode == zcartWallet) {
//               context.refresh(walletBalanceProvider);
//               context.refresh(walletTransactionFutureProvider);
//             }
//           } else {
//             toast("Payment Failed");
//           }
//         });
//       }
//     } else if (_currentStep < 2) {
//       setState(() => _currentStep += 1);
//     }
//   }

//   cancel() {
//     if (_currentStep > 0) setState(() => _currentStep -= 1);
//   }
// }

// class PaymentOptionsListBuilder extends StatefulWidget {
//   final Function(int index, String code)? onPressedCheckBox;
//   const PaymentOptionsListBuilder({
//     Key? key,
//     this.onPressedCheckBox,
//   }) : super(key: key);
//   @override
//   _PaymentOptionsListBuilderState createState() =>
//       _PaymentOptionsListBuilderState();
// }

// class _PaymentOptionsListBuilderState extends State<PaymentOptionsListBuilder> {
//   int? selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Consumer(
//         builder: (context, watch, _) {
//           final paymentOptionsState = watch(paymentOptionsNotifierProvider);
//           if (paymentOptionsState is PaymentOptionsLoadedState) {
//             List<PaymentOptions>? _paymentOptions =
//                 paymentOptionsState.paymentOptions;

//             List<PaymentOptions>? _implementedPaymentOptions =
//                 _paymentOptions?.where((element) {
//               if (paymentMethods.contains(element.code)) {
//                 if (element.code! == zcartWallet) {
//                   if (accessAllowed) {
//                     return true;
//                   } else {
//                     return false;
//                   }
//                 } else {
//                   return true;
//                 }
//               } else {
//                 return false;
//               }
//             }).toList();

//             _implementedPaymentOptions!
//                 .sort((a, b) => a.order!.compareTo(b.order!));

//             return ListView(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: _implementedPaymentOptions.map((e) {
//                   int _index = _implementedPaymentOptions.indexOf(e);
//                   return ListTile(
//                     onTap: () async {
//                       widget.onPressedCheckBox!(_index, e.code!);

//                       context
//                           .read(checkoutNotifierProvider.notifier)
//                           .paymentMethod = e.code;

//                       setState(() {
//                         selectedIndex = _index;
//                       });
//                     },
//                     title: Text(e.name!),
//                     trailing: _index == selectedIndex
//                         ? Icon(Icons.check_circle, color: kPrimaryColor)
//                         : Icon(
//                             Icons.radio_button_unchecked,
//                             color: getColorBasedOnTheme(
//                                 context, kDarkColor, kLightColor),
//                           ),
//                   );
//                 }).toList());
//           } else {
//             return const SizedBox();
//           }
//         },
//       ),
//     );
//   }
// }

// class PackagingListBuilder extends StatefulWidget {
//   final CartItemDetails? cartItem;
//   final Function(int)? onPressedCheckBox;

//   const PackagingListBuilder({Key? key, this.cartItem, this.onPressedCheckBox})
//       : super(key: key);

//   @override
//   _PackagingListBuilderState createState() => _PackagingListBuilderState();
// }

// class _PackagingListBuilderState extends State<PackagingListBuilder> {
//   int? selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, watch, _) {
//         final packagingState = watch(packagingNotifierProvider);
//         return packagingState is PackagingLoadedState
//             ? ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: packagingState.packagingList.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     onTap: () {
//                       widget.onPressedCheckBox!(index);
//                       context
//                           .read(cartItemDetailsNotifierProvider.notifier)
//                           .updateCart(widget.cartItem!.id,
//                               packagingId:
//                                   packagingState.packagingList[index].id);
//                       context
//                           .read(checkoutNotifierProvider.notifier)
//                           .packagingId = packagingState.packagingList[index].id;
//                       setState(() {
//                         selectedIndex = index;
//                       });
//                     },
//                     title: Text(packagingState.packagingList[index].cost!
//                         .substring(
//                             0,
//                             (packagingState.packagingList[index].cost!
//                                     .indexOf('.') +
//                                 3))),
//                     subtitle: Text(packagingState.packagingList[index].name!),
//                     trailing: index == selectedIndex
//                         ? Icon(Icons.check_circle, color: kPrimaryColor)
//                         : Icon(
//                             Icons.radio_button_unchecked,
//                             color: getColorBasedOnTheme(
//                                 context, kDarkColor, kLightColor),
//                           ),
//                   );
//                 })
//             : const SizedBox();
//       },
//     );
//   }
// }

// class ShippingOptionsBuilder extends StatefulWidget {
//   const ShippingOptionsBuilder({
//     Key? key,
//     required this.shippingOptions,
//     this.cartItem,
//     required this.onPressedCheckBox,
//   }) : super(key: key);

//   final List<ShippingOptions>? shippingOptions;
//   final CartItemDetails? cartItem;
//   final Function(int) onPressedCheckBox;

//   @override
//   _ShippingOptionsBuilderState createState() => _ShippingOptionsBuilderState();
// }

// class _ShippingOptionsBuilderState extends State<ShippingOptionsBuilder> {
//   int? selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: widget.shippingOptions!.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               onTap: () {
//                 widget.onPressedCheckBox(index);
//                 context
//                     .read(cartItemDetailsNotifierProvider.notifier)
//                     .updateCart(
//                       widget.cartItem!.id,
//                       shippingZoneId:
//                           widget.shippingOptions![index].shippingZoneId,
//                       shippingOptionId: widget.shippingOptions![index].id,
//                     );
//                 context
//                     .read(checkoutNotifierProvider.notifier)
//                     .shippingOptionId = widget.shippingOptions![index].id;

//                 setState(() {
//                   selectedIndex = index;
//                 });
//               },
//               title: Text(
//                 widget.shippingOptions![index].name!,
//               ),
//               trailing: Text(
//                 widget.shippingOptions![index].cost!,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.shippingOptions![index].carrierName ?? "Unknown",
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                   Text(
//                     widget.shippingOptions![index].deliveryTakes!,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: Theme.of(context).textTheme.caption,
//                   ),
//                 ],
//               ).pOnly(right: 10),
//               leading: index == selectedIndex
//                   ? Icon(Icons.check_circle, color: kPrimaryColor)
//                   : Icon(
//                       Icons.radio_button_unchecked,
//                       color: getColorBasedOnTheme(
//                           context, kDarkColor, kLightColor),
//                     ),
//             );
//           }),
//     );
//   }
// }

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

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PageController _pageController;
  bool _showShippingOptions = true;
  bool _isLastPage = false;
  Addresses? _selectedAddress;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
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
              context
                  .nextAndRemoveUntilPage(const BottomNavBar(selectedIndex: 4));
            }
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
            }
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.checkout.tr()),
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              body: Consumer(builder: (context, watch, child) {
                final _cartDetailsProvider =
                    watch(cartItemDetailsNotifierProvider);
                return _cartDetailsProvider is CartItemDetailsLoadedState
                    ? Column(
                        children: [
                          // const SizedBox(height: 18),
                          // Container(
                          //   height: 8,
                          //   decoration: BoxDecoration(
                          //     color: getColorBasedOnTheme(
                          //         context, kPriceColor, kDarkPriceColor),
                          //   ),
                          // ),
                          // const SizedBox(height: 10),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (value) {
                                setState(() {
                                  _showShippingOptions = value == 0;
                                });
                                if (value == 2) {
                                  setState(() {
                                    _isLastPage = true;
                                  });
                                } else {
                                  setState(() {
                                    _isLastPage = false;
                                  });
                                }
                              },
                              children: [
                                CheckoutAddressScreen(
                                  selectedAddress: _selectedAddress,
                                  isOneCheckout: widget.isOneCheckout,
                                  onSelectedAddress: (address) {
                                    setState(() {
                                      _selectedAddress = address;
                                    });
                                  },
                                ),
                                CheckOutItemDetailsPage(
                                    isOneCheckout: widget.isOneCheckout),
                                CheckoutPaymentPage(
                                  customerEmail: widget.customerEmail,
                                  cartItemDetails:
                                      _cartDetailsProvider.cartItemDetails,
                                  address: _selectedAddress,
                                ),
                              ],
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                          ),
                          if (_showShippingOptions)
                            ShippingDetails(
                              cartItem:
                                  _cartDetailsProvider.cartItemDetails!.data!,
                              onPressedNext: () {
                                if (_selectedAddress != null) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                } else {
                                  toast(LocaleKeys
                                      .select_shipping_address_continue
                                      .tr());
                                }
                              },
                            ),
                          if (!_showShippingOptions)
                            if (!_isLastPage)
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
                                        onPressed: () {
                                          _pageController.previousPage(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut);
                                        },
                                        child: const Text("Back"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16)),
                                        onPressed: () {
                                          _pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut);
                                        },
                                        child: const Text("Next"),
                                      ),
                                    ),
                                  ],
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
    );
  }
}

class CheckoutAddressScreen extends StatelessWidget {
  final bool isOneCheckout;
  final Function(Addresses) onSelectedAddress;
  final Addresses? selectedAddress;
  const CheckoutAddressScreen({
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
        final _guestAddresProvider = watch(guestAddressesProvider);
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
                          final Addresses? _address = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewAddressScreen(
                                    isAccessed: accessAllowed)),
                          );

                          if (_address != null) {
                            context
                                .read(guestAddressesProvider.notifier)
                                .addAddress(_address);
                          }
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
                      child: accessAllowed
                          ? _userAddressProvider!.when(
                              data: (value) {
                                if (value == null || value.isEmpty) {
                                  return const SizedBox();
                                } else {
                                  return AddressListBuilder(
                                    addressesList: value,
                                    cartItem: _cartDetailsProvider
                                        .cartItemDetails?.data,
                                    onAddressSelected: (index) {
                                      onSelectedAddress(value[index]);
                                    },
                                    selectedAddressIndex:
                                        selectedAddress != null
                                            ? value.indexOf(selectedAddress!)
                                            : null,
                                  );
                                }
                              },
                              loading: () =>
                                  const Center(child: LoadingWidget()),
                              error: (error, stackTrace) => const SizedBox(),
                            )
                          : AddressListBuilder(
                              addressesList: _guestAddresProvider.addresses,
                              cartItem:
                                  _cartDetailsProvider.cartItemDetails?.data,
                              onAddressSelected: (index) {
                                onSelectedAddress(
                                    _guestAddresProvider.addresses[index]);
                              },
                              selectedAddressIndex: selectedAddress != null
                                  ? _guestAddresProvider.addresses
                                      .indexOf(selectedAddress!)
                                  : null,
                            ),
                    ),
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

class ShippingDetails extends ConsumerWidget {
  final cart_item_details_model.CartItemDetails cartItem;
  final VoidCallback onPressedNext;

  const ShippingDetails({
    Key? key,
    required this.cartItem,
    required this.onPressedNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    var params = {
      'ship_to_acountry_id': cartItem.countryId,
      'ship_to_state_id': cartItem.stateId,
    };

    String _url = API.shippingOptionsForCart(cartItem.id!) +
        "?" +
        params.entries.map((e) => e.key + "=" + e.value.toString()).join("&");
    final _shippingOptions = watch(cartShippingOptionsFutureProvider(_url));

    return _shippingOptions.when(
      data: (value) {
        if (value == null || value.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title: Text(
                LocaleKeys.shipping.tr() + ':',
                style: context.textTheme.caption!.copyWith(
                    fontWeight: FontWeight.bold, color: kPrimaryFadeTextColor),
              ),
              subtitle: Text(
                "This seller does not deliver to your selected Country/Region. Change the shipping address or find other sellers who ship to your area.",
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
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return SizedBox(
                          height: context.screenHeight * 0.7,
                          child: ProductPageDefaultContainer(
                            isFullPadding: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Select Shipping",
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
                                          (e) => RadioListTile<int?>(
                                              value: e.id,
                                              groupValue: _shippingOption?.id,
                                              title: Text(
                                                (e.name ?? "Unknown") +
                                                    " by " +
                                                    (e.carrierName ??
                                                        "Unknown"),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                e.deliveryTakes ?? "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!,
                                              ),
                                              secondary: Text(
                                                e.cost ?? "0",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(
                                                      color:
                                                          getColorBasedOnTheme(
                                                              context,
                                                              kPriceColor,
                                                              kDarkPriceColor),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              onChanged: (value) async {
                                                Navigator.of(context).pop();
                                                context
                                                    .read(cartNotifierProvider
                                                        .notifier)
                                                    .updateCart(
                                                      cartItem.id!,
                                                      shippingOptionId: e.id,
                                                      shippingZoneId:
                                                          e.shippingZoneId,
                                                    );
                                                context
                                                    .read(
                                                        cartItemDetailsNotifierProvider
                                                            .notifier)
                                                    .updateCart(
                                                      cartItem.id!,
                                                      shippingOptionId: e.id,
                                                      shippingZoneId:
                                                          e.shippingZoneId,
                                                    );
                                              }),
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
                  },
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  title: Text(
                    LocaleKeys.shipping.tr() + ':',
                    style: context.textTheme.caption!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryFadeTextColor),
                  ),
                  trailing: Text(
                    double.parse(_shippingOption.costRaw ?? "0") <= 0.0
                        ? ""
                        : (_shippingOption.cost ?? "0"),
                    style: context.textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: getColorBasedOnTheme(
                            context, kPriceColor, kDarkPriceColor)),
                  ),
                  subtitle: Text(
                    (_shippingOption.name ?? 'Unknown') +
                        " by " +
                        (_shippingOption.carrierName ?? 'Unknown'),
                    style: context.textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: onPressedNext,
                  child: const Text("Next"),
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
}

class CheckOutItemDetailsPage extends ConsumerWidget {
  final bool isOneCheckout;
  const CheckOutItemDetailsPage({
    Key? key,
    required this.isOneCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _cartDetailsProvider = watch(cartItemDetailsNotifierProvider);
    // final _allCartsProvider = watch(cartNotifierProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: isOneCheckout
          ? const Center(child: Text("One Checkout is not available yet"))
          : _cartDetailsProvider is CartItemDetailsLoadedState
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      CheckOutPageShopCard(
                        image: _cartDetailsProvider
                            .cartItemDetails!.data!.shop!.image,
                        title: _cartDetailsProvider
                                .cartItemDetails!.data!.shop!.name ??
                            "Unknown",
                        verifiedText: _cartDetailsProvider
                                .cartItemDetails!.data!.shop!.verifiedText ??
                            "",
                      ),

                      ApplyCouponSection(
                          cartId:
                              _cartDetailsProvider.cartItemDetails!.data!.id!),
                      const SizedBox(height: 8),

                      CheckoutDetailsSingleCartItemCard(
                          cartItems: _cartDetailsProvider
                              .cartItemDetails!.data!.items!),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.sub_total.tr(),
                          price: _cartDetailsProvider
                                  .cartItemDetails!.data!.total ??
                              "0"),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.shipping.tr(),
                          price: _cartDetailsProvider
                                  .cartItemDetails!.data!.shipping ??
                              "0"),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.packaging.tr(),
                          price: _cartDetailsProvider
                                  .cartItemDetails!.data!.packaging ??
                              "0"),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.handling.tr(),
                          price: _cartDetailsProvider
                                  .cartItemDetails!.data!.handling ??
                              "0"),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.taxes.tr(),
                          price: _cartDetailsProvider
                                  .cartItemDetails!.data!.taxes ??
                              "0"),
                      CheckOutDetailsPriceWidget(
                          title: LocaleKeys.discount.tr(),
                          price: "- " +
                              (_cartDetailsProvider
                                      .cartItemDetails!.data!.discount ??
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

class CheckOutPageShopCard extends StatelessWidget {
  final String? image;
  final String title;
  final String verifiedText;
  const CheckOutPageShopCard({
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
            Icon(Icons.check_circle, color: kPrimaryColor, size: 15)
                .px2()
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
  const CheckOutDetailsPriceWidget({
    Key? key,
    required this.title,
    required this.price,
    this.isGrandTotal = false,
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
            : context.textTheme.subtitle2!
                .copyWith(fontWeight: FontWeight.bold),
      ),
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
  final List<cart_item_details_model.Item> cartItems;
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(cartItem.description!,
                                      maxLines: 3,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.subtitle2!
                                          .copyWith())
                                  .pOnly(right: 10),
                            ),
                            Text(
                              " x " + cartItem.quantity!.toString(),
                              style: context.textTheme.headline6!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cartItem.total!,
                          style: context.textTheme.bodyText2!.copyWith(
                              color: getColorBasedOnTheme(
                                  context, kPriceColor, kDarkPriceColor),
                              fontWeight: FontWeight.bold),
                        ).pOnly(right: 5),
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
  const CheckoutPaymentPage({
    Key? key,
    this.customerEmail,
    this.cartItemDetails,
    required this.address,
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
    int _grandTotal =
        getAmountFromString(widget.cartItemDetails?.data?.grandTotal ?? "0");

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Consumer(
        builder: (context, watch, _) {
          final _paymentOptionsState = watch(paymentOptionsNotifierProvider);
          final _pharmacyCheckProvider = watch(checkPharmacyPluginProvider);

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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: getColorBasedOnTheme(
                                context, kLightColor, kDarkCardBgColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  LocaleKeys.payment_method.tr(),
                                  style: context.textTheme.headline6!.copyWith(
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _implementedPaymentOptions.map((e) {
                                    String _code = e.code!;
                                    return ListTile(
                                      contentPadding: const EdgeInsets.all(0),
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
                                        style: context.textTheme.subtitle2!
                                            .copyWith(
                                          fontWeight:
                                              _code == _selectedPaymentMethod
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: _code == _selectedPaymentMethod
                                          ? Icon(Icons.check_circle,
                                              color: kPrimaryColor)
                                          : Icon(
                                              Icons.radio_button_unchecked,
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
                                      Text("Prescription",
                                          style: context.textTheme.bodyText2),
                                    ],
                                  ).pOnly(top: 10, bottom: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      await pickImageToBase64().then((value) {
                                        if (value != null) {
                                          setState(() {
                                            _prescriptionImage = value;
                                          });

                                          context
                                              .read(checkoutNotifierProvider
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
                                              base64Decode(_prescriptionImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const Icon(Icons.image)
                                                    .pOnly(bottom: 5),
                                                const Text(
                                                  "Choose Image",
                                                  textAlign: TextAlign.center,
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
                              child: Text(LocaleKeys.something_went_wrong.tr()),
                            ));
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: getColorBasedOnTheme(
                                context, kLightColor, kDarkCardBgColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                LocaleKeys.note_for_seller.tr(),
                                style: context.textTheme.headline6!.copyWith(
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
                                      .read(checkoutNotifierProvider.notifier)
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: getColorBasedOnTheme(
                                        context, kLightColor, kDarkCardBgColor),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0, 10),
                                      ),
                                    ]),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Guest Checkout",
                                              style:
                                                  context.textTheme.headline6)
                                          .pOnly(bottom: 10),
                                      Form(
                                        key: _emailFormKey,
                                        child: CustomTextField(
                                          hintText: LocaleKeys.your_email.tr(),
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value != null) {
                                              if (!value.contains('@') ||
                                                  !value.contains('.')) {
                                                return LocaleKeys.invalid_email
                                                    .tr();
                                              }
                                            }
                                          },
                                          onChanged: (value) {
                                            context
                                                .read(checkoutNotifierProvider
                                                    .notifier)
                                                .email = value;
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            LocaleKeys.create_account.tr()),
                                        minLeadingWidth: 0,
                                        onTap: () {
                                          setState(() {
                                            _createNewAccount =
                                                !_createNewAccount;
                                          });
                                          context
                                                  .read(checkoutNotifierProvider
                                                      .notifier)
                                                  .createAccount =
                                              _createNewAccount;
                                        },
                                        leading: Icon(_createNewAccount
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked),
                                      ),
                                      Visibility(
                                        visible: _createNewAccount,
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                isPassword: true,
                                                title: LocaleKeys.your_password
                                                    .tr(),
                                                hintText: LocaleKeys
                                                    .your_password
                                                    .tr(),
                                                keyboardType: TextInputType
                                                    .visiblePassword,
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
                                                keyboardType: TextInputType
                                                    .visiblePassword,
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
                                                          _passWordController
                                                              .text) {
                                                        return LocaleKeys
                                                            .dont_match_password
                                                            .tr();
                                                      }
                                                    }
                                                  }
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
                                                          .read(
                                                              checkoutNotifierProvider
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
                                                            builder: (context) =>
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_selectedPaymentMethod.isEmpty) {
                              toast(LocaleKeys.select_payment_method_continue
                                  .tr());
                            } else {
                              if (!accessAllowed) {
                                if (_createNewAccount) {
                                  if (_emailFormKey.currentState!.validate()) {
                                    if (_agreedToTerms) {
                                      if (_formKey.currentState!.validate()) {
                                        await PaymentMethods.pay(
                                          context,
                                          _selectedPaymentMethod,
                                          email: _emailController.text.trim(),
                                          price: _grandTotal,
                                          shippingId: widget.cartItemDetails!
                                              .data!.shippingOptionId,
                                          address: widget.address,
                                          cartItemDetails:
                                              widget.cartItemDetails?.data,
                                          cartMeta:
                                              widget.cartItemDetails?.meta,
                                        ).then((value) async {
                                          if (value) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            await context
                                                .read(checkoutNotifierProvider
                                                    .notifier)
                                                .guestCheckout();
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
                                      _selectedPaymentMethod,
                                      email: _emailController.text.trim(),
                                      price: _grandTotal,
                                      shippingId: widget.cartItemDetails!.data!
                                          .shippingOptionId,
                                      address: widget.address,
                                      cartItemDetails:
                                          widget.cartItemDetails?.data,
                                      cartMeta: widget.cartItemDetails?.meta,
                                    ).then((value) async {
                                      if (value) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await context
                                            .read(checkoutNotifierProvider
                                                .notifier)
                                            .guestCheckout();
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if (_selectedPaymentMethod ==
                                            zcartWallet) {
                                          context
                                              .refresh(walletBalanceProvider);
                                          context.refresh(
                                              walletTransactionFutureProvider);
                                        }
                                      } else {
                                        toast("Payment Failed");
                                      }
                                    });
                                  }
                                }
                              } else {
                                await PaymentMethods.pay(
                                  context,
                                  _selectedPaymentMethod,
                                  email: widget.customerEmail!,
                                  price: _grandTotal,
                                  shippingId: widget
                                      .cartItemDetails!.data!.shippingOptionId,
                                  address: widget.address,
                                  cartItemDetails: widget.cartItemDetails?.data,
                                  cartMeta: widget.cartItemDetails?.meta,
                                ).then((value) async {
                                  if (value) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await context
                                        .read(checkoutNotifierProvider.notifier)
                                        .checkout();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (_selectedPaymentMethod == zcartWallet) {
                                      context.refresh(walletBalanceProvider);
                                      context.refresh(
                                          walletTransactionFutureProvider);
                                    }
                                  } else {
                                    toast("Payment Failed");
                                  }
                                });
                              }
                            }
                          },
                    child: const Text("Proceed to Checkout"),
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

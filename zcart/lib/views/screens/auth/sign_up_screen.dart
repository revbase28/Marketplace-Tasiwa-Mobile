import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/user_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/terms_and_conditions_screen.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  final Widget? nextScreen;
  final int nextScreenIndex;
  const SignUpScreen({
    Key? key,
    this.nextScreen,
    this.nextScreenIndex = 5,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return ProviderListener<UserState>(
        provider: userNotifierProvider,
        onChange: (context, state) {
          if (state is UserLoadedState) {
            context.read(cartNotifierProvider.notifier).getCartList();
            context.read(wishListNotifierProvider.notifier).getWishList();
            context.refresh(walletBalanceProvider);
            context.refresh(walletTransactionFutureProvider);
            context.refresh(getAddressFutureProvider);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        BottomNavBar(selectedIndex: widget.nextScreenIndex)),
                (route) => false);

            if (widget.nextScreen != null) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => widget.nextScreen!));
            }
          }
          if (state is UserErrorState) {
            toast(state.message);
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: Text(LocaleKeys.sign_up.tr()),
            ),
            body: Consumer(
              builder: (context, watch, child) {
                final authState = watch(userNotifierProvider);
                if (authState is UserLoadingState) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Hero(
                            tag: 'logo',
                            child: Image.asset(
                              AppImages.logo,
                              height: 160,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              LocaleKeys.sign_up
                                  .tr()
                                  .split(" ")
                                  .map((e) => e.capitalizeFirstLetter())
                                  .join(" "),
                              textAlign: TextAlign.start,
                              style: context.textTheme.headline5!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _nameController,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              focusColor: kPrimaryColor,
                              labelText: LocaleKeys.your_full_name.tr(),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                              prefixIcon:
                                  const Icon(Icons.person, color: kFadeColor),
                            ),
                            validator: (value) => value!.isEmpty
                                ? LocaleKeys.field_required.tr()
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              focusColor: kPrimaryColor,
                              labelText: LocaleKeys.your_email.tr(),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                              prefixIcon: const Icon(Icons.alternate_email,
                                  color: kFadeColor),
                            ),
                            validator: (value) => value!.isEmpty
                                ? LocaleKeys.field_required.tr()
                                : !value.contains('@') || !value.contains('.')
                                    ? LocaleKeys.invalid_email.tr()
                                    : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            keyboardType: TextInputType.visiblePassword,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              focusColor: kPrimaryColor,
                              labelText: LocaleKeys.your_password.tr(),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                              prefixIcon: const Icon(
                                Icons.security,
                                color: kFadeColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: kFadeColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? LocaleKeys.field_required.tr()
                                  : value.length < 6
                                      ? LocaleKeys.password_validation.tr()
                                      : null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureText,
                            keyboardType: TextInputType.visiblePassword,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              focusColor: kPrimaryColor,
                              labelText: LocaleKeys.your_confirm_password.tr(),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                              prefixIcon: const Icon(
                                Icons.security,
                                color: kFadeColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: kFadeColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? LocaleKeys.field_required.tr()
                                  : value != _passwordController.text
                                      ? LocaleKeys.dont_match_password.tr()
                                      : null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.accept_terms_policy.tr(),
                          )
                              .text
                              .center
                              .textStyle(context.textTheme.caption!)
                              .make()
                              .w(context.screenWidth * 0.8)
                              .onInkTap(() => context.nextReplacementPage(
                                  const TermsAndConditionScreen())),
                          const SizedBox(height: 16),
                          CustomButton(
                            buttonText: LocaleKeys.sign_up.tr(),
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                hideKeyboard(context);
                                context
                                    .read(userNotifierProvider.notifier)
                                    .register(
                                        _nameController.text.trim(),
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                        true,
                                        false);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            // body: Stack(
            //   children: [
            //     Center(
            //       child: SingleChildScrollView(
            //         child: Center(
            //           child: Form(
            //             key: _formKey,
            //             child: Container(
            //               margin: const EdgeInsets.all(16),
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 16, vertical: 24),
            //               decoration: BoxDecoration(
            //                   color: getColorBasedOnTheme(
            //                       context, kLightCardBgColor, kDarkCardBgColor),
            //                   borderRadius:
            //                       const BorderRadius.all(Radius.circular(10))),
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: [
            //                   Text(LocaleKeys.sign_up.tr(),
            //                           textAlign: TextAlign.center,
            //                           style: context.textTheme.headline5!
            //                               .copyWith(
            //                                   fontWeight: FontWeight.bold))
            //                       .paddingBottom(20),
            //                   CustomTextField(
            //                     hintText: LocaleKeys.your_full_name.tr(),
            //                     title: LocaleKeys.your_full_name.tr(),
            //                     onChanged: (value) => _name = value,
            //                     validator: (value) => value!.isEmpty
            //                         ? LocaleKeys.field_required.tr()
            //                         : null,
            //                   ),
            //                   CustomTextField(
            //                     hintText: LocaleKeys.your_email.tr(),
            //                     title: LocaleKeys.your_email.tr(),
            //                     keyboardType: TextInputType.emailAddress,
            //                     onChanged: (value) => _email = value,
            //                     validator: (value) => value!.isEmpty
            //                         ? LocaleKeys.field_required.tr()
            //                         : !value.contains('@') ||
            //                                 !value.contains('.')
            //                             ? LocaleKeys.invalid_email.tr()
            //                             : null,
            //                   ),
            //                   CustomTextField(
            //                     isPassword: true,
            //                     hintText: LocaleKeys.your_password.tr(),
            //                     title: LocaleKeys.your_password.tr(),
            //                     keyboardType: TextInputType.visiblePassword,
            //                     onChanged: (value) => _password = value,
            //                     validator: (value) => value!.length < 6
            //                         ? LocaleKeys.password_validation.tr()
            //                         : null,
            //                   ),
            //                   CustomTextField(
            //                     isPassword: true,
            //                     hintText: LocaleKeys.your_confirm_password.tr(),
            //                     keyboardType: TextInputType.visiblePassword,
            //                     title: LocaleKeys.your_confirm_password.tr(),
            //                     validator: (value) => value != _password
            //                         ? LocaleKeys.dont_match_password.tr()
            //                         : null,
            //                   ),
            //                   CustomButton(
            //                     buttonText: LocaleKeys.sign_up.tr(),
            //                     onTap: () async {
            //                       if (_formKey.currentState!.validate()) {
            //                         hideKeyboard(context);
            //                         context
            //                             .read(userNotifierProvider.notifier)
            //                             .register(_name.trim(), _email.trim(),
            //                                 _password, true, false);
            //                       }
            //                     },
            //                   ).pOnly(top: 10),
            //                   Text(
            //                     LocaleKeys.accept_terms_policy.tr(),
            //                   )
            //                       .text
            //                       .center
            //                       .textStyle(context.textTheme.caption!)
            //                       .make()
            //                       .w(context.screenWidth * 0.8)
            //                       .onInkTap(() => context.nextReplacementPage(
            //                           const TermsAndConditionScreen()))
            //                       .pOnly(bottom: 10),
            //                   const Divider(
            //                     height: 20,
            //                   ),
            //                   Text(
            //                     LocaleKeys.have_account.tr(),
            //                   )
            //                       .text
            //                       .center
            //                       .textStyle(context.textTheme.caption!)
            //                       .make()
            //                       .w(context.screenWidth * 0.8)
            //                       .onInkTap(() => context.pop()),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //     Consumer(
            //       builder: (context, watch, _) {
            //         final authState = watch(userNotifierProvider);
            //         return Visibility(
            //           visible: authState is UserLoadingState,
            //           child: Container(
            //             color: getColorBasedOnTheme(
            //                 context, kLightColor, kDarkCardBgColor),
            //             child: const LoadingWidget(),
            //           ),
            //         );
            //       },
            //     )
            //   ],
            // ),
          ),
        ));
  }
}

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/user_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/reset_password.dart';
import 'package:zcart/views/screens/auth/sign_up_screen.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final bool needBackButton;

  const LoginScreen({
    Key? key,
    required this.needBackButton,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderListener<UserState>(
      provider: userNotifierProvider,
      onChange: (context, state) {
        if (state is UserLoadedState) {
          context.read(ordersProvider.notifier).orders();
          context.read(wishListNotifierProvider.notifier).getWishList();
          context.read(disputesProvider.notifier).getDisputes();
          context.read(couponsProvider.notifier).coupons();

          context.nextAndRemoveUntilPage(const BottomNavBar(selectedIndex: 0));
        }
        if (state is UserErrorState) {
          toast(state.message, bgColor: kPrimaryColor);
        }
      },
      child: Scaffold(
        appBar: widget.needBackButton
            ? AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.light,
              )
            : null,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: getColorBasedOnTheme(
                                context, kLightCardBgColor, kDarkCardBgColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(LocaleKeys.sign_in.tr(),
                                      style: context.textTheme.headline5),
                                ],
                              ),
                            ).paddingBottom(20),
                            CustomTextField(
                              hintText: LocaleKeys.your_email.tr(),
                              title: LocaleKeys.your_email.tr(),
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              validator: (value) => value!.isEmpty
                                  ? LocaleKeys.field_required.tr()
                                  : !value.contains('@') || !value.contains('.')
                                      ? LocaleKeys.invalid_email.tr()
                                      : null,
                            ),
                            CustomTextField(
                              isPassword: true,
                              hintText: LocaleKeys.your_password.tr(),
                              title: LocaleKeys.your_password.tr(),
                              keyboardType: TextInputType.visiblePassword,
                              controller: _passwordController,
                              validator: (value) => value!.length < 6
                                  ? LocaleKeys.password_validation.tr()
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                LocaleKeys.forgot_password.tr(),
                                style: context.textTheme.subtitle2!.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ).onInkTap(() {
                                context.nextPage(const ResetPassword());
                              }).py(5),
                            ),
                            CustomButton(
                                buttonText: LocaleKeys.sign_in.tr(),
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    context
                                        .read(userNotifierProvider.notifier)
                                        .login(_emailController.text.trim(),
                                            _passwordController.text.trim());
                                  }
                                }).pOnly(top: 10),
                            if (!(!MyConfig.isGoogleLoginActive &&
                                !MyConfig.isFacebookLoginActive &&
                                !MyConfig.isAppleLoginActive))
                              //TODO: Add social login
                              const Text("Or Continue With")
                                  .text
                                  .textStyle(context.textTheme.caption!)
                                  .align(TextAlign.center)
                                  .make()
                                  .py(12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (MyConfig.isGoogleLoginActive)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final GoogleSignInAccount? _googleUser =
                                            await GoogleSignIn().signIn();

                                        if (_googleUser != null) {
                                          final GoogleSignInAuthentication
                                              _googleAuth =
                                              await _googleUser.authentication;
                                          context
                                              .read(
                                                  userNotifierProvider.notifier)
                                              .loginUsingGoogle(
                                                  _googleAuth.accessToken!);
                                        } else {
                                          toast(LocaleKeys.something_went_wrong
                                              .tr());
                                        }
                                      },
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xffCE3927))),
                                      icon: const Icon(
                                        FontAwesomeIcons.google,
                                        size: 18,
                                      ),
                                      label: const Text("Google"),
                                    ).px(5),
                                  ),
                                if (MyConfig.isFacebookLoginActive)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final LoginResult result =
                                            await FacebookAuth.instance.login();
                                        if (result.status ==
                                            LoginStatus.success) {
                                          // you are logged
                                          final AccessToken accessToken =
                                              result.accessToken!;

                                          context
                                              .read(
                                                  userNotifierProvider.notifier)
                                              .loginUsingFacebook(
                                                  accessToken.token);
                                        } else {
                                          toast(LocaleKeys.something_went_wrong
                                              .tr());
                                        }
                                      },
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                          ),
                                          shape: MaterialStateProperty.all(
                                              const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xff3b5998))),
                                      icon: const Icon(
                                        FontAwesomeIcons.facebook,
                                        size: 18,
                                      ),
                                      label: const Text("Facebook"),
                                    ).px(5),
                                  ),
                              ],
                            ),
                            if (Platform.isIOS)
                              if (MyConfig.isAppleLoginActive)
                                SignInWithAppleButton(
                                  text: "Apple",
                                  onPressed: () async {
                                    final _checkAvailability =
                                        await SignInWithApple.isAvailable();
                                    if (_checkAvailability) {
                                      try {
                                        await SignInWithApple
                                            .getAppleIDCredential(
                                          scopes: [
                                            AppleIDAuthorizationScopes.email,
                                            AppleIDAuthorizationScopes.fullName,
                                          ],
                                        ).then((value) {
                                          debugPrint(value.authorizationCode);
                                          if (value.identityToken != null) {
                                            context
                                                .read(userNotifierProvider
                                                    .notifier)
                                                .loginUsingApple(
                                                    value.identityToken!);
                                          } else {
                                            toast(LocaleKeys
                                                .something_went_wrong
                                                .tr());
                                          }
                                        });
                                      } catch (e) {
                                        toast(LocaleKeys.something_went_wrong
                                            .tr());
                                      }
                                    } else {
                                      toast(
                                          "Apple Login is not available on your device");
                                    }
                                  },
                                ).px(5).py(5),
                            Text(
                              LocaleKeys.dont_have_account.tr(),
                              style: context.textTheme.caption,
                              textAlign: TextAlign.center,
                            )
                                .onInkTap(
                                    () => context.nextPage(SignUpScreen()))
                                .py(16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Consumer(builder: (ctx, watch, _) {
                final authState = watch(userNotifierProvider);
                return Visibility(
                  visible: authState is UserLoadingState,
                  child: Container(
                    color: getColorBasedOnTheme(
                        context, kLightColor, kDarkBgColor),
                    child: const LoadingWidget(),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

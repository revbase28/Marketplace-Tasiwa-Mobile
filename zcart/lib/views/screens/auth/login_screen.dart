import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/providers/plugin_provider.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/wallet_provider.dart';
import 'package:zcart/riverpod/state/user_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/reset_password.dart';
import 'package:zcart/views/screens/auth/sign_up_screen.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/bottom_nav_bar/tab_navigation_item.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  final bool needBackButton;
  final Widget? nextScreen;
  final String nextScreenId;
  const LoginScreen({
    Key? key,
    required this.needBackButton,
    this.nextScreen,
    this.nextScreenId = accountTabId,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

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
          context.refresh(walletBalanceProvider);
          context.refresh(walletTransactionFutureProvider);
          context.refresh(getAddressFutureProvider);

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      BottomNavBar(selectedTabId: widget.nextScreenId)),
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
          appBar: widget.needBackButton
              ? AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  title: Text(LocaleKeys.sign_in.tr()),
                )
              : AppBar(
                  systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
                  toolbarHeight: 0,
                  backgroundColor: Colors.transparent,
                ),
          body: Consumer(builder: (context, watch, child) {
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
                      SizedBox(height: widget.needBackButton ? 24 : 48),
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
                          LocaleKeys.sign_in
                              .tr()
                              .split(" ")
                              .map((e) => e.capitalizeFirstLetter())
                              .join(" "),
                          textAlign: TextAlign.start,
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.nextPage(const ResetPassword());
                          },
                          child: Text(
                            LocaleKeys.forgot_password.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    color: kPriceColor,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      CustomButton(
                          buttonText: LocaleKeys.sign_in.tr(),
                          buttonBGColor: kButtonBgColor,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              context.read(userNotifierProvider.notifier).login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim());
                            }
                          }),
                      const SizedBox(height: 16),
                      if (MyConfig.isGoogleLoginActive ||
                          MyConfig.isFacebookLoginActive ||
                          MyConfig.isAppleLoginActive)
                        Text(
                          LocaleKeys.or_continue_with.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16),
                      const SocialLoginButtons(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(LocaleKeys.dont_have_account.tr(),
                              style: Theme.of(context).textTheme.subtitle2,
                              textAlign: TextAlign.center),
                          TextButton(
                              onPressed: () {
                                context.nextPage(SignUpScreen(
                                    nextScreen: widget.nextScreen,
                                    nextScreenID: widget.nextScreenId));
                              },
                              child: Text(LocaleKeys.sign_up.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    //Apple login check
    final _checkAppleLoginPluginProvider = watch(checkAppleLoginPluginProvider);
    //Google Login Check
    final _checkGoogleLoginPluginProvider =
        watch(checkGoogleLoginPluginProvider);
    //Facebook Login Check
    final _checkFacebookLoginPluginProvider =
        watch(checkFacebookLoginPluginProvider);

    void _onPressedAppleLogin() async {
      final _checkAvailability = await SignInWithApple.isAvailable();
      if (_checkAvailability) {
        try {
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          ).then((value) {
            debugPrint(value.authorizationCode);
            if (value.identityToken != null) {
              context
                  .read(userNotifierProvider.notifier)
                  .loginUsingApple(value.identityToken!);
            } else {
              toast(LocaleKeys.something_went_wrong.tr());
            }
          });
        } catch (e) {
          toast(LocaleKeys.something_went_wrong.tr());
        }
      } else {
        toast(LocaleKeys.apple_login_not_available.tr());
      }
    }

    void _onPressedFacebookLogin() async {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken accessToken = result.accessToken!;

        context
            .read(userNotifierProvider.notifier)
            .loginUsingFacebook(accessToken.token);
      } else {
        toast(LocaleKeys.something_went_wrong.tr());
      }
    }

    void _onPressedGoogleLogin() async {
      final GoogleSignInAccount? _googleUser = await GoogleSignIn().signIn();

      if (_googleUser != null) {
        final GoogleSignInAuthentication _googleAuth =
            await _googleUser.authentication;

        if (_googleAuth.accessToken != null) {
          context
              .read(userNotifierProvider.notifier)
              .loginUsingGoogle(_googleAuth.accessToken!);
        }
      } else {
        toast(LocaleKeys.something_went_wrong.tr());
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (MyConfig.isGoogleLoginActive)
          _checkGoogleLoginPluginProvider.when(
            data: (value) {
              if (value) {
                return SocialIconButton(
                    image: AppImages.google, onPressed: _onPressedGoogleLogin);
              } else {
                return const SizedBox();
              }
            },
            loading: () => const SizedBox(),
            error: (error, stackTrace) => const SizedBox(),
          ),
        if (MyConfig.isFacebookLoginActive) const SizedBox(width: 8),
        if (MyConfig.isFacebookLoginActive)
          _checkFacebookLoginPluginProvider.when(
            data: (value) {
              if (value) {
                return SocialIconButton(
                    image: AppImages.facebook,
                    onPressed: _onPressedFacebookLogin);
              } else {
                // return SocialIconButton(
                //     image: AppImages.facebook,
                //     onPressed: _onPressedFacebookLogin);
                return const SizedBox();
              }
            },
            loading: () => const SizedBox(),
            error: (error, stackTrace) => const SizedBox(),
          ),
        if (Platform.isIOS)
          if (MyConfig.isAppleLoginActive) const SizedBox(width: 8),
        if (Platform.isIOS)
          if (MyConfig.isAppleLoginActive)
            _checkAppleLoginPluginProvider.when(
              data: (value) {
                if (value) {
                  return SocialIconButton(
                    image: AppImages.apple,
                    onPressed: _onPressedAppleLogin,
                  );
                } else {
                  return const SizedBox();
                }
              },
              loading: () => const SizedBox(),
              error: (error, stackTrace) => const SizedBox(),
            ),
      ],
    );
  }
}

class SocialIconButton extends StatelessWidget {
  final String image;
  final VoidCallback onPressed;
  const SocialIconButton({
    Key? key,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kFadeColor, width: 2),
        ),
        child: Image.asset(image, width: 30, height: 30),
      ),
    );
  }
}

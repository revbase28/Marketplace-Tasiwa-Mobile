import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/providers/user_provider.dart';
import 'package:zcart/riverpod/state/user_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/termsAndConditions_screen.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  String _email = '';
  String _name = '';
  String _password = '';

  final _formKey = GlobalKey<FormState>();

  SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderListener<UserState>(
        provider: userNotifierProvider,
        onChange: (context, state) {
          if (state is UserLoadedState) {
            context.read(cartNotifierProvider.notifier).getCartList();
            context.read(wishListNotifierProvider.notifier).getWishList();
            context
                .nextAndRemoveUntilPage(const BottomNavBar(selectedIndex: 0));
          }
          if (state is UserErrorState) {
            toast(state.message, bgColor: kPrimaryColor);
          }
        },
        child: Scaffold(
          appBar: AppBar(),
          body: Stack(
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
                            color: EasyDynamicTheme.of(context).themeMode ==
                                    ThemeMode.dark
                                ? kDarkCardBgColor
                                : kLightCardBgColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(LocaleKeys.sign_up.tr(),
                                      style: context.textTheme.headline5),
                                ],
                              ),
                            ).paddingBottom(20),
                            CustomTextField(
                              hintText: LocaleKeys.your_full_name.tr(),
                              title: LocaleKeys.your_full_name.tr(),
                              onChanged: (value) => _name = value,
                              validator: (value) => value!.isEmpty
                                  ? LocaleKeys.field_required.tr()
                                  : null,
                            ),
                            CustomTextField(
                              hintText: LocaleKeys.your_email.tr(),
                              title: LocaleKeys.your_email.tr(),
                              onChanged: (value) => _email = value,
                              validator: (value) => value!.isEmpty
                                  ? LocaleKeys.field_required.tr()
                                  : null,
                            ),
                            CustomTextField(
                              isPassword: true,
                              hintText: LocaleKeys.your_password.tr(),
                              title: LocaleKeys.your_password.tr(),
                              onChanged: (value) => _password = value,
                              validator: (value) => value!.length < 6
                                  ? LocaleKeys.password_validation.tr()
                                  : null,
                            ),
                            CustomTextField(
                              isPassword: true,
                              hintText: LocaleKeys.your_confirm_password.tr(),
                              title: LocaleKeys.your_confirm_password.tr(),
                              validator: (value) => value != _password
                                  ? LocaleKeys.dont_match_password.tr()
                                  : null,
                            ),
                            CustomButton(
                              buttonText: LocaleKeys.sign_up.tr(),
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  hideKeyboard(context);
                                  context
                                      .read(userNotifierProvider.notifier)
                                      .register(_name.trim(), _email.trim(),
                                          _password, true, false);
                                }
                              },
                            ).pOnly(top: 10),
                            Text(
                              LocaleKeys.accept_terms_policy.tr(),
                            )
                                .text
                                .center
                                .textStyle(context.textTheme.caption!)
                                .make()
                                .w(context.screenWidth * 0.8)
                                .onInkTap(() => context.nextReplacementPage(
                                    const TermsAndConditionScreen()))
                                .pOnly(bottom: 10),
                            const Divider(
                              height: 20,
                            ),
                            Text(
                              LocaleKeys.have_account.tr(),
                            )
                                .text
                                .center
                                .textStyle(context.textTheme.caption!)
                                .make()
                                .w(context.screenWidth * 0.8)
                                .onInkTap(() => context.pop()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Consumer(
                builder: (context, watch, _) {
                  final authState = watch(userNotifierProvider);
                  return Visibility(
                    visible: authState is UserLoadingState,
                    child: Container(
                      color: EasyDynamicTheme.of(context).themeMode ==
                              ThemeMode.dark
                          ? kDarkBgColor
                          : kLightColor,
                      child: LoadingWidget(),
                    ),
                  );
                },
              )
            ],
          ),
        ));
  }
}

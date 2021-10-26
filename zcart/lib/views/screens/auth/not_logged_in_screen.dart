import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/controller/blog/blog_controller.dart';
import 'package:zcart/data/controller/others/others_controller.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/blogs/blogs_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/aboutUs_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/privacyPolicy_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/termsAndConditions_screen.dart';
import 'package:zcart/views/shared_widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/views/shared_widgets/update_language.dart';
import 'package:easy_localization/easy_localization.dart';

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: kDarkColor.withOpacity(0.5),
                        child: const Icon(
                          Icons.person,
                          color: kLightColor,
                          size: 28,
                        ),
                      ).pOnly(bottom: 5),
                      Text(
                        LocaleKeys.access_message.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.subtitle2!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomButton(
                        onTap: () {
                          context.nextPage(const LoginScreen(
                            needBackButton: true,
                          ));
                        },
                        buttonText: LocaleKeys.sign_in.tr(),
                      ),
                      Divider(
                        height: 20,
                        thickness: 2,
                        color: kAccentColor.withOpacity(0.5),
                        endIndent: 20,
                        indent: 20,
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(LocaleKeys.language.tr(),
                              style: context.textTheme.subtitle2!),
                          trailing: const Icon(Icons.translate),
                          onTap: () {
                            updateLanguage(context);
                          },
                        ),
                      ),
                      if (MyConfig.isDynamicThemeActive)
                        Card(
                          elevation: 0,
                          child: ListTile(
                              title: Text(LocaleKeys.change_theme.tr(),
                                  style: context.textTheme.subtitle2!),
                              trailing: EasyDynamicThemeSwitch()),
                        ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(LocaleKeys.blogs.tr(),
                              style: context.textTheme.subtitle2!),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.read(blogsProvider.notifier).blogs();
                            context.nextPage(const BlogsScreen());
                          },
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(LocaleKeys.about_us.tr(),
                              style: context.textTheme.subtitle2!),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context
                                .read(aboutUsProvider.notifier)
                                .fetchAboutUs();
                            context.nextPage(const AboutUsScreen());
                          },
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(LocaleKeys.privacy_policy.tr(),
                              style: context.textTheme.subtitle2!),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context
                                .read(privacyPolicyProvider.notifier)
                                .fetchPrivacyPolicy();
                            context.nextPage(const PrivacyPolicyScreen());
                          },
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: Text(LocaleKeys.terms_condition.tr(),
                              style: context.textTheme.subtitle2!),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context
                                .read(termsAndConditionProvider.notifier)
                                .fetchTermsAndCondition();
                            context.nextPage(const TermsAndConditionScreen());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

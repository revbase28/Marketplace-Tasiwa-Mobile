import 'dart:io';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/controller/others/others_controller.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/about_us_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/privacy_policy_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/others/terms_and_conditions_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/shared_widgets/custom_confirm_dialog.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/views/shared_widgets/update_language.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.settings.tr()),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text(LocaleKeys.language.tr(),
                          style: context.textTheme.subtitle2!),
                      trailing: const Icon(
                        Icons.translate,
                      ),
                      onTap: () {
                        updateLanguage(context);
                      },
                    ),
                  ),
                  if (MyConfig.isDynamicThemeActive)
                    Card(
                      child: ListTile(
                        title: Text(LocaleKeys.change_theme.tr(),
                            style: context.textTheme.subtitle2!),
                        trailing: EasyDynamicThemeSwitch(),
                      ),
                    ),
                  if (Platform.isAndroid)
                    Card(
                      elevation: 0,
                      child: ListTile(
                        title: Text("Clear Cache",
                            style: context.textTheme.subtitle2!),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await clearCache(context);
                        },
                      ),
                    ),
                  const Divider(
                    height: 30,
                    thickness: 1,
                  ),
                  Card(
                    child: ListTile(
                      title: Text(LocaleKeys.about_us.tr(),
                          style: context.textTheme.subtitle2!),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.read(aboutUsProvider.notifier).fetchAboutUs();
                        context.nextPage(const AboutUsScreen());
                      },
                    ),
                  ),
                  Card(
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
                  const Divider(
                    height: 30,
                    thickness: 1,
                  ),
                  Card(
                    child: ListTile(
                      trailing: const Icon(Icons.logout_outlined),
                      title: Text(LocaleKeys.sign_out.tr(),
                          style: context.textTheme.subtitle2!),
                      onTap: () async {
                        await showCustomConfirmDialog(
                          context,
                          title: "Are you sure to sign out?",
                          dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                          negativeText: LocaleKeys.no.tr(),
                          positiveText: LocaleKeys.yes.tr(),
                          onAccept: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            // await context
                            //     .read(addressNotifierProvider.notifier)
                            //     .clearAddresses();
                            await FacebookAuth.instance.logOut();
                            await GoogleSignIn().signOut();
                            await context
                                .read(userNotifierProvider.notifier)
                                .logout();
                            setState(() {
                              _isLoading = false;
                            });
                            await setValue(loggedIn, false).then((value) =>
                                context.nextAndRemoveUntilPage(
                                    const BottomNavBar()));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ).cornerRadius(10).p(10),
            ),
    );
  }
}

Future<void> clearCache(BuildContext context) async {
  await showCustomConfirmDialog(
    context,
    dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
    title: "Are you sure to clear cache?",
    subTitle:
        "This will delete all of your local data and signed you out if you are signed in.",
    negativeText: LocaleKeys.no.tr(),
    positiveText: LocaleKeys.yes.tr(),
    onAccept: () async {
      _clearAll().then((value) async {
        await Restart.restartApp();
      });
    },
  );
}

Future<void> _clearAll() async {
  toast("Clearing Cache...");
  await DefaultCacheManager().emptyCache();
  await sharedPreferences.clear();
  await Hive.deleteFromDisk();

  /// this will delete cache
  final cacheDir = await getTemporaryDirectory();
  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }

  /// this will delete app's storage
  final appDir = await getApplicationSupportDirectory();
  if (appDir.existsSync()) {
    appDir.deleteSync(recursive: true);
  }
  toast("Cache Cleared");
}

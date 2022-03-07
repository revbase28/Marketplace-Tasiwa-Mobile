import 'dart:io';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/blogs/blogs_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/settings/settings_page.dart';
import 'package:zcart/views/shared_widgets/update_language.dart';
import 'package:easy_localization/easy_localization.dart';

// class NotLoggedInScreen extends StatelessWidget {
//   const NotLoggedInScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
//         toolbarHeight: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const SizedBox(height: 32),
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: kDarkColor.withOpacity(0.5),
//                       child: const Icon(
//                         Icons.person,
//                         color: kLightColor,
//                         size: 28,
//                       ),
//                     ).pOnly(bottom: 5),
//                     Text(
//                       LocaleKeys.access_message.tr(),
//                       textAlign: TextAlign.center,
//                       style: context.textTheme.subtitle2!
//                           .copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     CustomButton(
//                       onTap: () {
//                         context.nextPage(const LoginScreen(
//                           needBackButton: true,
//                         ));
//                       },
//                       buttonText: LocaleKeys.sign_in.tr(),
//                     ),
//                     Divider(
//                       height: 20,
//                       thickness: 2,
//                       color: kAccentColor.withOpacity(0.5),
//                       endIndent: 20,
//                       indent: 20,
//                     ),
//                     const NotLoggedInSettingItems(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class NotLoggedInSettingItems extends StatelessWidget {
  const NotLoggedInSettingItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          child: ListTile(
            title: Text(LocaleKeys.language.tr(),
                style: context.textTheme.subtitle2!),
            leading: const Icon(Icons.translate),
            onTap: () {
              updateLanguage(context);
            },
          ),
        ),
        if (MyConfig.isDynamicThemeActive)
          Card(
            elevation: 0,
            child: ListTile(
              title: Text("Dark Mode", style: context.textTheme.subtitle2!),
              trailing: EasyDynamicThemeSwitch(),
              leading: const Icon(Icons.color_lens),
            ),
          ),
        if (Platform.isAndroid)
          Card(
            elevation: 0,
            child: ListTile(
              title: Text(LocaleKeys.clear_cache.tr(),
                  style: context.textTheme.subtitle2!),
              leading: const Icon(Icons.delete_forever),
              onTap: () async {
                await clearCache(context);
              },
            ),
          ),
        Card(
          elevation: 0,
          child: ListTile(
            title: Text(LocaleKeys.blogs.tr(),
                style: context.textTheme.subtitle2!),
            leading: const Icon(CupertinoIcons.doc_append),
            onTap: () {
              context.nextPage(const BlogsScreen());
            },
          ),
        ),
        const CompanyInfoWidgets(),
      ],
    );
  }
}

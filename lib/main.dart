import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/Theme/theme.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/riverpod/providers/logger_provider.dart';
import 'package:zcart/translations/codegen_loader.g.dart';
import 'package:zcart/translations/supported_locales.dart';
import 'views/screens/startup/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  //Run the app
  runApp(
    EasyDynamicThemeWidget(
      child: EasyLocalization(
        path: "assets/translations",
        supportedLocales: supportedLocales,
        fallbackLocale: Locale("en"),
        assetLoader: CodegenLoader(),
        child: ProviderScope(
          observers: [Logger()],
          child: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: API.APP_NAME,
      themeMode: MyConfig.isChangeAbleThemeActive
          ? EasyDynamicTheme.of(context).themeMode == ThemeMode.system
              ? ThemeMode.light
              : EasyDynamicTheme.of(context).themeMode
          : ThemeMode.light,
      theme: AppTheme.light(context),
      darkTheme: AppTheme.dark(context),
      home: LoadingScreen(),
    );
  }
}

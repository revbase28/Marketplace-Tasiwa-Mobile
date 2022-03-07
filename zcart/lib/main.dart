import 'dart:io';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/Theme/theme.dart';
import 'package:zcart/config/config.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/app_images.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/riverpod/providers/logger_provider.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';
import 'package:zcart/translations/codegen_loader.g.dart';
import 'package:zcart/translations/supported_locales.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/views/shared_widgets/system_config_builder.dart';
import 'views/screens/startup/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize the localizations
  await EasyLocalization.ensureInitialized();

  //Shared Pref Initialization
  await initialize();

  //Hive Initialization
  await Hive.initFlutter();
  await Hive.openBox(hiveBox);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  //Run the app
  runApp(
    EasyDynamicThemeWidget(
      child: EasyLocalization(
        path: "assets/translations",
        supportedLocales: supportedLocales,
        fallbackLocale: const Locale("en"),
        assetLoader: const CodegenLoader(),
        child: ProviderScope(
          observers: [Logger()],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _brightness = SchedulerBinding.instance!.window.platformBrightness;

    return MaterialApp(
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: API.appName,
      themeMode: MyConfig.isDynamicThemeActive
          ? EasyDynamicTheme.of(context).themeMode == ThemeMode.system
              ? _brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light
              : EasyDynamicTheme.of(context).themeMode
          : ThemeMode.light,
      theme: AppTheme.light(context),
      darkTheme: AppTheme.dark(context),
      // home: const LoadingScreen(),
      home: SystemConfigBuilder(
        builder: (context, systemConfig) {
          final bool? _isInMaintenance = systemConfig?.maintenanceMode;
          return _isInMaintenance == false
              ? const LoadingScreen()
              : _isInMaintenance == null
                  ? const SimpleLoadinPage()
                  : const MainTenanceModePage();
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MainTenanceModePage extends StatelessWidget {
  const MainTenanceModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.logo,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              const SizedBox(height: 24),
              Text(
                "Marketplace is in maintenance mode!\nPlease try again later.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  context.refresh(systemConfigFutureProvider);
                },
                icon: const Icon(Icons.sync),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleLoadinPage extends StatelessWidget {
  const SimpleLoadinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const Center(child: LoadingWidget()),
    );
  }
}

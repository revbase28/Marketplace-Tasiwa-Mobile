import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:zcart/helper/get_color_from.hex.dart';

class MyConfig {
  ///
  ///
  ///  [Read all the instructions carefully before editing any of the below]
  ///
  ///

  /// APP NAME
  ///This is your app name. You must change this name as your own app name. Currently the app name is
  /// [zCart].
  ///
  static const String appName = "zCart";

  ///

  /// APP URLS
  /// This is your app url. You must change this url as your own app url. Currently the app url is
  /// [https://zcart.incevio.com].
  ///
  ///
  static const String testServer = "https://test.incevio.cloud";
  static const String mainServer = "https://zcart.incevio.cloud/";
  static const String appUrl = mainServer;

  ///

  ///App API URL
  ///This is your app api url. You must change this url as your own app api url. Currently the app api
  ///url is [https://test.incevio.com/api/]. This is the url that you will use to access the api. Don't ////forget the slash [/] at the end and [https://] at the front.
  ///
  static const String appApiUrl = 'https://test.incevio.cloud/api/';

  ///

  /// APP COLORS
  /// These are your app colors. You must change this colors as your own app colors.
  ///Only change the hex values of the colors. Format of the color is [#FFFFFF].
  ///
  static final Color primaryColor = HexColor("#B91C1C");
  static final Color accentColor = HexColor("#5c5ffC");

  ///App Gradient Colors
  static final Color gradientColor1 = HexColor("#B12704");
  static final Color gradientColor2 = HexColor("#F75463");

  ///

  /// APP LOADING INDICATOR [OPTIONAL]
  /// This is your app loading indicator. You must change this loading indicator as your own app.
  /// Currently the app loading indicator is [SpinKitCubeGrid].
  /// You will find all the loading indicators in [SpinKit] package - [https://pub.dev/packages/flutter_spinkit]
  /// You just need to add the name of the indicator after [SpinKit]. For example here the name of the
  /// indicator is [CubeGrid]. So the complete name of the indicator is [SpinKitCubeGrid].
  ///
  static Widget loadingIndicator({
    required Color color,
    required Duration duration,
    required double size,
  }) =>
      SpinKitRing(color: color, size: size, duration: duration);

  ///

  /// TURN ON/OFF SWITCHABLE THEME AND SOCIAL LOGINS
  /// Currently all the values are set to [true]. You can change this to [false] if you want to turn off
  /// any of the theme and social logins.
  ///
  /// [true] means that the theme and social logins are enabled.
  /// [false] means that the theme and social logins are disabled.
  ///
  /// Social Logins
  /// FACEBOOK LOGIN
  static const bool isFacebookLoginActive = true;

  /// GOOGLE LOGIN
  static const bool isGoogleLoginActive = true;

  /// APPLE LOGIN
  static const bool isAppleLoginActive = true;

  // Theme
  static const bool isDynamicThemeActive = true;

  ///

  /// PAYMENT GATEWAY CONFIGS
  /// These are your payment gateway configs. You must change this configs as your own payment gateway API configs. If you don't have any payment gateway API configs then you can leave these configs as it is.
  ///
  ///
  ///
  ///[Payment gateway API key]
  static const String zcartApiKey = "ZDiCk73HVvKkxO9DlfDZ75fAyU4Nqfe9";
  static const String zcartSecretKey = "W7GEp9KOdQWYX0HCbmZb1XNy3ygSquUU";
  static const String zcartIV = "M9RzG4u5mJh5n9Og";

  ///
  ///
  ///
  ///
  ///
  ///
  /// Dont change the code below
  MyConfig._();
}

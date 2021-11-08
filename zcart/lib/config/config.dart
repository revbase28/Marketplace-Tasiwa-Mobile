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
  static const String appUrl = "https://zcart.incevio.com";

  ///

  ///App API URL
  ///This is your app api url. You must change this url as your own app api url. Currently the app api
  ///url is [https://test.incevio.com/api/]. This is the url that you will use to access the api. Don't ////forget the slash [/] at the end and [https://] at the front.
  ///
  static const String appApiUrl = 'https://staging.incevio.cloud/api/';

  ///

  /// APP COLORS
  /// These are your app colors. You must change this colors as your own app colors.
  ///Only change the hex values of the colors. Format of the color is [#FFFFFF].
  ///
  static final Color primaryColor = HexColor("#0071A5");
  static final Color accentColor = HexColor("#03A8C5");

  ///App Gradient Colors
  static final Color gradientColor1 = HexColor("#B12704");
  static final Color gradientColor2 = HexColor("#F7CE19");

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
      SpinKitCubeGrid(color: color, size: size, duration: duration);

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
  /// [RAZOR PAY]
  /// API KEY
  static const String razorPayApiKey = 'rzp_test_Pq4V0mcist4gfu';

  /// SECRET KEY
  static const String razorPaySecretKey = "oot8NuMhyoz6sZkYbkdCvCar";

  /// CURRENCY CODE
  static const String razorPayCurrency = "INR";

  /// [PAYSTACK]
  /// API KEY
  static const String paystackApiKey =
      'pk_test_4b0bfd886ad641c03fc008017c0f127adb3eecb3';

  /// [PAYPAL]
  /// SANDBOX MODE
  static const bool paypalSandboxMode = true;

  /// CLIENT ID
  static const String paypalClientId =
      "AT1_wwlwFHefidTjEF4DYzjOVoI7ZK66ib1zlVA0YZUPuNj4D4IG_0Sxmto5Q6leByaxgdbHi-KkkaHz";

  /// CLIENT SECRET
  static const String paypalClientSecret =
      "EO4T0rY9u0gcKlegpW8nGKoXS1QjUNHLlfgcGPjW5Sv5r7o7gMPVMaPAfGgmqbQWo7UB8OSG2Fgb2Nkt";

  /// PAYPAL TRANSACTION DESCRIPTION
  static const String paypalTransactionDescription = "Payment for ZCart";

  /// PAYPAL CURRENCY CODE
  static const String payPalCurrency = "USD";

  /// PAYSTACK CURRENCY CODE
  static const String paystackCurrency = "ZAR";

  ///
  ///
  ///
  ///
  ///
  ///
  /// Dont change the code below
  MyConfig._();
}

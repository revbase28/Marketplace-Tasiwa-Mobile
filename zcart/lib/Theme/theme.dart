import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zcart/Theme/dark_theme.dart';
import 'package:zcart/Theme/light_theme.dart';
import 'package:zcart/Theme/styles/colors.dart';

class AppTheme {
  AppTheme._();

  static light(BuildContext context) {
    return lightTheme.copyWith(
      textTheme: lightTextTheme(context),
      appBarTheme: const AppBarTheme().copyWith(
        color: kPrimaryColor,
        iconTheme: const IconThemeData(color: kLightColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        centerTitle: true,
        foregroundColor: kLightColor,
      ),
    );
  }

  static dark(BuildContext context) {
    return darkTheme.copyWith(
      textTheme: darkTextTheme(context),
      appBarTheme: const AppBarTheme().copyWith(
        color: kPrimaryColor,
        iconTheme: const IconThemeData(color: kLightColor),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        centerTitle: true,
        foregroundColor: kLightColor,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zcart/config/config.dart';

//Change these colors to as your own app needs
//Accent Color is the subtle colors of the primary color.
//Primary Color and Accent Color
// const kPrimaryColor = Color(0xff333E48);
final kPrimaryColor = MyConfig.primaryColor;
// final kAccentColor = Color(0xFF465058);
final kAccentColor = MyConfig.accentColor;

//Light Background Colors - Scaffold BG Color
const kLightBgColor = Color(0xfff5f5f5);
const kChipBgColor = Color(0xff1E40AF);

//Dark Background Colors - Scaffold BG Color
const kDarkBgColor = Color(0xFF2B2B2B);

//Light, dark and fade colors
const kLightColor = Colors.white;
const kDarkColor = Color(0xFF282828);
const kFadeColor = Color(0xFFB0B0B0);
const kBottomBarUnselectedColor = Color(0xFFB6A000);
const kBottomBarSelectedColor = Color(0xFF202938);

//Other Colors
const kGreenColor = Colors.green;
const kButtonBgColor = Color(0xFFEDD104);
const kTileColor = Color(0xFFFEF3C7);
const kTileTextColor = Color(0xFFF59E0B);

//Primary Text Colors
const kPrimaryLightTextColor = Colors.white;
const kPrimaryDarkTextColor = Color(0xFF202938);
const kPrimaryFadeTextColor = Color(0xFFB4B2B2);

//Price Text Colors
const kPriceColor = Color(0xFFB12704);
const kDarkPriceColor = Color(0xFFF7CE19);

//Change these values to your own app needs
//Gradient Color For Product Offer and Coupons
final kGradientColor1 = MyConfig.gradientColor1;
final kGradientColor2 = MyConfig.gradientColor2;

//No Need to change

//Card BG Color related to Primary Color
final kLightCardBgColor = kPrimaryColor.withOpacity(0.1);
const kDarkCardBgColor = Color(0xFF3D3C3C);

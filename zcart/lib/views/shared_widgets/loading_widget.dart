import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';

// ignore: use_key_in_widget_constructors
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyConfig.loadingIndicator(
      color: kPrimaryColor,
      size: 24,
      duration: const Duration(milliseconds: 700),
    ).center();
  }
}

import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/config/config.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyConfig.loadingIndicator(
      color: kPrimaryColor,
      size: 46,
      duration: const Duration(milliseconds: 700),
    ).center();
  }
}

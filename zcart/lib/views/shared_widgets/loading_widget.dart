import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: use_key_in_widget_constructors
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SpinKitCubeGrid(
      color: kPrimaryColor,
      size: 24,
      duration: Duration(milliseconds: 700),
    ).center();
  }
}

import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? buttonText;

  final Color? buttonBGColor;

  const CustomButton({
    Key? key,
    this.onTap,
    this.buttonText,
    this.buttonBGColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonBGColor ?? kPrimaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        height: 50.0,
        child: Center(
          child: Text(
            buttonText ?? "",
            style: Theme.of(context).textTheme.button!.copyWith(
                  color: kPrimaryLightTextColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? buttonText;

  final Color? buttonBGColor;
  final double widthMultiplier;

  const CustomButton({
    Key? key,
    this.onTap,
    this.buttonText,
    this.buttonBGColor,
    this.widthMultiplier = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width * widthMultiplier,
        decoration: BoxDecoration(
          color: buttonBGColor ?? kPrimaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
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

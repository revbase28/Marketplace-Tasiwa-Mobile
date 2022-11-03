import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';

class CustomSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color bgColor;
  const CustomSmallButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.bgColor = kChipBgColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: kLightColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

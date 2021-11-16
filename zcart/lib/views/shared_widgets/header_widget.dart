import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';

// ignore: must_be_immutable
class HeaderWidget extends StatelessWidget {
  final Function? function;
  final String? privacy;
  final Function? onTap;
  final String title;
  final IconData iconData;

  const HeaderWidget(
      {this.function,
      this.privacy,
      this.onTap,
      this.title = "Status",
      this.iconData = Icons.edit,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(title),
            const SizedBox(width: 10),
            //getPrivacyIcon(privacy).visible(!privacy.isEmptyOrNull)
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () => function!(),
                child: Icon(Icons.refresh, color: kPrimaryColor)),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onTap as void Function()?,
              child: Icon(iconData, color: kPrimaryColor, size: 20),
            )
          ],
        )
      ],
    );
  }
}

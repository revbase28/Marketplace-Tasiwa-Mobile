import 'package:flutter/material.dart';

class ResponsiveTextWidget extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ResponsiveTextWidget({
    required this.title,
    this.textStyle,
  });
  final TextStyle? textStyle;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title!,
            style: textStyle,
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/helper/url_launcher_helper.dart';

class ResponsiveTextWidget extends StatelessWidget {
  const ResponsiveTextWidget({
    required this.title,
    this.textStyle,
    Key? key,
  }) : super(key: key);
  final TextStyle? textStyle;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: HtmlWidget(
            title ?? '',
            enableCaching: true,
            textStyle: textStyle,
            onTapUrl: (url) {
              launchURL(url);
              return true;
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/helper/url_launcher_helper.dart';

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
          child: HtmlWidget(
            title ?? '',
            enableCaching: true,
            webView: true,
            webViewJs: true,
            webViewMediaPlaybackAlwaysAllow: true,
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

import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';

class DataList extends StatelessWidget {
  final String? title;
  final String? valueText;
  final Color backgroundColor;
  final Color textColor;

  // ignore: use_key_in_widget_constructors
  const DataList(
      {this.title,
      this.valueText,
      this.backgroundColor = const Color(0xFFF6F6F6),
      this.textColor = kDarkColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Text(title!),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(valueText!,
                      overflow: TextOverflow.ellipsis, softWrap: false),
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

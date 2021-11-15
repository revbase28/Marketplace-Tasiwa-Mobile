import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zcart/Theme/styles/colors.dart';

import 'package:nb_utils/nb_utils.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? title;

  //final IconData icon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? initialValue;
  final bool isPassword;

  final TextEditingController? controller;
  final int? minLines;
  final int? maxLines;
  final Color color;
  final double widthMultiplier;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.title,
    //this.icon = Icons.person,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.isPassword = false,
    this.controller,
    this.widthMultiplier = 0.8,
    this.maxLines = 1,
    this.minLines = 1,
    this.color = kLightColor,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.title == null
              ? Container()
              : Text(
                  widget.title!,
                  style: context.theme.textTheme.subtitle2,
                ).paddingBottom(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: MediaQuery.of(context).size.width * widget.widthMultiplier,
            decoration: BoxDecoration(
              color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                  ? kDarkBgColor
                  : widget.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: widget.inputFormatters,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              obscureText: widget.isPassword ? _passwordVisible : false,
              initialValue: widget.initialValue,
              validator: widget.validator,
              onChanged: widget.onChanged,
              style: context.theme.textTheme.bodyText2,
              decoration: InputDecoration(
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                              _passwordVisible = !_passwordVisible;
                            }))
                    : null,
                hintText: widget.hintText,
                hintStyle: context.theme.textTheme.caption,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

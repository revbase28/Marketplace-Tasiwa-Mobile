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
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    this.hintText,
    this.title,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.isPassword = false,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
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
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        style: context.theme.textTheme.bodyText2!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color:
                        EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                            ? kAccentColor
                            : kPrimaryColor,
                  ),
                  onPressed: () => setState(() {
                        _passwordVisible = !_passwordVisible;
                      }))
              : null,
          labelText: widget.hintText,
          labelStyle: context.theme.textTheme.subtitle2!.copyWith(
            fontWeight: FontWeight.bold,
            color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                ? kLightColor.withOpacity(0.6)
                : kDarkColor.withOpacity(0.6),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                    ? kLightColor.withOpacity(0.8)
                    : kDarkColor.withOpacity(0.8),
                width: 2),
          ),
        ),
      ),
    );
  }
}

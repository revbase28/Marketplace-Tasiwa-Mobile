import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';

// ignore: must_be_immutable
class CustomDropDownField extends StatefulWidget {
  final String? title;
  final String? value;
  TextEditingController? controller;
  final FormFieldValidator? validator;
  final Function? onChange;
  final List<String?>? optionsList;
  final double widthMultiplier;

  final void Function(int)? callbackFunction;
  final bool isCallback;
  final bool isProductDetailsView;

  CustomDropDownField(
      {Key? key,
      this.title,
      this.value,
      this.controller,
      this.onChange,
      this.optionsList,
      this.widthMultiplier = 0.8,
      this.callbackFunction,
      this.isCallback = false,
      this.validator,
      this.isProductDetailsView = false})
      : super(key: key);

  @override
  _CustomDropDownFieldState createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: !widget.isProductDetailsView
          ? const EdgeInsets.symmetric(vertical: 6)
          : null,
      child: DropdownButtonFormField(
        isExpanded: true,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontWeight: FontWeight.bold,
                color: getColorBasedOnTheme(context,
                    kDarkColor.withOpacity(0.8), kLightColor.withOpacity(0.8)),
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
                color: getColorBasedOnTheme(context,
                    kDarkColor.withOpacity(0.8), kLightColor.withOpacity(0.8)),
                width: 2),
          ),
        ),
        value: widget.optionsList!.first,
        items: widget.optionsList!.map((String? value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            widget.controller!.text = newValue!;
          });
          if (widget.isCallback) {
            widget.callbackFunction!(widget.optionsList!.indexOf(newValue));
          }
        },
      ),
    );
  }
}

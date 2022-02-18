import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/translations/iso_codes.dart';
import 'package:zcart/translations/supported_locales.dart';

void updateLanguage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: kLightColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: ListView(
          children: supportedLocales.map((locale) {
            return Padding(
              padding: EdgeInsets.only(
                  right: 16,
                  left: 16,
                  top: supportedLocales.indexOf(locale) == 0 ? 16 : 0),
              child: Card(
                child: ListTile(
                  onTap: () async {
                    context.pop();
                    await context.setLocale(locale);
                  },
                  leading: Localizations.localeOf(context).languageCode ==
                          locale.languageCode
                      ? const Icon(Icons.radio_button_checked)
                      : const Icon(Icons.radio_button_off),
                  title: Text(isoLangs[locale.languageCode]!["nativeName"]!
                      .split(",")
                      .first),
                  trailing: Text(
                      isoLangs[locale.languageCode]!["name"]!.split(",").first,
                      style: context.textTheme.caption),
                ),
              ),
            );
          }).toList(),

          // ElevatedButton(
          //   onPressed: () async {
          //     context.pop();
          //     await context.setLocale(Locale("en"));
          //   },
          //   child: Text("English"),
          // ),
        ),
      );
    },
  );
}

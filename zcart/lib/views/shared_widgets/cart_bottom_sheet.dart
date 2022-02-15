import 'package:flutter/material.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zcart/views/screens/tabs/myCart_tab/my_cart_tab.dart';

Future<dynamic> addToCartBottomSheet(BuildContext context, responseBody) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        decoration: BoxDecoration(
            color: kDarkColor.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              responseBody["message"],
              textAlign: TextAlign.center,
              style: context.textTheme.subtitle2!.copyWith(
                color: kPrimaryLightTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.nextPage(const MyCartTab());
                },
                child: Text(LocaleKeys.view_cart.tr())),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: Text(LocaleKeys.continue_shopping.tr()),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

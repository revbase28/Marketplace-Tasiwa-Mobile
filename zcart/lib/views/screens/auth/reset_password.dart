import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/custom_button.dart';
import 'package:zcart/views/shared_widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.reset_password.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.reset_password.tr(),
                  style: context.textTheme.headline6,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  title: LocaleKeys.your_email.tr(),
                  hintText: LocaleKeys.your_email.tr(),
                  validator: (value) => value!.isEmpty
                      ? LocaleKeys.field_required.tr()
                      : !value.contains('@') || !value.contains('.')
                          ? LocaleKeys.invalid_email.tr()
                          : null,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  buttonText: LocaleKeys.send_reset_link.tr(),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      hideKeyboard(context);
                      context
                          .read(userNotifierProvider.notifier)
                          .forgotPassword(_emailController.text.trim());
                      context.pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

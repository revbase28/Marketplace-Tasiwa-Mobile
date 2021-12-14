import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'password_update.dart';
import 'personal_details.dart';

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.account_detatils.tr()),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Personal Details
                PersonalDetails().cornerRadius(10).p(10),

                /// Password
                PasswordUpdate().cornerRadius(10).p(10),
              ],
            ),
          ),
          Consumer(builder: (context, watch, _) {
            final userState = watch(userNotifierProvider);
            return Visibility(
                visible: userState is UserLoadingState,
                child: Container(
                    color:
                        getColorBasedOnTheme(context, kLightColor, kDarkColor),
                    child: const LoadingWidget()));
          })
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/data/controller/others/others_controller.dart';
import 'package:zcart/data/controller/others/terms_and_condition_state.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.terms_condition.tr()),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Consumer(
            builder: (context, watch, _) {
              final termsAndConditionState = watch(termsAndConditionProvider);
              return termsAndConditionState is TermsAndConditionLoadedState
                  ? HtmlWidget(
                      termsAndConditionState
                          .termsAndConditionModel.data!.content!,
                      onTapUrl: (url) {
                        launchURL(url);
                        return true;
                      },
                    )
                  : termsAndConditionState is TermsAndConditionLoadingState
                      ? const LoadingWidget()
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(height: 10),
                              Text(LocaleKeys.no_data_yet.tr())
                            ],
                          ),
                        );
            },
          ),
        ),
      ),
    );
  }
}

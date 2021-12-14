import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/data/controller/others/about_us_state.dart';
import 'package:zcart/data/controller/others/others_controller.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.about_us.tr()),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Consumer(
            builder: (context, watch, _) {
              final aboutUsState = watch(aboutUsProvider);
              return aboutUsState is AboutUsLoadedState
                  ? HtmlWidget(
                      aboutUsState.aboutUsModel.data!.content!,
                      textStyle: context.textTheme.bodyText2!,
                      onTapUrl: (url) {
                        launchURL(url);
                        return true;
                      },
                    )
                  : aboutUsState is AboutUsLoadingState
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

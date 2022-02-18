import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/offers_provider.dart';
import 'package:zcart/riverpod/state/offers_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final offersState = watch(offersNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.offers.tr()),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: offersState is OffersLoadingState
            ? SizedBox(
                height: context.screenHeight - 100,
                child: const Center(child: LoadingWidget()))
            : offersState is OffersLoadedState
                ? Column(
                    children: [
                      Container(
                        color: getColorBasedOnTheme(
                            context, kLightColor, kDarkBgColor),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: CachedNetworkImage(
                                imageUrl: offersState.offersModel.data!.image!,
                                errorWidget: (context, url, error) =>
                                    const SizedBox(),
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                      value: progress.progress),
                                ),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                      offersState.offersModel.data!.name!,
                                      maxLines: null,
                                      softWrap: true,
                                      style: context.textTheme.bodyText2!),
                                ),
                              ],
                            ).py(5),
                            Text(
                                offersState.offersModel.data!.brand ??
                                    LocaleKeys.not_available.tr(),
                                style: context.textTheme.subtitle2),
                            Text(
                                "${offersState.offersModel.data!.gtinType ?? ""} : ${offersState.offersModel.data!.gtin ?? LocaleKeys.not_available.tr()}",
                                style: context.textTheme.subtitle2!),
                          ],
                        ),
                      ),
                      ProductDetailsCardGridView(
                              productList:
                                  offersState.offersModel.data!.listings!)
                          .px(8)
                    ],
                  )
                : const SizedBox(),
      ),
    );
  }
}

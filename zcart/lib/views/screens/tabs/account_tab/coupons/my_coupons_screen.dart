import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/cart/coupon_controller.dart';
import 'package:zcart/data/controller/cart/coupon_state.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/scroll_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';

class MyCouponsScreen extends ConsumerWidget {
  const MyCouponsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _couponState = watch(couponsProvider);
    final _scrollControllerProvider =
        watch(couponScrollNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.coupons.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: kLightColor),
            onPressed: () {
              context.read(couponsProvider.notifier).coupons();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () => context.read(couponsProvider.notifier).coupons(),
          child: _couponState is CouponLoadedState
              ? _couponState.coupon!.isNotEmpty
                  ? ProviderListener<ScrollState>(
                      onChange: (context, state) {
                        if (state is ScrollReachedBottomState) {
                          //TODO: Coupon load more

                        }
                      },
                      provider: couponScrollNotifierProvider,
                      child: ListView.builder(
                          controller: _scrollControllerProvider.controller,
                          itemCount: _couponState.coupon!.length,
                          itemBuilder: (context, index) {
                            return CouponsCard(
                              amount: _couponState.coupon![index].amount,
                              shopTitle: _couponState.coupon![index].shop!.name,
                              shopImage:
                                  _couponState.coupon![index].shop!.image,
                              code: _couponState.coupon![index].code,
                              notice: _couponState.coupon![index].validity,
                            );
                          }),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline).pOnly(bottom: 10),
                          Text(LocaleKeys.coupons_not_available.tr()),
                        ],
                      ),
                    )
              : _couponState is CouponLoadingState
                  ? const LoadingWidget()
                  : const SizedBox()),
    );
  }
}

class CouponsCard extends StatelessWidget {
  final String? amount;
  final String? shopTitle;
  final String? shopImage;
  final String? code;
  final String? notice;
  const CouponsCard({
    Key? key,
    this.amount,
    this.shopTitle,
    this.shopImage,
    this.code,
    this.notice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [kGradientColor1, kGradientColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    LocaleKeys.redeem_coupon.tr(),
                    style: context.textTheme.subtitle2!.copyWith(
                      color: kPrimaryLightTextColor,
                    ),
                  ).py(5),
                  Text(
                    code!,
                    style: context.textTheme.headline4!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: kPrimaryLightTextColor,
                    ),
                  ).onInkTap(() {
                    Clipboard.setData(ClipboardData(text: code))
                        .then((value) => toast(LocaleKeys.code_is_copied.tr()));
                  }),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: kLightColor,
                          width: 2,
                        )),
                    child: Text(
                      amount!,
                      style: context.textTheme.headline4!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryLightTextColor,
                      ),
                    ),
                  ),
                  Text(
                    shopTitle!,
                    style: context.textTheme.subtitle1!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryLightTextColor,
                    ),
                  ).py(5)
                ],
              ),
            ],
          ),
          Text(
            notice!,
            style: context.textTheme.caption!.copyWith(
              color: kPrimaryLightTextColor,
            ),
          ).pOnly(left: 16, top: 8),
        ],
      ),
    );
  }
}

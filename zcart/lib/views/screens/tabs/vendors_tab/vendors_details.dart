import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/riverpod/providers/provider.dart';
import 'package:zcart/riverpod/state/state.dart';
import 'package:zcart/views/screens/auth/login_screen.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/screens/tabs/home_tab/components/error_widget.dart';
import 'package:zcart/views/screens/tabs/vendors_tab/vendors_about_us_screen.dart';
import 'components/vendors_card.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

class VendorsDetailsScreen extends ConsumerWidget {
  const VendorsDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final vendorDetailsState = watch(vendorDetailsNotifierProvider);
    final vendorItemDetailsListState = watch(vendorItemsNotifierProvider);
    final scrollControllerProvider =
        watch(vendorItemScrollNotifierProvider.notifier);

    return ProviderListener<ScrollState>(
      provider: vendorItemScrollNotifierProvider,
      onChange: (context, state) {
        if (state is ScrollReachedBottomState) {
          context
              .read(vendorItemsNotifierProvider.notifier)
              .getMoreVendorItems();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: getOverlayStyleBasedOnTheme(context),
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          controller: scrollControllerProvider.controller,
          child: Column(
            children: [
              vendorDetailsState is VendorDetailsLoadedState
                  ? Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: context.screenHeight * .25,
                              width: context.screenWidth,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(vendorDetailsState
                                      .vendorDetails!.bannerImage!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    kDarkBgColor.withOpacity(0.5),
                                    BlendMode.darken,
                                  ),
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  vendorDetailsState.vendorDetails!.name!,
                                  style: context.textTheme.headline6!.copyWith(
                                    color: kLightColor.withOpacity(0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).pOnly(bottom: 5),
                            const Positioned(
                                child: BackButton(
                              color: kLightColor,
                            )),
                          ],
                        ),
                        VendorCard(
                          logo: vendorDetailsState.vendorDetails!.image,
                          name: vendorDetailsState.vendorDetails!.name,
                          verifiedText:
                              vendorDetailsState.vendorDetails!.verifiedText,
                          isVerified:
                              vendorDetailsState.vendorDetails!.verified,
                          rating: vendorDetailsState.vendorDetails!.rating,
                          onTap: () => context.nextPage(
                            VendorsAboutUsScreen(
                              vendorDetails: vendorDetailsState.vendorDetails,
                              onPressedContact: () {
                                if (accessAllowed) {
                                  context
                                      .read(productChatProvider.notifier)
                                      .productConversation(
                                        vendorDetailsState.vendorDetails!.id,
                                      );

                                  context.nextPage(
                                    VendorChatScreen(
                                        shopId: vendorDetailsState
                                            .vendorDetails!.id,
                                        shopImage: vendorDetailsState
                                            .vendorDetails!.image,
                                        shopName: vendorDetailsState
                                            .vendorDetails!.name,
                                        shopVerifiedText: vendorDetailsState
                                            .vendorDetails!.verifiedText),
                                  );
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(
                                                needBackButton: true,
                                              )));
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : vendorDetailsState is VendorDetailsLoadingState ||
                          vendorDetailsState is VendorDetailsInitialState
                      ? const ProductLoadingWidget().px(10)
                      : vendorDetailsState is VendorDetailsErrorState
                          ? ErrorMessageWidget(vendorDetailsState.message)
                          : const SizedBox(),
              vendorItemDetailsListState is VendorItemLoadedState
                  ? ProductDetailsCard(
                          productList: vendorItemDetailsListState.vendorItem!)
                      .px(10)
                  : vendorItemDetailsListState is VendorItemLoadingState ||
                          vendorItemDetailsListState is VendorItemInitialState
                      ? const ProductLoadingWidget().px(10)
                      : vendorItemDetailsListState is VendorItemErrorState
                          ? ErrorMessageWidget(
                              vendorItemDetailsListState.message)
                          : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

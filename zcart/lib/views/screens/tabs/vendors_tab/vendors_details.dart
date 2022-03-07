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
    final _vendorDetailsState = watch(vendorDetailsNotifierProvider);
    final _vendorItemDetailsListState = watch(vendorItemsNotifierProvider);
    final _scrollControllerProvider =
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
          controller: _scrollControllerProvider.controller,
          child: Column(
            children: [
              _vendorDetailsState is VendorDetailsLoadedState
                  ? Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: context.screenHeight * .25,
                              width: context.screenWidth,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(_vendorDetailsState
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
                                  _vendorDetailsState.vendorDetails!.name!,
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
                        const SizedBox(height: 10),
                        VendorCard(
                          logo: _vendorDetailsState.vendorDetails!.image,
                          name: _vendorDetailsState.vendorDetails!.name,
                          verifiedText:
                              _vendorDetailsState.vendorDetails!.verifiedText,
                          isVerified:
                              _vendorDetailsState.vendorDetails!.verified,
                          rating: _vendorDetailsState.vendorDetails!.rating,
                          onTap: () => context.nextPage(
                            VendorsAboutUsScreen(
                              vendorDetails: _vendorDetailsState.vendorDetails,
                              onPressedContact: () {
                                if (accessAllowed) {
                                  context
                                      .read(productChatProvider.notifier)
                                      .productConversation(
                                        _vendorDetailsState.vendorDetails!.id,
                                      );

                                  context.nextPage(
                                    VendorChatScreen(
                                        shopId: _vendorDetailsState
                                            .vendorDetails!.id,
                                        shopImage: _vendorDetailsState
                                            .vendorDetails!.image,
                                        shopName: _vendorDetailsState
                                            .vendorDetails!.name,
                                        shopVerifiedText: _vendorDetailsState
                                            .vendorDetails!.verifiedText),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(
                                        needBackButton: true,
                                        nextScreen: VendorsDetailsScreen(),
                                        nextScreenIndex: 1,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : _vendorDetailsState is VendorDetailsLoadingState ||
                          _vendorDetailsState is VendorDetailsInitialState
                      ? const ProductLoadingWidget().px(10)
                      : _vendorDetailsState is VendorDetailsErrorState
                          ? ErrorMessageWidget(_vendorDetailsState.message)
                          : const SizedBox(),
              _vendorItemDetailsListState is VendorItemLoadedState
                  ? ProductDetailsCardGridView(
                          productList: _vendorItemDetailsListState.vendorItem!)
                      .px(8)
                  : _vendorItemDetailsListState is VendorItemLoadingState ||
                          _vendorItemDetailsListState is VendorItemInitialState
                      ? const ProductLoadingWidget().px(10)
                      : _vendorItemDetailsListState is VendorItemErrorState
                          ? ErrorMessageWidget(
                              _vendorItemDetailsListState.message)
                          : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

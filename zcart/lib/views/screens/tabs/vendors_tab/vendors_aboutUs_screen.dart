import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/models/vendors/vendor_details_model.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';

import 'components/vendors_activity_card.dart';
import 'components/vendors_card.dart';

class VendorsAboutUsScreen extends StatelessWidget {
  final VendorDetails? vendorDetails;
  final VoidCallback onPressedContact;
  const VendorsAboutUsScreen({
    Key? key,
    this.vendorDetails,
    required this.onPressedContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: context.screenHeight * .25,
                    width: context.screenWidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(vendorDetails!.bannerImage!),
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
                        vendorDetails!.name!,
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
              Stack(
                alignment: Alignment.center,
                children: [
                  VendorCard(
                    logo: vendorDetails!.image,
                    name: vendorDetails!.name,
                    verifiedText: vendorDetails!.verifiedText,
                    isVerified: vendorDetails!.verified,
                    rating: vendorDetails!.rating,
                    trailingEnabled: false,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        tooltip: "Contact Shop",
                        onPressed: onPressedContact,
                        icon: const Icon(CupertinoIcons.bubble_left),
                      ),
                    ),
                  )
                ],
              ),
              VendorsActivityCard(
                activeListCount: vendorDetails!.activeListingsCount ?? 0,
                rating: vendorDetails!.rating ?? '0',
                itemsSold: vendorDetails!.soldItemCount ?? 0,
              ),
              Container(
                color: getColorBasedOnTheme(
                    context, kLightColor, kDarkCardBgColor),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.description.tr(),
                            style: context.textTheme.bodyText2)
                        .py(5),
                    ResponsiveTextWidget(
                        title: vendorDetails!.description,
                        textStyle: context.textTheme.caption!)
                  ],
                ),
              ).cornerRadius(10).p(10),
            ],
          ),
        ),
      ),
    );
  }
}

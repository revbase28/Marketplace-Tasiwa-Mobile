import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:zcart/views/screens/startup/loading_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderPlacedPage extends ConsumerWidget {
  final String? accessToken;

  const OrderPlacedPage({
    Key? key,
    this.accessToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
              onPressed: () {
                context.nextAndRemoveUntilPage(
                    const BottomNavBar(selectedIndex: 0));
              },
              icon: const Icon(Icons.home))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kLightColor,
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: kPrimaryColor,
                  size: 84,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const Text(
              'Order Confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kLightColor),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                "Thank you very much! Your order has been placed successfully!",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.w400, color: kLightColor),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: kLightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (accessToken != null) {
                    toast(LocaleKeys.register_successful.tr());
                    await setValue(loggedIn, true);
                    await setValue(access, accessToken).then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoadingScreen()),
                          (Route<dynamic> route) => false);
                    });
                  } else {
                    context.nextAndRemoveUntilPage(
                        const BottomNavBar(selectedIndex: 0));
                  }
                },
                child: Text(
                  'Continue Shopping',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // const SizedBox(height: 8),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //       horizontal: MediaQuery.of(context).size.width * 0.2),
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //       side: const BorderSide(color: kLightColor, width: 2),
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10)),
            //     ),
            //     onPressed: () async {
            //       context.nextReplacementPage(const MyOrderScreen());
            //     },
            //     child: Text(
            //       "Order History",
            //       style: Theme.of(context).textTheme.headline6!.copyWith(
            //           color: kLightColor, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';

class ProductLoadingWidget extends StatefulWidget {
  const ProductLoadingWidget({Key? key}) : super(key: key);

  @override
  _ProductLoadingWidgetState createState() => _ProductLoadingWidgetState();
}

class _ProductLoadingWidgetState extends State<ProductLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Shimmer.fromColors(
                baseColor: getColorBasedOnTheme(
                    context, Colors.grey[200]!, kDarkColor),
                highlightColor: getColorBasedOnTheme(
                    context, Colors.grey[100]!, kDarkCardBgColor),
                enabled: true,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      color: kLightColor,
                      borderRadius: BorderRadius.circular(10)),
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: Shimmer.fromColors(
              baseColor:
                  getColorBasedOnTheme(context, Colors.grey[200]!, kDarkColor),
              highlightColor: getColorBasedOnTheme(
                  context, Colors.grey[100]!, kDarkCardBgColor),
              enabled: true,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: .85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: kLightColor,
                                borderRadius: BorderRadius.circular(10)),
                            width: 85.0,
                            height: 58.0,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Container(
                            width: 85.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                                color: kLightColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Container(
                            width: 85.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                                color: kLightColor,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Flexible(
            child: Shimmer.fromColors(
                baseColor: getColorBasedOnTheme(
                    context, Colors.grey[200]!, kDarkColor),
                highlightColor: getColorBasedOnTheme(
                    context, Colors.grey[100]!, kDarkCardBgColor),
                enabled: true,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      color: getColorBasedOnTheme(
                          context, kLightColor, kDarkCardBgColor),
                      borderRadius: BorderRadius.circular(10)),
                )),
          ),
        ],
      ),
    );
  }
}

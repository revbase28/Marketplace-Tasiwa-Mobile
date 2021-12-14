import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/data/controller/blog/blog_controller.dart';
import 'package:zcart/data/controller/blog/blog_state.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class BlogDetailsScreen extends ConsumerWidget {
  const BlogDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final blogState = watch(blogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.blog_details.tr()),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: blogState is BlogLoadedState
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blogState.blog!.title!,
                    style: context.textTheme.headline6!
                        .copyWith(color: kDarkColor),
                  ).py(15).px(16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          radius: 20,
                          foregroundColor: whiteColor,
                          backgroundColor: kFadeColor,
                          backgroundImage: NetworkImage(
                            blogState.blog!.author!.avatar!,
                          )).pOnly(right: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(blogState.blog!.author!.name!,
                                  style: context.textTheme.subtitle2)
                              .pOnly(bottom: 5),
                          Text('${blogState.blog!.publishedAt}',
                              style: context.textTheme.caption),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.hand_thumbsup,
                                  size: 14,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(blogState.blog!.likes.toString()),
                              ],
                            ),
                            const VerticalDivider(
                              width: 5,
                              thickness: 2,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.text_bubble,
                                  size: 14,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(blogState.blog!.commentsCount.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).pOnly(bottom: 8).px(16),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: blogState.blog!.tags!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Chip(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          label: Text(
                            blogState.blog!.tags![index].firstLetterUpperCase(),
                            style: context.textTheme.caption!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryLightTextColor),
                          ),
                        ).p(2);
                      },
                    ).pOnly(bottom: 10).pOnly(left: 8),
                  ),
                  SizedBox(
                    width: context.screenWidth,
                    child: CachedNetworkImage(
                      imageUrl: blogState.blog!.featuredImage!,
                      errorWidget: (context, url, error) => const SizedBox(),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child:
                            CircularProgressIndicator(value: progress.progress),
                      ),
                      fit: BoxFit.cover,
                    ).pOnly(bottom: 10),
                  ),
                  HtmlWidget(
                    blogState.blog!.content!,
                    textStyle: context.textTheme.bodyText2!.copyWith(
                        fontSize: 15, letterSpacing: 0, wordSpacing: 1.4),
                    enableCaching: true,
                    onTapUrl: (url) {
                      launchURL(url);
                      return true;
                    },
                  ).pOnly(bottom: 10).px(16),
                  Text(
                    LocaleKeys.comments.tr(),
                    style: context.textTheme.headline6!.copyWith(
                      color: kPrimaryColor,
                    ),
                  ).pOnly(left: 16, bottom: 10),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: blogState.blog!.comments!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: kPrimaryColor.withOpacity(.03),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 20,
                                  foregroundColor: whiteColor,
                                  backgroundColor: kFadeColor,
                                  backgroundImage: NetworkImage(
                                    blogState
                                        .blog!.comments![index].author!.avatar!,
                                  )).pOnly(right: 10),
                              Expanded(
                                child: Text(
                                  blogState.blog!.comments![index].content!,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ).cornerRadius(10).pOnly(bottom: 10);
                      }).px(16)
                ],
              ),
            )
          : const LoadingWidget().p(17),
    );
  }
}

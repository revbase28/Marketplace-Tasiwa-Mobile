import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/data/controller/blog/blog_controller.dart';
import 'package:zcart/data/controller/blog/blog_state.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/blogs/blogs_details_screen.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';

class BlogsScreen extends ConsumerWidget {
  const BlogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final blogsState = watch(blogsProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.blogs.tr()),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                context.read(blogsProvider.notifier).blogs();
              },
            ),
          ],
        ),
        body: blogsState is BlogsLoadedState
            ? blogsState.blogList!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: blogsState.blogList!.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          context
                              .read(blogProvider.notifier)
                              .blog(blogsState.blogList![index].slug);
                          context.nextPage(const BlogDetailsScreen());
                        },
                        tileColor: getColorBasedOnTheme(
                            context, kLightColor, kDarkCardBgColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: SizedBox(
                          width: 50,
                          child: CachedNetworkImage(
                            imageUrl:
                                blogsState.blogList![index].featuredImage!,
                            errorWidget: (context, url, error) =>
                                const SizedBox(),
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                              child: CircularProgressIndicator(
                                  value: progress.progress),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          blogsState.blogList![index].title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        isThreeLine: true,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HtmlWidget(
                              blogsState.blogList![index].excerpt!.substring(
                                      0,
                                      blogsState.blogList![index].excerpt!
                                                  .length >
                                              60
                                          ? 60
                                          : blogsState.blogList![index].excerpt!
                                              .length) +
                                  (blogsState.blogList![index].excerpt!.length >
                                          60
                                      ? "..."
                                      : ""),
                              textStyle: context.textTheme.subtitle2!,
                              onTapUrl: (url) {
                                launchURL(url);
                                return true;
                              },
                            ).pOnly(bottom: 5),
                            Text(
                              "${LocaleKeys.author.tr()} : ${blogsState.blogList![index].author!.name}",
                              style: context.textTheme.caption,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                    Text(blogsState.blogList![index].likes
                                        .toString()),
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
                                    Text(blogsState
                                        .blogList![index].commentsCount
                                        .toString()),
                                  ],
                                ),
                                Expanded(
                                  child: Text(
                                    blogsState.blogList![index].updatedAt!,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ).pSymmetric(v: 5),
                                ),
                              ],
                            ).pOnly(top: 3),
                          ],
                        ).pSymmetric(v: 5),
                      ).pOnly(bottom: 12);
                    })
                : SingleChildScrollView(
                    child: SizedBox(
                      height: context.screenHeight,
                      width: context.screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline).pOnly(bottom: 10),
                          Text(LocaleKeys.blogs_not_available.tr()),
                        ],
                      ),
                    ),
                  )
            : blogsState is BlogsLoadingState
                ? const LoadingWidget()
                : const SizedBox());
  }
}

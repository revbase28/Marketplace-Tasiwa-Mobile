import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  const ImageViewerPage({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(title),
          systemOverlayStyle: getOverlayStyleBasedOnTheme(context)),
      body: PhotoView(imageProvider: CachedNetworkImageProvider(imageUrl)),
    );
  }
}

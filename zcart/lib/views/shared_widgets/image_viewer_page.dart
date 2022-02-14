import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

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
          title: Text(title), systemOverlayStyle: SystemUiOverlayStyle.light),
      body: PinchZoom(
        child: CachedNetworkImage(imageUrl: imageUrl),
        resetDuration: const Duration(milliseconds: 100),
      ),
    );
  }
}

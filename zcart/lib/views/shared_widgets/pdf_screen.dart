import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:zcart/helper/url_launcher_helper.dart';

class PDFScreen extends StatefulWidget {
  final String path;

  const PDFScreen({Key? key, required this.path}) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  late Completer<PDFViewController> _controller;

  int? _currentPage = 0;
  bool _isReady = false;
  String errorMessage = '';
  String _path = "";

  @override
  void initState() {
    _path = widget.path;
    _controller = Completer<PDFViewController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split("/").last),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: const [
          //ShareButton
          // IconButton(
          //     onPressed: () async {
          //       //await Share.share(widget.link);
          //     },
          //     icon: const Icon(Icons.share)),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: PDFView(
              filePath: _path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage!,
              onRender: (_pages) {
                setState(() {
                  _pages = _pages;
                  _isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onLinkHandler: (String? uri) {
                launchURL(uri ?? "");
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
          errorMessage.isEmpty
              ? !_isReady
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}

Future<String?> generateInvoice(String api, String name) async {
  final _response = await getRequest(api, bearerToken: true);
  if (_response.body.isEmpty) {
    return null;
  }
  if (_response.statusCode > 206) {
    return null;
  }

  final File _file = File(await getTemporaryDirectory()
      .then((value) => value.path + "/" + "$name.pdf"));
  final _res = await _file.writeAsBytes(_response.bodyBytes);

  return _res.path;
}

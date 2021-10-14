import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(url) async =>
    await canLaunch(url) ? await launch(url) : toast('Could not launch $url');

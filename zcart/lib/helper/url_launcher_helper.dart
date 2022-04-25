import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
    ? await launchUrl(Uri.parse(url))
    : toast('Could not launch $url');

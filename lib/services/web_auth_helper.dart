import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class WebAuthHelper {
  static Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
  }) async {
    final appLinks = AppLinks();

    final callbackFuture = appLinks.uriLinkStream
        .firstWhere((uri) => uri.scheme == callbackUrlScheme)
        .timeout(const Duration(minutes: 5));

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

    final callbackUri = await callbackFuture;
    return callbackUri.toString();
  }
}

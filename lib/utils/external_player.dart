import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:jiruhub/models/index.dart';
import 'package:jiruhub/utils/request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchMobileExternalPlayer(String playUrl, String player) async {
  switch (player) {
    case "vlc":
      await _launchExternalPlayer("vlc://$playUrl");
      break;
    case "other":
      await AndroidIntent(
        action: 'action_view',
        data: playUrl,
        type: 'video/*',
      ).launch();
      break;
  }
}

// desktop
Future<void> launchDesktopExternalPlayer(
    String playUrl,
    String player,
    Map<String, String> headers,
    List<ExtensionBangumiWatchSubtitle> subs) async {
  final subLink = subs.map((e) => e.url).toList();
  //windows
  if (Platform.isWindows) {
    switch (player) {
      case "vlc":
        const vlc = 'C:\\Program Files\\VideoLAN\\VLC\\vlc.exe';
        await Process.run(vlc, [playUrl]);
        break;
      case "potplayer":
        await _launchExternalPlayer("potplayer://$playUrl");
        break;
    }
  }
  //linux
  switch (player) {
    case "vlc":
      await Process.run("vlc", [playUrl]);
      break;
    case "mpv":
      final sub = [];
      var directory = await getTemporaryDirectory();
      for (final s in subs) {
        final fileName = Uri.parse(s.url).pathSegments.last;
        final response = await dio.get(s.url);
        final targetPath = '${directory.path}/$fileName';
        await File(targetPath).writeAsString(response.data);
        sub.add(targetPath);
      }

      final uA = headers.remove("User-Agent");
      final headerFields =
          headers.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      await Process.run("mpv", [
        playUrl,
        '--user-agent=$uA',
        if (headerFields.isNotEmpty) '--http-header-fields="$headerFields"',
        if (subLink.isNotEmpty) '--sub-files=${sub.join(":")}',
      ]);
      break;
  }
}

_launchExternalPlayer(String url) async {
  if (!await launchUrlString(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Failed to launch $url");
  }
}

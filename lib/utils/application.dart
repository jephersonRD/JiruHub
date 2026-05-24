// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:jiruhub/utils/i18n.dart';
import 'package:jiruhub/utils/request.dart';
import 'package:jiruhub/utils/router.dart';
import 'package:jiruhub/views/widgets/button.dart';
import 'package:jiruhub/views/widgets/messenger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

late PackageInfo packageInfo;
late AndroidDeviceInfo androidDeviceInfo;
late WindowsDeviceInfo windowsDeviceInfo;
late LinuxDeviceInfo linuxDeviceInfo;

class ApplicationUtils {
  static Future ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
      return packageInfo;
    }
    if (Platform.isLinux) {
      linuxDeviceInfo = await deviceInfo.linuxInfo;
      return packageInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfo.windowsInfo;
    }
    return packageInfo;
  }

  static String get _platformSuffix =>
      Platform.isWindows ? 'windows.zip' : 'linux.tar.gz';

  static checkUpdate(BuildContext context, {bool showSnackbar = false}) async {
    try {
      const url =
          "https://api.github.com/repos/jephersonRD/JiruHub/releases/latest";
      final res = await dio.get(url);
      final tagName = res.data["tag_name"] as String;
      final remoteVersion = tagName.replaceFirst('v', '');
      debugPrint('remoteVersion: $remoteVersion');
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          Get.to(
            Scaffold(
              appBar: AppBar(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    'upgrade.new-version',
                    translationParams: {
                      'version': remoteVersion,
                    },
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: Markdown(data: res.data['body'])),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformFilledButton(
                        onPressed: () {
                          RouterUtils.pop();
                          launchUrl(
                            Uri.parse(res.data['html_url']),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text('upgrade.download'.i18n),
                      ),
                    )
                  ],
                ),
              ),
            ),
            transition: Transition.rightToLeftWithFade,
          );
          return;
        }

        final expectedName = 'JiruHub-$tagName-$_platformSuffix';
        final assets = res.data['assets'] as List;
        Map<String, dynamic>? asset;
        try {
          asset = assets.firstWhere(
            (a) => (a['name'] as String) == expectedName,
          ) as Map<String, dynamic>;
        } catch (_) {
          asset = null;
        }

        showPlatformDialog(
          context: context,
          title: FlutterI18n.translate(
            context,
            'upgrade.new-version',
            translationParams: {
              'version': remoteVersion,
            },
          ),
          content: Markdown(
            shrinkWrap: true,
            data: res.data['body'],
          ),
          actions: [
            PlatformTextButton(
              onPressed: () {
                RouterUtils.pop();
              },
              child: Text('upgrade.not-now'.i18n),
            ),
            PlatformFilledButton(
              onPressed: () {
                RouterUtils.pop();
                if (asset != null) {
                  _downloadAndInstall(context, asset, remoteVersion);
                } else {
                  launchUrl(
                    Uri.parse(res.data['html_url']),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Text(
                asset != null ? 'Download & Install' : 'upgrade.download'.i18n,
              ),
            )
          ],
        );
      } else {
        if (!showSnackbar) {
          return;
        }
        showPlatformSnackbar(
          context: context,
          title: 'upgrade.check-update'.i18n,
          content: "upgrade.no-update".i18n,
        );
      }
    } catch (e) {
      if (!showSnackbar) {
        return;
      }
      showPlatformSnackbar(
        context: context,
        title: 'upgrade.check-update'.i18n,
        content: 'upgrade.error'.i18n,
      );
    }
  }

  static Future<void> _downloadAndInstall(
    BuildContext context,
    Map<String, dynamic> asset,
    String version,
  ) async {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading update...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final url = asset['browser_download_url'] as String;
      final tempDir = Directory.systemTemp.createTempSync('jiruhub_update_');
      final downloadPath = '${tempDir.path}/${asset['name']}';

      await dio.download(url, downloadPath);

      if (Platform.isLinux) {
        await Process.run('tar', [
          '-xzf',
          downloadPath,
          '-C',
          tempDir.path,
        ]);
      } else if (Platform.isWindows) {
        await Process.run('powershell', [
          'Expand-Archive',
          '-Path',
          downloadPath,
          '-DestinationPath',
          tempDir.path,
          '-Force',
        ]);
      }

      Get.back();

      await _replaceAndRestart(tempDir);
    } catch (e) {
      Get.back();
      if (context.mounted) {
        showPlatformSnackbar(
          context: context,
          title: 'Update failed',
          content: e.toString(),
        );
      }
    }
  }

  static Future<void> _replaceAndRestart(Directory tempDir) async {
    final currentExe = Platform.resolvedExecutable;
    final installDir = Directory(currentExe).parent;
    final exeName = currentExe.split(Platform.pathSeparator).last;

    if (Platform.isLinux) {
      await Process.run('cp', ['-r', '${tempDir.path}/.', installDir.path]);
      Process.start(
        '${installDir.path}/$exeName',
        [],
        mode: ProcessStartMode.normal,
      );
      exit(0);
    } else if (Platform.isWindows) {
      final batchPath = '${tempDir.path}\\update.bat';
      File(batchPath).writeAsStringSync(
        '@echo off\r\n'
        'chcp 65001 >nul\r\n'
        'timeout /t 3 /nobreak >nul\r\n'
        'xcopy /y /e /q "${tempDir.path}\\*.*" "${installDir.path}\\"\r\n'
        'start "" "${installDir.path}\\$exeName"\r\n'
        'rmdir /s /q "${tempDir.path}"\r\n',
      );
      Process.start(
        batchPath,
        [],
        mode: ProcessStartMode.normal,
        runInShell: true,
      );
      exit(0);
    }
  }
}

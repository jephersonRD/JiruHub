import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiruhub/models/extension.dart';
import 'package:jiruhub/controllers/extension/extension_controller.dart';
import 'package:jiruhub/controllers/search_controller.dart';
import 'package:jiruhub/controllers/settings_controller.dart';
import 'package:jiruhub/data/services/extension_service.dart';
import 'package:jiruhub/utils/i18n.dart';
import 'package:jiruhub/utils/jiruhub_directory.dart';
import 'package:jiruhub/utils/request.dart';
import 'package:jiruhub/utils/router.dart';
import 'package:jiruhub/views/widgets/button.dart';
import 'package:jiruhub/views/widgets/messenger.dart';
import 'package:path/path.dart' as path;

class ExtensionUtils {
  static Map<String, ExtensionService> runtimes = {};
  static Map<String, String> extensionErrorMap = {};

  static String get extensionsDir => path.join(
        JiruHubDirectory.getDirectory,
        'extensions',
      );

  // 初始化扩展
  static ensureInitialized() async {
    // 创建目录
    Directory(extensionsDir).createSync(recursive: true);
    await _loadExtensions();
    // 监听目录变化
    Directory(extensionsDir).watch().listen((event) async {
      if (path.extension(event.path) == '.js') {
        final package = path.basenameWithoutExtension(event.path);
        debugPrint('extension event: ${event.path} ${event.type}');
        switch (event.type) {
          case FileSystemEvent.delete:
            runtimes.remove(package);
            extensionErrorMap.remove(event.path);
            _safeReloadPage();
            break;
          case FileSystemEvent.create:
          case FileSystemEvent.modify:
            // Skip if this package is already being installed (e.g. by install())
            if (_loading.contains(package)) break;
            runtimes.remove(package);
            extensionErrorMap.remove(event.path);
            await installByPath(event.path);
            _safeReloadPage();
            break;
        }
      }
    });
  }

  static _loadExtensions() async {
    // 获取扩展列表
    final extensionsList = Directory(extensionsDir).listSync();
    // 遍历扩展列表
    for (final extension in extensionsList) {
      await installByPath(extension.path);
    }

    _reloadPage();
  }

  static uninstall(String package) async {
    final file = File(path.join(extensionsDir, '$package.js'));
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static install(String url, BuildContext context) async {
    try {
      final res = await dio.get<String>(url);
      if (res.data == null) {
        throw Exception("Does not seem to be an extension");
      }
      final ext = ExtensionUtils.parseExtension(res.data!);
      final savePath = path.join(extensionsDir, '${ext.package}.js');
      // Guard before writing so the file watcher skips this package
      _loading.add(ext.package);
      File(savePath).writeAsStringSync(res.data!);
      try {
        runtimes[ext.package] = await ExtensionService().initRuntime(ext);
      } finally {
        _loading.remove(ext.package);
      }
      _safeReloadPage();
    } catch (e) {
      if (context.mounted) {
        showPlatformDialog(
          context: context,
          title: 'extension-install-error'.i18n,
          content: Text(e.toString()),
          actions: [
            PlatformButton(
              child: Text('common.close'.i18n),
              onPressed: () {
                RouterUtils.pop();
              },
            )
          ],
        );
      }
      rethrow;
    }
  }

  static installByScript(String script, BuildContext context) async {
    try {
      final ext = ExtensionUtils.parseExtension(script);
      final savePath = path.join(extensionsDir, '${ext.package}.js');
      // Mark as loading BEFORE writing the file so the file watcher skips this package
      _loading.add(ext.package);
      // 保存文件
      File(savePath).writeAsStringSync(script);
      try {
        runtimes[ext.package] = await ExtensionService().initRuntime(ext);
      } finally {
        _loading.remove(ext.package);
      }
      _reloadPage();
    } catch (e) {
      if (context.mounted) {
        showPlatformDialog(
          context: context,
          title: 'extension-install-error'.i18n,
          content: Text(e.toString()),
          actions: [
            PlatformButton(
              child: Text('common.close'.i18n),
              onPressed: () {
                RouterUtils.pop();
              },
            )
          ],
        );
      }
      rethrow;
    }
  }

  static final Set<String> _loading = {};

  static installByPath(String p) async {
    if (path.extension(p) == '.js') {
      try {
        final file = File(p);
        final content = await file.readAsString();
        final ext = ExtensionUtils.parseExtension(content);
        // Skip if already loaded with same version (prevents Isar unique index violation
        // when file watcher fires multiple events during install)
        if (runtimes.containsKey(ext.package) &&
            runtimes[ext.package]!.extension.version == ext.version) {
          return;
        }
        // Prevent concurrent loads of the same package
        if (_loading.contains(ext.package)) return;
        _loading.add(ext.package);
        try {
          runtimes[ext.package] = await ExtensionService().initRuntime(ext);
        } finally {
          _loading.remove(ext.package);
        }
      } catch (e) {
        extensionErrorMap[p] = e.toString();
      }
    }
  }

  static _safeReloadPage() {
    try {
      _reloadPage();
    } catch (_) {}
  }

  static _reloadPage() {
    // 重载扩展页面
    if (Get.isRegistered<ExtensionPageController>()) {
      Get.find<ExtensionPageController>().callRefresh();
    }
    // 重载搜索页面
    if (Get.isRegistered<SearchPageController>()) {
      Get.find<SearchPageController>().callRefresh();
    }
  }

  static String typeToString(ExtensionType type) {
    switch (type) {
      case ExtensionType.bangumi:
        return 'extension-type.video'.i18n;
      case ExtensionType.fikushon:
        return 'extension-type.novel'.i18n;
      case ExtensionType.manga:
        return 'extension-type.comic'.i18n;
    }
  }

  static addLog(
    Extension ext,
    ExtensionLogLevel level,
    String logContent,
  ) async {
    if (!Get.isRegistered<SettingsController>()) {
      return;
    }
    final windowId = Get.find<SettingsController>().extensionLogWindowId.value;
    if (windowId == -1) {
      return;
    }
    try {
      DesktopMultiWindow.invokeMethod(
        windowId,
        "addLog",
        jsonEncode(
          ExtensionLog(
            extension: ext,
            content: logContent,
            time: DateTime.now(),
            level: level,
          ).toJson(),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static addNetworkLog(
    String key,
    ExtensionNetworkLog log,
  ) {
    if (!Get.isRegistered<SettingsController>()) {
      return;
    }
    final windowId = Get.find<SettingsController>().extensionLogWindowId.value;
    if (windowId == -1) {
      return;
    }
    try {
      DesktopMultiWindow.invokeMethod(
        windowId,
        "addNetworkLog",
        jsonEncode({
          'key': key,
          'log': log.toJson(),
        }),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ==MiruExtension==
  // @name         Enime
  // @version      v0.0.1
  // @author       MiaoMint
  // @lang         all
  // @license      MIT
  // @icon         https://avatars.githubusercontent.com/u/74993083?s=200&v=4
  // @package      moe.enime
  // @type         bangumi
  // @webSite      https://api.enime.moe/
  // @description  Enime API is an open source API service for developers to access anime info (as well as their video sources) https://github.com/Enime-Project/api.enime.moe
  // ==/MiruExtension==

  // 解析扩展为元数据
  static Extension parseExtension(String extension) {
    Map<String, dynamic> result = {};
    RegExp exp = RegExp(r'@(\w+)\s+(.*)');
    Iterable<RegExpMatch> matches = exp.allMatches(extension);
    for (RegExpMatch match in matches) {
      result[match.group(1)!] = match.group(2);
    }
    result['nsfw'] = result['nsfw'] == "true";
    return Extension.fromJson(result);
  }
}

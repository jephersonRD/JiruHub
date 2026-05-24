import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:jiruhub/models/extension.dart';
import 'package:jiruhub/utils/extension.dart';
import 'package:jiruhub/utils/i18n.dart';
import 'package:jiruhub/utils/jiruhub_storage.dart';
import 'package:jiruhub/utils/request.dart';
import 'package:jiruhub/views/widgets/cache_network_image.dart';
import 'package:jiruhub/views/widgets/platform_widget.dart';
import 'package:jiruhub/views/widgets/progress.dart';

class ExtensionCard extends StatefulWidget {
  const ExtensionCard({
    super.key,
    required this.name,
    required this.version,
    required this.icon,
    required this.package,
    required this.lang,
    required this.nsfw,
    required this.type,
    this.url,
    this.webSite,
    this.license,
    this.description,
  });
  final String? icon;
  final String? url;
  final String name;
  final String version;
  final String package;
  final String lang;
  final ExtensionType type;
  final bool nsfw;
  final String? webSite;
  final String? license;
  final String? description;

  @override
  State<ExtensionCard> createState() => _ExtensionCardState();
}

class _ExtensionCardState extends State<ExtensionCard> {
  bool isLoading = false;
  bool isInstall = false;
  bool hasUpgrade = false;
  late String icon = widget.icon ?? '';

  @override
  void initState() {
    setState(() {
      isInstall = ExtensionUtils.runtimes.containsKey(widget.package);
      hasUpgrade = isInstall &&
          ExtensionUtils.runtimes[widget.package]!.extension.version !=
              widget.version;
    });
    super.initState();
  }

  _install() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Use direct url from index.json if available, otherwise fallback to repo convention
      final url = widget.url ??
          JiruHubStorage.getSetting(SettingKey.jiruhubRepoUrl) +
              "/repo/${widget.package}.js";
      debugPrint(url);
      final res = await dio.get<String>(url);
      if (res.data == null) throw Exception("Does not seem to be an extension");

      String script = res.data!;
      // Inject metadata header if missing (e.g. CDN cache serving old file)
      if (!script.contains('==JiruHubExtension==') && !script.contains('==MiruExtension==') && !script.contains('@package')) {
        final typeName = widget.type.toString().split('.').last;
        final header = '// ==MiruExtension==\n'
            '// @name         ${widget.name}\n'
            '// @version      ${widget.version}\n'
            '// @author       jephersonRD\n'
            '// @lang         ${widget.lang}\n'
            '// @license      ${widget.license ?? "MIT"}\n'
            '// @icon         ${widget.icon ?? ""}\n'
            '// @package      ${widget.package}\n'
            '// @type         $typeName\n'
            '// @webSite      ${widget.webSite ?? ""}\n'
            '// @description  ${widget.description ?? widget.name}\n'
            '// ==/MiruExtension==\n\n';
        script = header + script;
      }
      await ExtensionUtils.installByScript(script, context);
      isLoading = false;
      isInstall = true;
      hasUpgrade = false;
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 35,
        height: 35,
        child: CacheNetWorkImagePic(
          icon,
          fit: BoxFit.contain,
          fallback: const Icon(Icons.extension),
        ),
      ),
      title: Text(widget.name),
      subtitle: DefaultTextStyle(
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(widget.version),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(ExtensionUtils.typeToString(widget.type)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(widget.lang),
              ),
              if (widget.nsfw)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    '18+',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          )),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 25,
              height: 25,
              child: ProgressRing(),
            )
          else if (isInstall) ...[
            if (hasUpgrade)
              FilledButton(
                child: Text('extension-repo.upgrade'.i18n),
                onPressed: () async {
                  await _install();
                  setState(() {});
                },
              ),
            const SizedBox(width: 8),
            if (isInstall)
              TextButton(
                child: Text('common.uninstall'.i18n),
                onPressed: () async {
                  await ExtensionUtils.uninstall(widget.package);
                  setState(() {
                    isInstall = false;
                  });
                },
              )
          ] else
            TextButton(
              onPressed: () async {
                await _install();
              },
              child: Text('common.install'.i18n),
            )
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: CacheNetWorkImagePic(
              icon,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              fallback: const Icon(fluent.FluentIcons.add_in, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.name, style: const TextStyle(fontSize: 17)),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 12,
              color: fluent.FluentTheme.of(context).inactiveColor,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(ExtensionUtils.typeToString(widget.type)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(widget.lang),
                ),
                if (widget.nsfw)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      '18+',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  widget.version,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 25,
                  height: 25,
                  child: ProgressRing(),
                )
              else if (isInstall) ...[
                if (hasUpgrade)
                  fluent.FilledButton(
                    child: Text('extension-repo.upgrade'.i18n),
                    onPressed: () async {
                      await _install();
                      setState(() {});
                    },
                  ),
                const SizedBox(width: 8),
                if (isInstall)
                  fluent.FilledButton(
                    child: Text('common.uninstall'.i18n),
                    onPressed: () async {
                      await ExtensionUtils.uninstall(widget.package);
                      setState(() {
                        isInstall = false;
                      });
                    },
                  )
              ] else
                fluent.FilledButton(
                  onPressed: () async {
                    await _install();
                  },
                  child: Text('common.install'.i18n),
                )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}

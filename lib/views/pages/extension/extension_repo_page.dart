import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiruhub/models/extension.dart';
import 'package:jiruhub/controllers/extension/extension_repo_controller.dart';
import 'package:jiruhub/views/widgets/extension/extension_card.dart';
import 'package:jiruhub/utils/i18n.dart';
import 'package:jiruhub/views/widgets/button.dart';
import 'package:jiruhub/views/widgets/platform_widget.dart';
import 'package:jiruhub/views/widgets/progress.dart';
import 'package:jiruhub/views/widgets/search_appbar.dart';

class ExtensionRepoPage extends StatefulWidget {
  const ExtensionRepoPage({super.key});

  @override
  State<ExtensionRepoPage> createState() => _ExtensionRepoPageState();
}

class _ExtensionRepoPageState extends State<ExtensionRepoPage> {
  late ExtensionRepoPageController c;

  @override
  void initState() {
    c = Get.put(ExtensionRepoPageController());
    super.initState();
  }

  // 筛选 dialog
  _filterDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => SegmentedButton<ExtensionType?>(
                    segments: [
                      ButtonSegment(
                        value: null,
                        label: Text('common.show-all'.i18n),
                      ),
                      ButtonSegment(
                        value: ExtensionType.bangumi,
                        label: Text('extension-type.video'.i18n),
                      ),
                      ButtonSegment(
                        value: ExtensionType.manga,
                        label: Text('extension-type.comic'.i18n),
                      ),
                      ButtonSegment(
                        value: ExtensionType.fikushon,
                        label: Text('extension-type.novel'.i18n),
                      ),
                    ],
                    selected: <ExtensionType?>{c.searchType.value},
                    onSelectionChanged: (value) {
                      debugPrint(value.first.toString());
                      c.searchType.value = value.first;
                      Get.back();
                    },
                    showSelectedIcon: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _content() {
    if (c.isLoading.value) {
      return const Center(child: ProgressRing());
    }
    if (c.isError.value) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('extension-repo.error'.i18n),
          const SizedBox(height: 8),
          fluent.Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'extension-repo.error-tips'.i18n,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 13),
          PlatformFilledButton(
            child: Text('common.retry'.i18n),
            onPressed: () {
              c.onRefresh();
            },
          )
        ],
      ));
    }

    final extensionCards = c.extensions
        .where((e) =>
            e['package'] != null &&
            e['name'] != null &&
            e['version'] != null &&
            e['lang'] != null)
        .map((e) {
          final type = ExtensionType.values.firstWhere(
            (element) => element.toString() == 'ExtensionType.${e['type']}',
            orElse: () => ExtensionType.bangumi,
          );
          return ExtensionCard(
              key: ValueKey(e['package']),
              name: e['name'] ?? '',
              icon: e['icon'],
              version: e['version'] ?? '',
              package: e['package'] ?? '',
              lang: e['lang'] ?? 'all',
              url: e['url'],
              webSite: e['webSite'],
              license: e['license'],
              description: e['description'],
              nsfw: e['nsfw'] == 'true' || e['nsfw'] == true,
              type: type);
        })
        .toList();
    // 过滤
    if (c.search.value.isNotEmpty) {
      extensionCards.removeWhere((element) =>
          !element.name.toLowerCase().contains(c.search.value.toLowerCase()));
    }
    if (c.searchType.value != null) {
      extensionCards.removeWhere(
        (element) => element.type != c.searchType.value,
      );
    }
    if (c.searchLang.value != 'all') {
      extensionCards.removeWhere(
        (element) => element.lang != c.searchLang.value,
      );
    }

    if (extensionCards.isEmpty) {
      return Center(child: Text('extension-repo.empty'.i18n));
    }

    return PlatformBuildWidget(
      androidBuilder: (context) => ListView(
        children: extensionCards,
      ),
      desktopBuilder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth ~/ 220).clamp(1, 10);
          return GridView.count(
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: extensionCards,
          );
        },
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: SearchAppBar(
          title: 'common.extension-repo'.i18n,
          textEditingController: TextEditingController(text: c.search.value),
          onSubmitted: (value) {
            c.search.value = value;
          },
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _filterDialog();
              },
            ),
          ],
        ),
        body: EasyRefresh(
          onRefresh: c.onRefresh,
          header: const ClassicHeader(
            showText: false,
            showMessage: false,
          ),
          child: Obx(_content),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'common.extension-repo'.i18n,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Obx(
                () => fluent.ComboBox<String>(
                  items: [
                    fluent.ComboBoxItem(value: 'all', child: Text('common.show-all'.i18n)),
                    fluent.ComboBoxItem(value: 'en', child: const Text('English')),
                    fluent.ComboBoxItem(value: 'es', child: const Text('Español')),
                    fluent.ComboBoxItem(value: 'zh', child: const Text('中文')),
                    fluent.ComboBoxItem(value: 'ja', child: const Text('日本語')),
                    fluent.ComboBoxItem(value: 'ko', child: const Text('한국어')),
                    fluent.ComboBoxItem(value: 'hi', child: const Text('हिन्दी')),
                    fluent.ComboBoxItem(value: 'ru', child: const Text('Русский')),
                  ],
                  value: c.searchLang.value,
                  onChanged: (value) {
                    c.searchLang.value = value ?? 'all';
                  },
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                () => fluent.ComboBox<String>(
                  items: [
                    fluent.ComboBoxItem(
                      value: "all",
                      child: Text('common.show-all'.i18n),
                    ),
                    fluent.ComboBoxItem(
                      value: ExtensionType.bangumi.toString(),
                      child: Text('extension-type.video'.i18n),
                    ),
                    fluent.ComboBoxItem(
                      value: ExtensionType.manga.toString(),
                      child: Text('extension-type.comic'.i18n),
                    ),
                    fluent.ComboBoxItem(
                      value: ExtensionType.fikushon.toString(),
                      child: Text('extension-type.novel'.i18n),
                    ),
                  ],
                  value: c.searchType.value?.toString() ?? "all",
                  onChanged: (value) {
                    if (value == "all") {
                      c.searchType.value = null;
                      return;
                    }
                    c.searchType.value = ExtensionType.values.firstWhere(
                      (element) => element.toString() == value,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: Obx(
                  () => fluent.TextBox(
                    controller: TextEditingController(text: c.search.value),
                    placeholder: 'common.search'.i18n,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        c.onRefresh();
                        c.search.value = '';
                      }
                    },
                    onSubmitted: (value) {
                      c.search.value = value;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              fluent.IconButton(
                icon: const Icon(fluent.FluentIcons.refresh),
                onPressed: () {
                  c.onRefresh();
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(_content),
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

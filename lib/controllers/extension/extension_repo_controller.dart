import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:jiruhub/models/index.dart';
import 'package:jiruhub/utils/jiruhub_storage.dart';
import 'package:jiruhub/utils/request.dart';

class ExtensionRepoPageController extends GetxController {
  List<dynamic> extensions = <dynamic>[].obs;
  List<dynamic> extensionsTemp = <dynamic>[];

  final isLoading = false.obs;
  final isError = false.obs;
  final search = ''.obs;
  final Rx<ExtensionType?> searchType = Rx(null);
  final RxString searchLang = 'all'.obs;

  static const List<String> availableLangs = [
    'all', 'en', 'es', 'zh', 'ja', 'ko', 'hi', 'ru', 'ar', 'id', 'vi', 'tr', 'th', 'it'
  ];

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    isLoading.value = true;
    isError.value = false;

    try {
      final url = '${JiruHubStorage.getSetting(SettingKey.jiruhubRepoUrl)}/index.json';
      debugPrint('🔍 Extension repo URL: $url');
      final res = await dio.get<String>(url);
      extensions = jsonDecode(res.data!);
      if (!JiruHubStorage.getSetting(SettingKey.enableNSFW)) {
        extensions.removeWhere((element) => element['nsfw'] == "true");
      }
      extensionsTemp.clear();
      extensionsTemp.addAll(extensions);
    } catch (e) {
      isError.value = true;
      debugPrint('❌ Extension repo error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

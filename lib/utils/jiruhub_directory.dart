import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class JiruHubDirectory {
  static late final Directory _appDocDir;
  static late final Directory _cacheDir;

  static ensureInitialized() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _cacheDir = await getTemporaryDirectory();
  }

  static String get getDirectory => _jiruhubDir(_appDocDir);

  static String get getCacheDirectory => _jiruhubDir(_cacheDir);

  static String _jiruhubDir(Directory directory) {
    final dir = path.join(directory.path, 'jiruhub');
    Directory(dir).createSync(recursive: true);
    return dir;
  }
}

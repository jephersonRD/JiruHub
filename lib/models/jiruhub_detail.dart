import 'package:isar/isar.dart';

part 'jiruhub_detail.g.dart';

@collection
class JiruHubDetail {
  Id id = Isar.autoIncrement;
  @Index(name: 'package&url', composite: [CompositeIndex('url')])
  late String package;
  late String url;
  late String data;
  int? tmdbID;
  DateTime updateTime = DateTime.now();
  String? aniListID;
}

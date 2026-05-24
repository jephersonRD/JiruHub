import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiruhub/models/index.dart';
import 'package:jiruhub/views/pages/favorites_page.dart';
import 'package:jiruhub/router/router.dart';
import 'package:jiruhub/utils/extension.dart';
import 'package:jiruhub/views/widgets/extension_item_card.dart';
import 'package:jiruhub/views/widgets/horizontal_list.dart';

class HomeFavorites extends StatefulWidget {
  const HomeFavorites({
    super.key,
    required this.type,
    required this.data,
  });
  final ExtensionType type;
  final List<Favorite> data;

  @override
  State<HomeFavorites> createState() => _HomeFavoritesState();
}

class _HomeFavoritesState extends State<HomeFavorites> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      child: HorizontalList(
        title: ExtensionUtils.typeToString(widget.type),
        onClickMore: () {
          if (Platform.isAndroid) {
            Get.to(FavoritesPage(type: widget.type));
          } else {
            router.push(
              Uri(
                path: '/favorites',
                queryParameters: {'type': widget.type.index.toString()},
              ).toString(),
            );
          }
        },
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          return ExtensionItemCard(
            key: ValueKey(widget.data[index].cover),
            title: widget.data[index].title,
            url: widget.data[index].url,
            package: widget.data[index].package,
            cover: widget.data[index].cover,
          );
        },
      ),
    );
  }
}

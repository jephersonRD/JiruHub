// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:dio/dio.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:jiruhub/data/providers/anilist_provider.dart';
import 'package:jiruhub/data/providers/bt_server_provider.dart';
import 'package:jiruhub/models/index.dart';
import 'package:jiruhub/utils/log.dart';
import 'package:jiruhub/utils/request.dart';
import 'package:jiruhub/utils/router.dart';
import 'package:jiruhub/views/dialogs/bt_dialog.dart';
import 'package:jiruhub/controllers/home_controller.dart';
import 'package:jiruhub/controllers/main_controller.dart';
import 'package:jiruhub/router/router.dart';
import 'package:jiruhub/utils/bt_server.dart';
import 'package:jiruhub/data/services/database_service.dart';
import 'package:jiruhub/data/services/extension_service.dart';
import 'package:jiruhub/utils/i18n.dart';
import 'package:jiruhub/utils/layout.dart';
import 'package:jiruhub/utils/jiruhub_directory.dart';
import 'package:jiruhub/views/pages/watch/video/video_player_sidebar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:crypto/crypto.dart';
import 'package:jiruhub/utils/jiruhub_storage.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';

class VideoPlayerController extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionService runtime;
  final String anilistID;

  VideoPlayerController({
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playIndex,
    required this.episodeGroupId,
    required this.runtime,
    required this.anilistID,
  });

  // 播放器
  final player = Player();
  late final videoController = VideoController(player);

  final showSidebar = false.obs;
  final isOpenSidebar = false.obs;
  final isFullScreen = false.obs;
  late final index = playIndex.obs;

  // 快捷键
  late final keyboardShortcuts = <KeyboardKey, VoidCallback>{
    LogicalKeyboardKey.escape: () {
      if (isFullScreen.value) {
        WindowManager.instance.setFullScreen(false);
      }
      RouterUtils.pop();
    },
    LogicalKeyboardKey.keyF: () => toggleFullscreen(),
    LogicalKeyboardKey.mediaPlay: () => player.play(),
    LogicalKeyboardKey.mediaPause: () => player.pause(),
    LogicalKeyboardKey.mediaPlayPause: () => player.playOrPause(),
    LogicalKeyboardKey.mediaTrackNext: () => player.next(),
    LogicalKeyboardKey.mediaTrackPrevious: () => player.previous(),
    LogicalKeyboardKey.space: () => player.playOrPause(),
    LogicalKeyboardKey.keyJ: () {
      final rate = player.state.position +
          Duration(
            milliseconds:
                (JiruHubStorage.getSetting(SettingKey.keyJ) * 1000).toInt(),
          );
      player.seek(rate);
    },
    LogicalKeyboardKey.keyI: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (JiruHubStorage.getSetting(SettingKey.keyI) * 1000).toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowLeft: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (JiruHubStorage.getSetting(SettingKey.arrowLeft) * 1000)
                      .toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowRight: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (JiruHubStorage.getSetting(SettingKey.arrowRight) * 1000)
                      .toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowUp: () {
      final volume = player.state.volume + 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
    LogicalKeyboardKey.arrowDown: () {
      final volume = player.state.volume - 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
  };

  // 字幕
  final subtitles = <SubtitleTrack>[].obs;

  // 画质
  final currentQuality = "".obs;
  final qualityMap = <String, String>{};

  // 是否已经自动跳转到上次播放进度
  bool _isAutoSeekPosition = false;

  // 信息列队
  final messageQueue = <Message>[];
  final Rx<Widget?> cuurentMessageWidget = Rx(null);

  // 播放速度
  final currentSpeed = 1.0.obs;
  final speedList = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];

  // torrent 媒体文件
  final torrentMediaFileList = <String>[].obs;
  final currentTorrentFile = ''.obs;
  String _torrenHash = "";

  // 调用 watch 方法获取到的数据
  ExtensionBangumiWatch? watchData;
  final error = "".obs;
  final isGettingWatchData = true.obs;

  // Selector de servidores (llenado desde X-Servers header de la extensión)
  final availableServers = <String, String>{}.obs; // nombre → embed URL
  final serverReferers = <String, String>{}; // nombre → referer (no observable)
  final currentServerName = ''.obs;
  final serverFailedMessage = ''.obs;


  // 字幕配置
  final subtitleFontSize = 46.0.obs;
  final subtitleFontWeight = FontWeight.normal.obs;
  final subtitleTextAlign = TextAlign.center.obs;
  final subtitleFontColor = Colors.white.obs;
  final subtitleBackgroundColor = Colors.black.obs;
  final subtitleBackgroundOpacity = 0.5.obs;

  // 侧边栏初始化 tab
  final initSidebarTab = SidebarTab.episodes.obs;

  // 播放方式
  final playMode = PlaylistMode.none.obs;

  // 进度
  final position = Duration.zero.obs;

  // 总时长
  final duration = Duration.zero.obs;

  // 播放状态
  final isPlaying = false.obs;

  // dlna 设备
  final dlnaDevice = Rx<DLNADevice?>(null);

  // 定时器
  Timer? _dlnaTimer;

  @override
  void onInit() async {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await AutoOrientation.landscapeAutoMode(forceSensor: true);
    }
    _initSettings();
    _initPlayer();
    // Configurar libmpv para evitar crashes en Linux:
    // - hwdec=no: evita error vaapi not supported by libswscale
    // - reconnect=0: evita SIGSEGV ~16s post-EHOSTUNREACH cuando
    //   libmpv intenta reconectar HLS y falla en la limpieza interna
    // - network-timeout=5: fallo rápido
    if (player.platform is NativePlayer) {
      final np = player.platform as NativePlayer;
      await np.setProperty('hwdec', 'no');
      await np.setProperty('network-timeout', '5');
      await np.setProperty(
          'demuxer-lavf-o', 'reconnect=0,reconnect_delay_max=0');
    }
    play();

    super.onInit();
  }

  _initSettings() {
    subtitleFontSize.value =
        JiruHubStorage.getSetting(SettingKey.subtitleFontSize);
    subtitleFontColor.value = Color(
      JiruHubStorage.getSetting(
        SettingKey.subtitleFontColor,
      ),
    );
    final fontWeightText =
        JiruHubStorage.getSetting(SettingKey.subtitleFontWeight);
    subtitleFontWeight.value =
        fontWeightText == 'bold' ? FontWeight.bold : FontWeight.normal;
    subtitleBackgroundColor.value = Color(JiruHubStorage.getSetting(
      SettingKey.subtitleBackgroundColor,
    ));
    subtitleBackgroundOpacity.value = JiruHubStorage.getSetting(
      SettingKey.subtitleBackgroundOpacity,
    );
    subtitleTextAlign.value = TextAlign.values[JiruHubStorage.getSetting(
      SettingKey.subtitleTextAlign,
    )];

    ever(subtitleFontSize, (callback) {
      JiruHubStorage.setSetting(SettingKey.subtitleFontSize, callback);
    });
    ever(subtitleFontColor, (callback) {
      JiruHubStorage.setSetting(
        SettingKey.subtitleFontColor,
        callback.value,
      );
    });
    ever(subtitleFontWeight, (callback) {
      JiruHubStorage.setSetting(
        SettingKey.subtitleFontWeight,
        callback == FontWeight.bold ? 'bold' : 'normal',
      );
    });
    ever(subtitleBackgroundColor, (callback) {
      JiruHubStorage.setSetting(
        SettingKey.subtitleBackgroundColor,
        callback.value,
      );
    });
    ever(subtitleBackgroundOpacity, (callback) {
      JiruHubStorage.setSetting(
        SettingKey.subtitleBackgroundOpacity,
        callback,
      );
    });
    ever(subtitleTextAlign, (callback) {
      JiruHubStorage.setSetting(
        SettingKey.subtitleTextAlign,
        callback.index,
      );
    });
  }

  _initPlayer() {
    // 切换剧集
    ever(index, (callback) {
      play();
    });

    // 切换倍速
    ever(currentSpeed, (callback) {
      player.setRate(callback);
    });

    // 显示剧集列表
    ever(showSidebar, (callback) {
      if (!showSidebar.value) {
        isOpenSidebar.value = false;
      }
    });

    // 自动切换下一集
    player.stream.completed.listen((event) {
      if (!event || playMode.value == PlaylistMode.single) {
        return;
      }
      if (playMode.value == PlaylistMode.loop) {
        player.seek(Duration.zero);
        player.play();
        return;
      }

      if (index.value == playList.length - 1) {
        sendMessage(Message(Text('video.play-complete'.i18n)));
        return;
      }
      if (!player.state.buffering) {
        index.value++;
      }
    });

    // 讀取現在的畫質
    player.stream.height.listen((event) async {
      if (player.state.width != null) {
        final width = player.state.width;
        currentQuality.value = "${width}x$event";
      }
    });

    // 自动恢复上次播放进度
    player.stream.duration.listen((event) async {
      if (_isAutoSeekPosition || event.inSeconds == 0) {
        return;
      }

      // 获取上次播放进度
      final history = await DatabaseService.getHistoryByPackageAndUrl(
        runtime.extension.package,
        detailUrl,
      );

      if (history != null &&
          history.progress.isNotEmpty &&
          history.episodeId == index.value &&
          history.episodeGroupId == episodeGroupId) {
        _isAutoSeekPosition = true;
        player.seek(Duration(seconds: int.parse(history.progress)));
        sendMessage(Message(Text('video.resume-last-playback'.i18n)));
      }
    });

    // 监听 track
    player.stream.tracks.listen((event) {
      if (event.subtitle.isEmpty) {
        return;
      }

      final latestLanguageSelected = JiruHubStorage.getSetting(
        SettingKey.subtitleLastLanguageSelected,
      );
      final latestTitleSelected = JiruHubStorage.getSetting(
        SettingKey.subtitleLastTitleSelected,
      );
      if (latestLanguageSelected == null && latestTitleSelected == null) {
        return;
      }

      final subtitle = [...event.subtitle, ...subtitles].firstWhereOrNull(
        (element) {
          if (element.id == "no" || element.id == "auto") {
            return false;
          }
          return element.language == latestLanguageSelected ||
              element.title == latestTitleSelected;
        },
      );

      if (subtitle != null) {
        player.setSubtitleTrack(subtitle);
      }
    });

    // 总时长监听
    player.stream.duration.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      duration.value = event;
    });

    // 监听播放状态
    player.stream.playing.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      isPlaying.value = event;
    });

    // 监听进度
    player.stream.position.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      position.value = event;
    });

    // 错误监听 — detectar fallo de reproducción
    player.stream.error.listen((event) {
      logger.severe('media_kit error: $event');
      sendMessage(Message(Text(event)));
      // Si el error indica que el stream no es accesible, notificar
      if (event.toLowerCase().contains('not found') ||
          event.toLowerCase().contains('403') ||
          event.toLowerCase().contains('500') ||
          event.toLowerCase().contains('no such') ||
          event.toLowerCase().contains('failed')) {
        if (serverFailedMessage.value.isEmpty) {
          if (availableServers.length > 1) {
            serverFailedMessage.value =
                'Servidor "${currentServerName.value}" no disponible.\n'
                'Cambia de servidor con el botón Servidor.';
          } else {
            serverFailedMessage.value = 'Error de reproducción. Intenta más tarde.';
          }
        }
      }
    });
  }

  // 播放
  play() async {
    // 如果已经 delete 当前 controller
    if (!Get.isRegistered<VideoPlayerController>(tag: title)) {
      return;
    }
    player.stop();
    isGettingWatchData.value = true;
    try {
      await getWatchData();
    } catch (e) {
      logger.severe(e);
      error.value = e.toString();
      return;
    }

    try {
      if (watchData!.type == ExtensionWatchBangumiType.torrent) {
        try {
          await getTorrentMediaFile();
        } catch (e) {
          logger.severe(e);
          error.value = e.toString();
          return;
        }

        playTorrentFile(torrentMediaFileList.first);
      } else {
        if (dlnaDevice.value != null) {
          await dlnaDevice.value!.setUrl(watchData!.url);
          await dlnaDevice.value!.play();
        } else {
          final primaryUrl = watchData!.url;
          unawaited(getQuality());

          logger.info('Intentando servidor primario: ${currentServerName.value} → $primaryUrl');
          bool worked = await _tryOpenPlayer(primaryUrl, watchData!.headers);

          if (!worked && watchData!.headers != null && watchData!.headers!.containsKey('X-Netu-Alts')) {
            try {
              final List<dynamic> alts = jsonDecode(watchData!.headers!['X-Netu-Alts']!);
              for (final altUrlDyn in alts) {
                final altUrl = altUrlDyn.toString();
                logger.info('Intentando URL alternativa: $altUrl');
                worked = await _tryOpenPlayer(altUrl, watchData!.headers);
                if (worked) {
                  watchData = ExtensionBangumiWatch(
                    type: watchData!.type,
                    url: altUrl,
                    subtitles: watchData!.subtitles,
                    headers: watchData!.headers,
                    audioTrack: watchData!.audioTrack,
                  );
                  break;
                }
              }
            } catch (e) {
              logger.warning('Error parseando X-Netu-Alts: $e');
            }
          }

          if (!worked) {
            logger.severe('Servidor primario fallido: ${currentServerName.value}');
            // Auto-failover: iterar servidores alternativos
            bool foundWorking = false;
            final serverEntries = availableServers.entries.toList();
            final serverErrors = <String, String>{}; // Para registrar errores por servidor
            logger.info('Servidores disponibles para failover: ${serverEntries.map((e) => e.key).toList()}');
            for (final entry in serverEntries) {
              if (entry.key == currentServerName.value) continue;
              try {
                logger.info('Failover → probando servidor: ${entry.key}');
                serverFailedMessage.value =
                    'Servidor "${currentServerName.value}" no disponible, '
                    'probando "${entry.key}"...';
                var alt = await runtime.watch(entry.value)
                    as ExtensionBangumiWatch;
                logger.info('Failover ${entry.key} URL: ${alt.url}');
                if (alt.url.startsWith('error://')) {
                  final errorMsg = alt.url.replaceFirst('error://', '');
                  logger.severe('Failover ${entry.key}: error de extracción ($errorMsg)');
                  serverErrors[entry.key] = errorMsg;
                  continue;
                }
                
                bool altWorked = await _tryOpenPlayer(alt.url, alt.headers);
                
                if (!altWorked && alt.headers != null && alt.headers!.containsKey('X-Netu-Alts')) {
                  try {
                    final List<dynamic> alts = jsonDecode(alt.headers!['X-Netu-Alts']!);
                    for (final altUrlDyn in alts) {
                      final altUrlStr = altUrlDyn.toString();
                      logger.info('Failover probando alternativa: $altUrlStr');
                      altWorked = await _tryOpenPlayer(altUrlStr, alt.headers);
                      if (altWorked) {
                        alt = ExtensionBangumiWatch(
                          type: alt.type,
                          url: altUrlStr,
                          subtitles: alt.subtitles,
                          headers: alt.headers,
                          audioTrack: alt.audioTrack,
                        );
                        break;
                      }
                    }
                  } catch (e) {
                    logger.warning('Error parseando X-Netu-Alts en failover: $e');
                  }
                }

                if (!altWorked) {
                  logger.severe('Failover ${entry.key}: no se pudo conectar a ningún host');
                  continue;
                }
                
                // Servidor alternativo alcanzable — usarlo
                currentServerName.value = entry.key;
                watchData = alt;
                serverFailedMessage.value = '';
                logger.info('Failover exitoso: ${entry.key}');
                foundWorking = true;
                break;
              } catch (e, stackTrace) {
                logger.severe('Failover ${entry.key} excepción: $e');
                logger.severe('Stack trace: $stackTrace');
              }
            }
            if (!foundWorking) {
              final errorDetails = serverErrors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
              logger.severe('Todos los servidores fallaron. Errores: $errorDetails');
              serverFailedMessage.value =
                  'Ningún servidor disponible desde tu red.\n'
                  'Errores: $errorDetails\n'
                  'Prueba con una VPN o elige otro episodio.';
              logger.severe('Todos los servidores fallaron, iniciando _safePlayerInit');
              await _safePlayerInit();
              isGettingWatchData.value = false;
              return;
            }
          }
          if (watchData!.audioTrack != null) {
            await player.setAudioTrack(
              AudioTrack.uri(watchData!.audioTrack!),
            );
          }
        }

      }
      isGettingWatchData.value = false;
      // 添加来自扩展的字幕
      subtitles.addAll(
        (watchData!.subtitles ?? []).map(
          (e) => SubtitleTrack.uri(
            e.url,
            language: e.language,
            title: e.title,
          ),
        ),
      );
      player.setSubtitleTrack(SubtitleTrack.no());
    } on StartServerException catch (_) {
      // 如果是 启动 bt server 失败
      if (Platform.isAndroid) {
        await showDialog(
          context: currentContext,
          builder: (context) => const BTDialog(),
        );
      } else {
        await fluent.showDialog(
          context: currentContext,
          builder: (context) => const BTDialog(),
        );
      }

      // 延时 3 秒再重试
      await Future.delayed(const Duration(seconds: 3));
      play();
      return;
    } catch (e) {
      sendMessage(
        Message(
          Text(e.toString()),
          time: const Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  // 获取 watch 数据
  getWatchData() async {
    watchData = null;
    subtitles.clear();
    availableServers.clear();
    serverReferers.clear();
    serverFailedMessage.value = '';
    final playUrl = playList[index.value].url;
    watchData = await runtime.watch(playUrl) as ExtensionBangumiWatch;

    final headers = watchData!.headers;
    if (headers != null) {
      // Parsear lista de servidores (embed URLs crudos)
      if (headers.containsKey('X-Servers')) {
        try {
          final Map<String, dynamic> parsed = jsonDecode(headers['X-Servers']!);
          availableServers.value =
              parsed.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {}
      }
      // Parsear referers por servidor
      if (headers.containsKey('X-Server-Referers')) {
        try {
          final Map<String, dynamic> parsed =
              jsonDecode(headers['X-Server-Referers']!);
          serverReferers.addAll(
              parsed.map((k, v) => MapEntry(k, v.toString())));
        } catch (_) {}
      }
      // Servidor actual
      currentServerName.value = headers['X-Primary-Server'] ??
          (availableServers.isNotEmpty ? availableServers.keys.first : '');
      // Limpiar cabeceras especiales — no enviar al player
      watchData!.headers = Map.from(headers)
        ..remove('X-Servers')
        ..remove('X-Server-Referers')
        ..remove('X-Primary-Server');
    }
  }

  // Cambia al servidor — extrae su stream URL on-demand llamando watch(embedUrl)
  switchServer(String name) async {
    if (!availableServers.containsKey(name)) return;
    serverFailedMessage.value = '';
    isGettingWatchData.value = true;

    final embedUrl = availableServers[name]!;
    ExtensionBangumiWatch newWatch;
    try {
      // Mode 2: la extensión detecta que es un embed URL y extrae directamente
      newWatch = await runtime.watch(embedUrl) as ExtensionBangumiWatch;
    } catch (e) {
      logger.severe(e);
      serverFailedMessage.value =
          'No se pudo extraer el servidor "$name". Intenta otro.';
      isGettingWatchData.value = false;
      return;
    }

    if (newWatch.url.startsWith('error://')) {
      serverFailedMessage.value =
          'Servidor "$name" no disponible. Intenta otro.';
      isGettingWatchData.value = false;
      return;
    }

    currentServerName.value = name;
    // Si la extensión no devolvió Referer, intentar del mapa local
    final headers = <String, String>{};
    final referer = newWatch.headers?['Referer'] ?? serverReferers[name];
    if (referer != null) headers['Referer'] = referer;

    watchData = ExtensionBangumiWatch(
      type: watchData!.type,
      url: newWatch.url,
      headers: headers.isEmpty ? null : headers,
    );
    _isAutoSeekPosition = true;
    isGettingWatchData.value = false;
    await player.open(
      Media(newWatch.url, httpHeaders: watchData!.headers),
    );
  }

  // 获取 torrent 媒体文件
  getTorrentMediaFile() async {
    if (Get.find<MainController>().btServerisRunning.value == false) {
      await BTServerUtils.startServer();
    }
    sendMessage(
      Message(
        Text('video.torrent-downloading'.i18n),
      ),
    );
    // 下载 torrent
    final torrentFile = path.join(
      JiruHubDirectory.getCacheDirectory,
      'temp.torrent',
    );
    await dio.download(watchData!.url, torrentFile);

    final file = File(torrentFile);
    _torrenHash = await BTServerApi.addTorrent(file.readAsBytesSync());
    final files = await BTServerApi.getFileList(_torrenHash);

    torrentMediaFileList.clear();

    for (final file in files) {
      if (_isSubtitle(file)) {
        subtitles.add(
          SubtitleTrack.uri(
            '${BTServerApi.baseApi}/torrent/$_torrenHash/$file',
            title: path.basename(file),
          ),
        );
      } else {
        torrentMediaFileList.add(file);
      }
    }
  }

  // 获取画质
  getQuality() async {
    final url = watchData!.url;
    final headers = watchData!.headers;
    logger.info(url);

    late dynamic response;
    try {
      response = await dio.get(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Red no alcanzable — notificar al usuario
        logger.severe(e);
        if (availableServers.length > 1) {
          serverFailedMessage.value =
              'Servidor "${currentServerName.value}" no disponible.\n'
              'Cambia de servidor con el botón Servidor para ver el anime.';
        } else {
          serverFailedMessage.value =
              'Servidor no disponible. Intenta más tarde.';
        }
      } else {
        // HTTP 4xx/5xx: puede que libmpv lo reproduzca igual (Range headers)
        logger.info('getQuality HTTP error ${e.response?.statusCode}, continuing');
      }
      return;
    } catch (e) {
      logger.severe(e);
      return;
    }

    // 请求判断 content-type 是否为 m3u8
    final contentType = response.headers.value('content-type')?.toLowerCase();
    if (contentType == null ||
        !contentType.contains('mpegurl') &&
            !contentType.contains('m3u8') &&
            !contentType.contains('mp2t')) {
      logger.info('not m3u8');
      return;
    }

    // 接收数据到变量
    final completer = Completer<String>();
    final stream = response.data.stream;
    final buffer = StringBuffer();

    stream.listen(
      (data) {
        buffer.write(utf8.decode(data));
      },
      onDone: () {
        completer.complete(buffer.toString());
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    final m3u8Content = await completer.future;
    if (m3u8Content.isEmpty) {
      return;
    }

    late HlsPlaylist playlist;
    try {
      playlist = await HlsPlaylistParser.create().parseString(
        response.realUri,
        m3u8Content,
      );
    } on ParserException catch (e) {
      logger.severe(e);
      return;
    }

    if (playlist is HlsMasterPlaylist) {
      final urlList = playlist.mediaPlaylistUrls
          .map(
            (e) => e.toString(),
          )
          .toList();
      final resolution = playlist.variants.map(
        (it) => "${it.format.width}x${it.format.height}",
      );
      qualityMap.addAll(
        Map.fromIterables(
          resolution,
          urlList,
        ),
      );
    }
  }

  // 播放 torrent 媒体文件
  playTorrentFile(String file) {
    currentTorrentFile.value = file;
    (player.platform as NativePlayer).setProperty("network-timeout", "60");
    player.open(Media('${BTServerApi.baseApi}/torrent/$_torrenHash/$file'));
  }

  // 切换全屏
  toggleFullscreen() async {
    await WindowManager.instance.setFullScreen(!isFullScreen.value);
    isFullScreen.value = !isFullScreen.value;
  }

  // 切换画质
  switchQuality(String qualityUrl) async {
    final currentSecond = player.state.position.inSeconds;
    final headers = watchData!.headers;
    await player.open(
      Media(qualityUrl, httpHeaders: headers),
    );
    //跳轉到切換之前的時間
    Timer.periodic(const Duration(seconds: 1), (timer) {
      player.seek(Duration(seconds: currentSecond));
      if (player.state.position.inSeconds == currentSecond) {
        timer.cancel();
      }
    });
  }

  // 设置字幕
  setSubtitleTrack(SubtitleTrack subtitle) {
    player.setSubtitleTrack(subtitle);
    JiruHubStorage.setSetting(
      SettingKey.subtitleLastLanguageSelected,
      subtitle.language,
    );
    JiruHubStorage.setSetting(
      SettingKey.subtitleLastTitleSelected,
      subtitle.title,
    );
  }

  // 保存历史记录
  _saveHistory() async {
    if (duration.value.inSeconds == 0) {
      return;
    }

    final tempDir = JiruHubDirectory.getCacheDirectory;
    final coverDir = path.join(tempDir, 'history_cover');
    Directory(coverDir).createSync(recursive: true);
    final epName = playList[index.value].name;
    final filename = '${title}_$epName';
    final file = File(
        path.join(coverDir, md5.convert(utf8.encode(filename)).toString()));
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }

    final data = await player.screenshot();
    if (data == null) {
      return;
    }
    await file.writeAsBytes(data);

    logger.info('save history');

    await DatabaseService.putHistory(
      History()
        ..url = detailUrl
        ..cover = file.path
        ..episodeGroupId = episodeGroupId
        ..package = runtime.extension.package
        ..type = runtime.extension.type
        ..episodeId = index.value
        ..episodeTitle = epName
        ..title = title
        ..progress = player.state.position.inSeconds.toString()
        ..totalProgress = player.state.duration.inSeconds.toString(),
    );
    await Get.find<HomePageController>().onRefresh();
  }

  // 判断文件是否是字幕
  _isSubtitle(String file) {
    return file.endsWith('.srt') ||
        file.endsWith('.vtt') ||
        file.endsWith(".ass");
  }

  // 发送消息
  sendMessage(Message message) {
    messageQueue.add(message);

    if (messageQueue.length == 1) {
      _processNextMessage();
    }
  }

  // 处理消息提示
  _processNextMessage() async {
    if (messageQueue.isEmpty) {
      cuurentMessageWidget.value = null;
      return;
    }

    final message = messageQueue.first;
    cuurentMessageWidget.value = message.child;
    // 等待消息显示完毕
    await Future.delayed(message.time);
    messageQueue.removeAt(0);
    _processNextMessage();
  }

  // 切换侧边栏
  toggleSideBar(SidebarTab tab) {
    if (showSidebar.value) {
      showSidebar.value = false;
      return;
    }
    initSidebarTab.value = tab;
    showSidebar.value = true;
  }

  // 添加本地字幕文件
  addSubtitleFile() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
      allowMultiple: false,
    );
    if (file == null) {
      return;
    }
    final data = File(file.files.first.path!).readAsStringSync();
    subtitles.add(
      SubtitleTrack.data(
        data,
        title: file.files.first.name,
      ),
    );
  }

  // 连接 DLNA 设备
  connectDLNADevice(DLNADevice device) async {
    if (watchData == null) {
      sendMessage(Message(Text('等待视频加载'.i18n)));
      return;
    }
    final url = watchData!.url;
    dlnaDevice.value = device;
    await device.setUrl(url);
    await device.play();
    await player.stop();
    _dlnaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getDLNAStatus();
    });
  }

  // 断开 DLNA 设备
  disconnectDLNADevice() async {
    if (dlnaDevice.value == null) {
      return;
    }
    final device = dlnaDevice.value!;
    dlnaDevice.value = null;
    device.stop();
    _dlnaTimer?.cancel();
  }

  // 获取 DLNA 播放状态
  _getDLNAStatus() async {
    final device = dlnaDevice.value;
    if (device == null) {
      return;
    }
    final transportInfo = await device.getTransportInfo();
    if (transportInfo.contains("PLAYING")) {
      isPlaying.value = true;
    } else {
      isPlaying.value = false;
    }
    final dlnaPosition = await device.position();
    final positionParser = PositionParser(dlnaPosition);
    final absTimeArr = positionParser.AbsTime.split(":");
    final absTime = Duration(
      hours: int.parse(absTimeArr[0]),
      minutes: int.parse(absTimeArr[1]),
      seconds: int.parse(absTimeArr[2]),
    );
    position.value = absTime;
    positionParser.TrackDurationInt;
    duration.value = Duration(seconds: positionParser.TrackDurationInt);
  }

  // Verifica si el host de una URL es alcanzable vía TCP.
  // Dart maneja EHOSTUNREACH (errno 113) limpiamente;
  // libmpv/libavformat tienen un bug que causa SIGSEGV con ese errno.
  Future<bool> _isHostReachable(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasAuthority || uri.host.isEmpty) return true;
      final port = (uri.hasPort && uri.port > 0)
          ? uri.port
          : (uri.scheme == 'https' ? 443 : 80);
      final socket = await Socket.connect(
        uri.host,
        port,
        timeout: const Duration(seconds: 4),
      );
      socket.destroy();
      logger.info('Host alcanzable: ${uri.host}:$port');
      return true;
    } on SocketException catch (e) {
      logger.severe('Host inalcanzable: $url — ${e.message}');
      return false;
    } catch (_) {
      return true; // Error desconocido: dejar que libmpv lo intente
    }
  }

  // Intenta abrir el player con la URL dada.
  // Retorna true si el player fue abierto correctamente.
  // Retorna false si la URL es error:// o el host no es alcanzable.
  Future<bool> _tryOpenPlayer(
      String url, Map<String, String>? headers) async {
    if (url.startsWith('error://')) {
      logger.severe('URL de error recibida: $url');
      return false;
    }
    if (!await _isHostReachable(url)) {
      return false;
    }
    await player.open(Media(url, httpHeaders: headers));
    return true;
  }

  // Inicializa mpv con una fuente local de video negro (sin red).
  // REQUERIDO antes de que el usuario navegue atrás cuando player.open()
  // nunca fue llamado: sin esto, mpv_render_context_free (video_output_dispose)
  // crashea con SIGSEGV porque el pipeline de render nunca procesó frames.
  Future<void> _safePlayerInit() async {
    try {
      // av://lavfi:color genera frames localmente sin red — siempre disponible
      // play:false evita que mpv empiece a reproducir (wakelock=1)
      await player.open(
        Media('av://lavfi:color=black:size=2x2:rate=1'),
        play: false,
      );
      // Esperar a que mpv procese el open antes de stop()
      await Future.delayed(const Duration(milliseconds: 300));
      await player.stop();
      // Esperar a que el stop complete (estado 'idle') antes de retornar
      // Si retornamos muy rápido y el usuario navega atrás, video_output_dispose
      // puede correr mientras el stop aún está en progreso → crash
      await Future.delayed(const Duration(milliseconds: 500));
      logger.info('_safePlayerInit completado');
    } catch (e) {
      logger.severe('_safePlayerInit error: $e');
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await player.stop();
      } catch (_) {}
    }
  }

  // 播放器相关操作
  playOrPause() async {
    if (dlnaDevice.value == null) {
      player.playOrPause();
      return;
    }
    if (isPlaying.value) {
      await dlnaDevice.value!.pause();
    } else {
      await dlnaDevice.value!.play();
    }
  }

  seek(Duration duration) async {
    if (dlnaDevice.value == null) {
      player.seek(duration);
      return;
    }
    final curr = await dlnaDevice.value!.position();
    final diff = duration - position.value;
    await dlnaDevice.value!.seekByCurrent(curr, diff.inSeconds);
  }

  @override
  void onClose() async {
    if (JiruHubStorage.getSetting(SettingKey.autoTracking) && anilistID != "") {
      AniListProvider.editList(
        status: AnilistMediaListStatus.current,
        progress: playIndex + 1,
        mediaId: anilistID,
      );
    }
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      // 如果是平板则不改变
      // 切换回竖屏
      if (!LayoutUtils.isTablet) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
    _dlnaTimer?.cancel();
    try { player.pause(); } catch (_) {}
    try {
      await player.stop();
      // Dar tiempo a libmpv para liquidar su estado antes de dispose
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (_) {}
    try {
      await _saveHistory();
    } catch (_) {}
    try {
      player.dispose();
    } catch (e) {
      logger.severe('player.dispose error: $e');
    }
    logger.info('dispose video controller');
    super.onClose();
  }
}

class Message {
  final Widget child;
  final Duration time;
  Message(this.child, {this.time = const Duration(seconds: 3)});
}

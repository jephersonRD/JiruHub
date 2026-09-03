import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_socks_proxy/socks_proxy.dart';
import 'package:jiruhub/utils/jiruhub_directory.dart';
import 'package:jiruhub/utils/jiruhub_storage.dart';

late final Dio dio;

class MiruRequest {
  static final _cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage("${JiruHubDirectory.getDirectory}/.cookies/"),
  );

  static bool _isInitialized = false;

  static Future<void> ensureInitialized() async {
    _loadSystemCertificates();
    dio = Dio();
    final cookieManager = CookieManager(_cookieJar);
    dio.interceptors.add(cookieManager);
    refreshProxy();
    _isInitialized = true;
  }

  // Dart's BoringSSL solo busca las rutas de CA al estilo Debian, asi que en
  // Fedora/openSUSE/Alpine toda peticion HTTPS muere con
  // CERTIFICATE_VERIFY_FAILED. Le indicamos el bundle de la distro.
  static void _loadSystemCertificates() {
    if (!Platform.isLinux) {
      return;
    }
    final candidates = [
      if (Platform.environment['SSL_CERT_FILE'] != null)
        Platform.environment['SSL_CERT_FILE']!,
      '/etc/ssl/certs/ca-certificates.crt', // Debian, Ubuntu, Fedora (compat)
      '/etc/pki/tls/certs/ca-bundle.crt', // RHEL, CentOS
      '/etc/ssl/ca-bundle.pem', // openSUSE
      '/etc/ssl/cert.pem', // Alpine, Arch
    ];
    for (final path in candidates) {
      if (!File(path).existsSync()) {
        continue;
      }
      try {
        SecurityContext.defaultContext.setTrustedCertificates(path);
        return;
      } on TlsException {
        // Bundle ilegible o ya cargado: probamos el siguiente candidato.
      }
    }
  }

  static refreshProxy() {
    String proxy = "";
    final type = JiruHubStorage.getSetting(SettingKey.proxyType);
    if (type == "DIRECT") {
      proxy = type;
    } else {
      proxy = '$type ${JiruHubStorage.getSetting(SettingKey.proxy)}';
    }

    if (!_isInitialized) {
      SocksProxy.initProxy(proxy: proxy);
      return;
    }
    SocksProxy.setProxy(proxy);
  }

  static Future<void> cleanCookie(String url) async {
    await _cookieJar.delete(Uri.parse(url));
  }

  static Future<void> setCookie(String cookies, String url) async {
    final cookieList = cookies.split(';');
    for (final cookie in cookieList) {
      await _cookieJar.saveFromResponse(
        Uri.parse(url),
        [Cookie.fromSetCookieValue(cookie)],
      );
    }
  }

  static Future<String> getCookie(String url) async {
    final cookies = await _cookieJar.loadForRequest(Uri.parse(url));
    return cookies.map((e) => e.toString()).join(';');
  }
}

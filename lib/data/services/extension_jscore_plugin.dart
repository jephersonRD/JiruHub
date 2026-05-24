import 'dart:async';
import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:jiruhub/utils/log.dart';

const dartBridgeMessageName = 'DART_BRIDGE_MESSAGE_NAME';

class JsBridge {
  final JavascriptRuntime jsRuntime;
  int _messageCounter = 0;
  static final Map<int, Completer> _pendingRequests = {};
  final Object? Function(Object? value)? toEncodable;
  static final Map<String, Future<dynamic> Function(dynamic message)>
      _handlers = {};
  JsBridge({
    required this.jsRuntime,
    this.toEncodable,
  }) {
    final bridgeScriptEvalResult = jsRuntime.evaluate(jsBridgeJs);
    if (bridgeScriptEvalResult.isError) {
      logger.info('Error eval bridge script');
    }
    final windowEvalResult =
        jsRuntime.evaluate('var window = global = globalThis;');
    if (windowEvalResult.isError) {
      logger.info('Error eval window script');
    }
    jsRuntime.onMessage(dartBridgeMessageName, (message) {
      _onMessage(message);
    });
  }

  _onMessage(dynamic message) async {
    if (message['isRequest']) {
      final handler = _handlers[message['name']];
      if (handler == null) {
        logger.info('Error: no handlers for message $message');
      } else {
        final result = await handler(message['args']);
        final jsResult = jsRuntime.evaluate(
            'onMessageFromDart(false, ${message['callId']}, "${message['name']}",${jsonEncode(result, toEncodable: toEncodable)})');
        if (jsResult.isError) {
          logger.info('Error sending message to JS: $jsResult');
        }
      }
    } else {
      final completer = _pendingRequests.remove(message['callId']);
      if (completer == null) {
        logger.info('Error: no completer for response for message $message');
      } else {
        completer.complete(message['result']);
      }
    }
  }

  sendMessage(String name, dynamic message) async {
    if (_messageCounter > 999999999) {
      _messageCounter = 0;
    }
    _messageCounter += 1;
    final completer = Completer();
    _pendingRequests[_messageCounter] = completer;
    final jsResult = jsRuntime.evaluate(
        'window.onMessageFromDart(true, $_messageCounter, "$name",${jsonEncode(message, toEncodable: toEncodable)})');
    if (jsResult.isError) {
      logger.info('Error sending message to JS: $jsResult');
    }

    return completer.future;
  }

  // final _handlers = {};

  setHandler(String name, Future<dynamic> Function(dynamic message) handler) {
    _handlers[name] = handler;
  }
}

const jsBridgeJs = '''
globalThis.DartBridge = (() => {
    let callId = 0;
    const DART_BRIDGE_MESSAGE_NAME = '$dartBridgeMessageName';
    globalThis.onMessageFromDart = async (isRequest, callId, name, args) => {
        if (isRequest) {
            if (handlers[name]) {
                sendMessage(DART_BRIDGE_MESSAGE_NAME, JSON.stringify({
                    isRequest: false,
                    callId,
                    name,
                    result: await handlers[name](args),
                }));
            }
        }
        else {
            const pendingResolve = pendingRequests[callId];
            delete pendingRequests[callId];
            if (pendingResolve) {
                pendingResolve(args);
            }
        }
        return null;
    };
    const handlers = {};
    const pendingRequests = {};
    return {
        sendMessage: async (name, args) => {
            if (callId > 999999999) {
                callId = 0;
            }
            callId += 1;
            sendMessage(DART_BRIDGE_MESSAGE_NAME, JSON.stringify({
                isRequest: true,
                callId,
                name,
                args,
            }),call=((res)=>{}));
            return new Promise((resolve) => {
                pendingRequests[callId] = resolve;
                call(resolve)
            });
        },
        setHandler: (name, handler) => {
            handlers[name] = handler;
        },
        resolveRequest: (callId, result) => {
            sendMessage(DART_BRIDGE_MESSAGE_NAME, JSON.stringify({
                isRequest: false,
                callId,
                result,
            }));
        },
    };
})();
global = globalThis;
''';

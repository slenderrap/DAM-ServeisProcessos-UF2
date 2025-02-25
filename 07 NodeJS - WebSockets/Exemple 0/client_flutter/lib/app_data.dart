import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'utils_websockets.dart';

class AppData extends ChangeNotifier {
  final WebSocketsHandler _wsHandler = WebSocketsHandler();
  final String _wsServer = "localhost";
  final int _wsPort = 8888;

  int frame = 0;
  Map<String, dynamic> gameState = {};
  bool isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = Duration(seconds: 3);

  String _direction = "none";
  String color = "black";

  String get direction => _direction;

  set direction(String newDirection) {
    if (_direction != newDirection) {
      _direction = newDirection;
      if (isConnected) {
        sendMessage(jsonEncode({"type": "move", "direction": _direction}));
      }
      notifyListeners();
    }
  }

  AppData() {
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print("S'ha assolit el màxim d'intents de reconnexió.");
      }
      return;
    }

    isConnected = false;
    notifyListeners();

    _wsHandler.connectToServer(
      _wsServer,
      _wsPort,
      _onWebSocketMessage,
      onError: _onWebSocketError,
      onDone: _onWebSocketClosed,
    );

    isConnected = true;
    _reconnectAttempts = 0;
    notifyListeners();
  }

  void _onWebSocketMessage(String message) {
    try {
      var data = jsonDecode(message);
      if (data["type"] == "update") {
        gameState = data["gameState"];
        frame++;

        // Buscar el nostre client i assignar el color
        String? clientId = _wsHandler.socketId;
        if (clientId != null && gameState["clients"] != null) {
          var clientData = gameState["clients"].firstWhere(
            (client) => client["id"] == clientId,
            orElse: () => null,
          );

          if (clientData != null) {
            color = clientData["color"] ?? "black";
          }
        }

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processant missatge WebSocket: $e");
      }
    }
  }

  void _onWebSocketError(dynamic error) {
    if (kDebugMode) {
      print("Error de WebSocket: $error");
    }
    isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  void _onWebSocketClosed() {
    if (kDebugMode) {
      print("WebSocket tancat. Intentant reconnectar...");
    }
    isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      if (kDebugMode) {
        print(
            "Intent de reconnexió #$_reconnectAttempts en ${_reconnectDelay.inSeconds} segons...");
      }
      Future.delayed(_reconnectDelay, () {
        _connectToWebSocket();
      });
    } else {
      if (kDebugMode) {
        print(
            "No es pot reconnectar al servidor després de $_maxReconnectAttempts intents.");
      }
    }
  }

  void sendMessage(String message) {
    if (isConnected) {
      _wsHandler.sendMessage(message);
    }
  }

  void disconnect() {
    _wsHandler.disconnectFromServer();
    isConnected = false;
    notifyListeners();
  }
}
